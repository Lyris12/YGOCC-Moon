--Ritmi Mistici - Rullo di Tamburi
--Script by XGlitchy30
function c76565325.initial_effect(c)
	c:EnableCounterPermit(0x1555)
	--COUNTER TRACKER
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e0:SetRange(LOCATION_SZONE)
	e0:SetOperation(c76565325.ctop0)
	c:RegisterEffect(e0)
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0x:SetRange(LOCATION_SZONE)
	e0x:SetCode(EVENT_CHAIN_SOLVED)
	e0x:SetLabelObject(e0)
	e0x:SetOperation(c76565325.ctop1)
	c:RegisterEffect(e0x)
	--RESET COUNTER_TRACKER
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e00:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e00:SetCode(EVENT_LEAVE_FIELD)
	e00:SetLabelObject(e0x)
	e00:SetCondition(c76565325.resetcon1)
	e00:SetOperation(c76565325.reset1)
	c:RegisterEffect(e00)
	local e000=Effect.CreateEffect(c)
	e000:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e000:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e000:SetCode(EVENT_SSET)
	e000:SetLabelObject(e0x)
	e000:SetOperation(c76565325.reset0)
	c:RegisterEffect(e000)
	--add counters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,76565325+EFFECT_COUNT_CODE_OATH)
	e1:SetLabelObject(e0x)
	e1:SetTarget(c76565325.target)
	e1:SetOperation(c76565325.activate)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,76165325)
	e2:SetTarget(c76565325.rmtg)
	e2:SetOperation(c76565325.rmop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,76265325)
	e3:SetCondition(c76565325.sccon)
	e3:SetTarget(c76565325.sctg)
	e3:SetOperation(c76565325.scop)
	c:RegisterEffect(e3)
end
--filters
function c76565325.spfilter(c,e,tp)
	return c:IsSetCard(0x7555) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--counter tracker
function c76565325.ctop0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local count=c:GetCounter(0x1555)
	e:SetLabel(count)
end
function c76565325.ctop1(e,tp,eg,ep,ev,re,r,rp)
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
function c76565325.resetcon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DESTROY)
end
function c76565325.reset1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
function c76565325.reset0(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
--add counters
function c76565325.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanAddCounter(tp,0x1555,3,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1555)
end
function c76565325.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1555,3)
		e:GetLabelObject():GetLabelObject():SetLabel(0)
		e:GetLabelObject():SetLabel(0)
	end
end
--spsummon
function c76565325.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1555,1,REASON_EFFECT) end
end
function c76565325.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsCanRemoveCounter(tp,0x1555,1,REASON_EFFECT) then
		c:RemoveCounter(tp,0x1555,1,REASON_EFFECT)
		Duel.BreakEffect()
		if c:GetCounter(0x1555)==0 then
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+76565329,e,REASON_EFFECT,tp,tp,1)
			if Duel.Destroy(c,REASON_EFFECT)~=0 then
				if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
					local rm=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
					if rm:GetCount()>0 then
						Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)
					end
				end
			end
		end
	end
end
--destroy
function c76565325.sccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsReason(REASON_DESTROY) and rp==tp
end
function c76565325.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c76565325.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c76565325.scop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c76565325.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)		
	end
end