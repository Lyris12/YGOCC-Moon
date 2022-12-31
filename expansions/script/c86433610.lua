--Multitask Trasferimento
--Script by XGlitchy30
function c86433610.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c86433610.target)
	c:RegisterEffect(e1)
	--ability gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetValue(c86433610.value)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	--redirect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c86433610.rdcon)
	e3:SetOperation(c86433610.rdprev)
	c:RegisterEffect(e3)
	--draw
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(86433610,0))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,86433610)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c86433610.drawtg)
	e4:SetOperation(c86433610.draw)
	c:RegisterEffect(e4)
end
--filters
function c86433610.rdtfilter(c,rp,tp)
	return c:IsSetCard(0x86f) and c:IsType(TYPE_MONSTER) and c:GetFlagEffect(86433610)<=0 and c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsControler(tp)
end
function c86433610.tdfilter(c)
	return c:IsSetCard(0x86f) and c:IsAbleToDeck()
end
--Activate
function c86433610.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectOption(tp,aux.Stringid(86433597,0),aux.Stringid(86433597,1),aux.Stringid(86433597,2),aux.Stringid(86433597,3),aux.Stringid(86433597,4))
	e:GetLabelObject():SetLabel(op+10)
	e:GetHandler():SetHint(CHINT_DESC,aux.Stringid(86433597,op))
end
--ability gain
function c86433610.value(e,c)
	local op=e:GetLabel()
	if op==10 then return TYPE_TOON
	elseif op==11 then return TYPE_SPIRIT
	elseif op==12 then return TYPE_UNION
	elseif op==13 then return TYPE_DUAL
	elseif op==14 then return TYPE_FLIP
	else return 0 end
end
--redirect
function c86433610.rdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c86433610.rdtfilter,1,nil,rp,tp)
end
function c86433610.rdprev(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c86433610.rdtfilter,nil,rp,tp)
	if g:GetCount()<=0 then return end
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(86433610,RESET_CHAIN,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
		if tc:GetDestination()==LOCATION_GRAVE then
			local redirect=Effect.CreateEffect(tc)
			redirect:SetType(EFFECT_TYPE_SINGLE)
			redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			redirect:SetCode(EFFECT_CANNOT_TO_GRAVE)
			redirect:SetReset(RESET_EVENT+EVENT_CUSTOM+86433610)
			tc:RegisterEffect(redirect)
		elseif tc:GetDestination()==LOCATION_HAND then
			local redirect=Effect.CreateEffect(tc)
			redirect:SetType(EFFECT_TYPE_SINGLE)
			redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			redirect:SetCode(EFFECT_CANNOT_TO_HAND)
			redirect:SetReset(RESET_EVENT+EVENT_CUSTOM+86433610)
			tc:RegisterEffect(redirect)
		elseif (tc:GetDestination()==LOCATION_DECK or tc:GetDestination()==LOCATION_EXTRA) then
			local redirect=Effect.CreateEffect(tc)
			redirect:SetType(EFFECT_TYPE_SINGLE)
			redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			redirect:SetCode(EFFECT_CANNOT_TO_DECK)
			redirect:SetReset(RESET_EVENT+EVENT_CUSTOM+86433610)
			tc:RegisterEffect(redirect)
		else
			local redirect=Effect.CreateEffect(tc)
			redirect:SetType(EFFECT_TYPE_SINGLE)
			redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			redirect:SetCode(EFFECT_CANNOT_REMOVE)
			redirect:SetReset(RESET_EVENT+EVENT_CUSTOM+86433610)
			tc:RegisterEffect(redirect)
		end
		if Duel.Remove(tc,POS_FACEUP,REASON_RULE+REASON_TEMPORARY)~=0 then
			if tc:IsLocation(LOCATION_REMOVED) then
				tc:RegisterFlagEffect(80433610,RESET_EVENT+(RESETS_STANDARD-RESET_REMOVE-RESET_TEMP_REMOVE)+RESET_PHASE+PHASE_END,0,1)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabelObject(tc)
				e1:SetCountLimit(1)
				e1:SetCondition(c86433610.retcon)
				e1:SetOperation(c86433610.retop)
				Duel.RegisterEffect(e1,tp)
			end
		end
		Duel.RaiseEvent(tc,EVENT_CUSTOM+86433610,e,0,tp,tp,0)
		Duel.RaiseSingleEvent(tc,EVENT_CUSTOM+86433610,e,0,tp,tp,0)
	end
end
function c86433610.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(80433610)~=0
end
function c86433610.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
--draw
function c86433610.exfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function c86433610.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(c86433610.exfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,e:GetHandler())
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c86433610.draw(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=Duel.SelectMatchingCard(tp,c86433610.exfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,e:GetHandler())
	if #sg>0 then
		Duel.Exile(sg,REASON_EFFECT)
		Duel.BreakEffect()
		local access,randtab=Group.CreateGroup(),{86433597,86433598,86433599,86433604}
		access:KeepAlive()
		Duel.DisableShuffleCheck()
		for i=1,11 do
			table.insert(randtab,randtab[4]+i)
		end
		for i=1,3 do
			local index=math.random(1,#randtab)
			local d=Duel.CreateToken(tp,randtab[index])
			Duel.SendtoDeck(d,tp,2,REASON_EFFECT)
			access:AddCard(d)
		end
		if #access==3 then
			Duel.BreakEffect()
			Duel.ConfirmCards(1-tp,access)
			Duel.ShuffleDeck(tp)
			access:DeleteGroup()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end