--Multitask Decifrazione
--Script by XGlitchy30
function c86433609.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(864)
	e1:SetCost(c86433609.cost)
	e1:SetTarget(c86433609.target)
	e1:SetOperation(c86433609.activate)
	c:RegisterEffect(e1)
	--place link
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86433609,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c86433609.lkcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c86433609.lktg)
	e2:SetOperation(c86433609.lkop)
	c:RegisterEffect(e2)
end
--resets
function c86433609.resetcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject():GetLabelObject()
	return not c:IsLocation(LOCATION_EXTRA) or not c:IsControler(e:GetLabel())
end
function c86433609.reseteff(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	c:Reset()
	e:Reset()
end
--filters
function c86433609.cfilter1(c,tp)
	return ((c:IsOnField() and c:IsFaceup()) or c:IsLocation(LOCATION_HAND)) and c:IsSetCard(0x86f) and c:IsAbleToGraveAsCost()
end
function c86433609.cfilter2(c)
	return c:IsType(TYPE_LINK) and not c:IsFaceup()
end
function c86433609.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x86f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--Activate
function c86433609.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c86433609.cfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c86433609.cfilter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function c86433609.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 end
end
function c86433609.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)<=0 then return end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA):Filter(c86433609.cfilter2,nil)
	if g:GetCount()>=3 then ct=3 else ct=g:GetCount() end
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
		local cg=g:Select(1-tp,ct,ct,nil)
		if cg:GetCount()==0 then return end
		Duel.ConfirmCards(tp,cg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg=cg:Select(tp,1,1,nil)
		local ec=sg:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetLabelObject(ec)
		e1:SetTargetRange(0,1)
		e1:SetTarget(c86433609.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetLabelObject(ec)
		e2:SetTargetRange(1,0)
		e2:SetValue(c86433609.aclimit)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local reset=Effect.CreateEffect(e:GetHandler())
		reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		reset:SetCode(EVENT_ADJUST)
		reset:SetLabel(1-tp)
		reset:SetLabelObject(e1)
		reset:SetCountLimit(1)
		reset:SetCondition(c86433609.resetcon)
		reset:SetOperation(c86433609.reseteff)
		Duel.RegisterEffect(reset,tp)
		local reset2=reset:Clone()
		reset2:SetLabelObject(e2)
		Duel.RegisterEffect(reset2,tp)
	else
		local extra=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
		Duel.ConfirmCards(tp,extra)
	end
end
function c86433609.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and c~=e:GetLabelObject()
end
function c86433609.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetLabel(864) and re:GetHandler():GetOriginalCode()==86433609
end
--place link
function c86433609.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)<15 and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function c86433609.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c86433609.cfilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
end
function c86433609.lkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c86433609.cfilter2),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		if g:GetFirst():IsLocation(LOCATION_EXTRA) then
			local p,loc,alt=0,0,0
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then p=tp loc=LOCATION_MZONE
			elseif Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then p=tp loc=LOCATION_SZONE
			elseif Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then p=1-tp loc=LOCATION_MZONE
			elseif Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then p=1-tp loc=LOCATION_SZONE
			else alt=100 end
			if alt==100 then
				Duel.Remove(g:GetFirst(),POS_FACEUP,REASON_RULE)
			else
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
				e1:SetLabelObject(g:GetFirst())
				e1:SetTargetRange(LOCATION_EXTRA,0)
				e1:SetTarget(c86433609.debugtofield)
				Duel.RegisterEffect(e1,tp)
				Duel.MoveToField(g:GetFirst(),tp,p,loc,POS_FACEUP_ATTACK,false)
				e1:Reset()
			end
		end
		if Duel.SendtoDeck(g,1-tp,nil,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c86433609.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
			if not Duel.SelectYesNo(tp,aux.Stringid(86433609,2)) then return end
			Duel.BreakEffect()
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c86433609.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if sg:GetCount()>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function c86433609.debugtofield(e,c,sump,sumtype,sumpos,targetp,se)
    return c==e:GetLabelObject()
end