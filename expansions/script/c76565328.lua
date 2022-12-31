--Ritmi Mistici - Grande Orchestrale
--Script by XGlitchy30
function c76565328.initial_effect(c)
	c:EnableCounterPermit(0x1555)
	--COUNTER TRACKER
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e0:SetRange(LOCATION_FZONE)
	e0:SetOperation(c76565328.ctop0)
	c:RegisterEffect(e0)
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0x:SetRange(LOCATION_FZONE)
	e0x:SetCode(EVENT_CHAIN_SOLVED)
	e0x:SetLabelObject(e0)
	e0x:SetOperation(c76565328.ctop1)
	c:RegisterEffect(e0x)
	--RESET COUNTER_TRACKER
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e00:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e00:SetCode(EVENT_LEAVE_FIELD)
	e00:SetLabelObject(e0x)
	e00:SetCondition(c76565328.resetcon1)
	e00:SetOperation(c76565328.reset1)
	c:RegisterEffect(e00)
	local e000=Effect.CreateEffect(c)
	e000:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e000:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e000:SetCode(EVENT_SSET)
	e000:SetLabelObject(e0x)
	e000:SetOperation(c76565328.reset0)
	c:RegisterEffect(e000)
	--add counters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,76565328+EFFECT_COUNT_CODE_OATH)
	e1:SetLabelObject(e0x)
	e1:SetTarget(c76565328.target)
	e1:SetOperation(c76565328.activate)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,76165328)
	e2:SetLabelObject(e0x)
	e2:SetTarget(c76565328.rmtg)
	e2:SetOperation(c76565328.rmop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetLabelObject(e0x)
	e3:SetCountLimit(1,76265328)
	e3:SetCondition(c76565328.sccon)
	e3:SetTarget(c76565328.sctg)
	e3:SetOperation(c76565328.scop)
	c:RegisterEffect(e3)
	--stats boost
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x7555))
	e4:SetValue(c76565328.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
end
--filters
function c76565328.counterf(c)
	return c:IsSetCard(0x7555) and c:IsFaceup() and c:IsCanRemoveCounter(tp,0x1555,1,REASON_EFFECT)
end
function c76565328.shfilter(c)
	return c:IsSetCard(0x7555) and c:IsAbleToDeck()
end
--counter tracker
function c76565328.ctop0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local count=c:GetCounter(0x1555)
	e:SetLabel(count)
end
function c76565328.ctop1(e,tp,eg,ep,ev,re,r,rp)
	local code=71565323
	local c=e:GetHandler()
	local prev=e:GetLabelObject():GetLabel()
	if c:GetCounter(0x1555)<prev then
		e:SetLabel(e:GetLabel()+prev-c:GetCounter(0x1555))
		e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()-prev+c:GetCounter(0x1555))
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+76565329,e,REASON_EFFECT,tp,tp,prev-c:GetCounter(0x1555))
	else
		e:GetLabelObject():SetLabel(c:GetCounter(0x1555))
	end
	if e:GetLabel()<=16 then
		for num=0,e:GetLabel() do
			if e:GetLabel()==num then
				local factor=1000000*num
				for numres=0,16 do
					local factores=1000000*numres
					e:GetHandler():ResetFlagEffect(code+factores)
				end
				e:GetHandler():RegisterFlagEffect(code+factor,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(76565323,num))
			end
		end
	end
end
--reset counter tracker
function c76565328.resetcon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DESTROY)
end
function c76565328.reset1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
function c76565328.reset0(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
--add counters
function c76565328.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanAddCounter(tp,0x1555,10,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,10,0,0x1555)
end
function c76565328.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1555,10)
		e:GetLabelObject():GetLabelObject():SetLabel(0)
		e:GetLabelObject():SetLabel(0)
	end
end
--spsummon
function c76565328.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76565328.counterf,tp,LOCATION_SZONE,0,1,nil) end
end
function c76565328.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local count=Duel.GetMatchingGroup(c76565328.counterf,tp,LOCATION_SZONE,0,nil)
	if count:GetCount()<=0 then return end
	local ct=count:GetFirst()
	while ct do
		if ct:IsCanRemoveCounter(tp,0x1555,1,REASON_EFFECT) then
			ct:RemoveCounter(tp,0x1555,1,REASON_EFFECT)
		end
		ct=count:GetNext()
	end
	Duel.BreakEffect()
	if c:GetCounter(0x1555)==0 then
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+76565329,e,REASON_EFFECT,tp,tp,1)
		if Duel.Destroy(c,REASON_EFFECT)~=0 then
			e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()+1)
			local g=Duel.GetDecktopGroup(1-tp,10)
			local rm=g:Filter(Card.IsAbleToRemove,nil)
			if rm:GetCount()==10 then 
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
--destroy
function c76565328.sccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsReason(REASON_DESTROY)
end
function c76565328.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabelObject():GetLabel()
	local alt=0
	if re:GetHandler():IsCode(76565322) then 
		ct=1 
		alt=1
	end
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(c76565328.shfilter,tp,LOCATION_GRAVE,0,ct,nil) end
	e:SetLabel(alt)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c76565328.scop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	if e:GetLabel()==1 then
		ct=1
	end
	if ct<=0 then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c76565328.shfilter),tp,LOCATION_GRAVE,0,nil)
	if ct>sg:GetCount() then return end
	if ct>0 and sg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tg=sg:Select(tp,ct,ct,nil)
		Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	e:GetLabelObject():SetLabel(0)
end
--stats boost
function c76565328.atkval(e,c)
	return e:GetHandler():GetCounter(0x1555)*50
end