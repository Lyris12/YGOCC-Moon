--Ritmi Mistici - Trombettiere
--Script by XGlitchy30
function c76565315.initial_effect(c)
	c:EnableCounterPermit(0x1555)
	--COUNTER TRACKER
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e0:SetRange(LOCATION_SZONE)
	e0:SetOperation(c76565315.ctop0)
	c:RegisterEffect(e0)
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0x:SetRange(LOCATION_SZONE)
	e0x:SetCode(EVENT_CHAIN_SOLVED)
	e0x:SetLabelObject(e0)
	e0x:SetOperation(c76565315.ctop1)
	c:RegisterEffect(e0x)
	--RESET COUNTER_TRACKER
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e00:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e00:SetCode(EVENT_LEAVE_FIELD)
	e00:SetLabelObject(e0)
	e00:SetCondition(c76565315.resetcon1)
	e00:SetOperation(c76565315.reset1)
	c:RegisterEffect(e00)
	local e000=Effect.CreateEffect(c)
	e000:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e000:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e000:SetCode(EVENT_SSET)
	e000:SetLabelObject(e0)
	e000:SetOperation(c76565315.reset0)
	c:RegisterEffect(e000)
	--Spell Form
	local act=Effect.CreateEffect(c)
	act:SetDescription(aux.Stringid(76565315,0))
	act:SetType(EFFECT_TYPE_FIELD)
	act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	act:SetCode(EFFECT_SPSUMMON_PROC_G)
	act:SetRange(LOCATION_HAND)
	act:SetLabelObject(e0)
	act:SetCondition(c76565315.actcon)
	act:SetOperation(c76565315.actop)
	c:RegisterEffect(act)
	--activate placeholder
	local x=Effect.CreateEffect(c)
	x:SetCategory(CATEGORY_COUNTER)
	x:SetType(EFFECT_TYPE_ACTIVATE)
	x:SetCode(EVENT_FREE_CHAIN)
	x:SetLabelObject(e0x)
	x:SetOperation(c76565315.xop)
	c:RegisterEffect(x)
	--remove counter
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetLabelObject(e0x)
	e1:SetTarget(c76565315.rctg)
	e1:SetOperation(c76565315.rcop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,76565315)
	e2:SetLabelObject(e0x)
	e2:SetCondition(c76565315.sccon)
	e2:SetTarget(c76565315.sctg)
	e2:SetOperation(c76565315.scop)
	c:RegisterEffect(e2)
end
--filters
function c76565315.filter(c)
	return c:IsSetCard(0x7555) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
--Spell Form
function c76565315.actcon(c,e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function c76565315.actop(e,tp,eg,ep,ev,re,r,rp,c)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	c:RegisterFlagEffect(76565315,RESET_EVENT+0x1fe0000,EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE,0)
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetReset(RESET_EVENT+0x1fc0000)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
	local kp=Effect.CreateEffect(c)
	kp:SetType(EFFECT_TYPE_SINGLE)
	kp:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	kp:SetCode(EFFECT_REMAIN_FIELD)
	kp:SetReset(RESET_EVENT+0x1fc0000)
	c:RegisterEffect(kp)
	local te=c:GetActivateEffect()
	Duel.RaiseEvent(c,EVENT_CUSTOM+76565315,te,0,tp,tp,0)
	Duel.Hint(HINT_CARD,0,76565315)
	if not Duel.IsCanAddCounter(tp,0x1555,2,c) then return end
	c:AddCounter(0x1555,2)
	e:GetLabelObject():SetLabel(2)
	Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+76165315,e,0,0,tp,0)
end
function c76565315.xop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x1555,2)
	e:GetLabelObject():GetLabelObject():SetLabel(0)
	e:GetLabelObject():SetLabel(0)
end
--counter tracker
function c76565315.ctop0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local count=c:GetCounter(0x1555)
	e:SetLabel(count)
end
function c76565315.ctop1(e,tp,eg,ep,ev,re,r,rp)
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
function c76565315.resetcon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DESTROY)
end
function c76565315.reset1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
function c76565315.reset0(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
--remove counter
function c76565315.rccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(76565315)>0
end
function c76565315.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1555,1,REASON_EFFECT) end
end
function c76565315.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsCanRemoveCounter(tp,0x1555,1,REASON_EFFECT) then
		c:RemoveCounter(tp,0x1555,1,REASON_EFFECT)
		Duel.BreakEffect()
		if c:GetCounter(0x1555)==0 then
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+76565329,e,REASON_EFFECT,tp,tp,1)
			Duel.Destroy(c,REASON_EFFECT)
			e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()+1)
		end
	end
end
--search
function c76565315.sccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsReason(REASON_DESTROY)
end
function c76565315.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabelObject():GetLabel()
	local alt=0
	if re:GetHandler():IsCode(76565322) then 
		ct=1 
		alt=1
	end
	if chk==0 then return Duel.IsExistingMatchingCard(c76565315.filter,tp,LOCATION_DECK,0,ct,nil) end
	e:SetLabel(alt)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_DECK)
end
function c76565315.scop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	if e:GetLabel()==1 then
		ct=1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c76565315.filter,tp,LOCATION_DECK,0,ct,ct,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	e:GetLabelObject():SetLabel(0)
end