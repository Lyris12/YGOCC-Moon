--Untergang Sturmbrecher
function c400012.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c400012.target)
	e1:SetOperation(c400012.activate)
	e1:SetCondition(c400012.condition)
	e1:SetCountLimit(1,400012)
	c:RegisterEffect(e1)
end
function c400012.filter(c)
	return c:IsType(TYPE_MONSTER)and c:IsFaceup() 
end
function c400012.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x246)
end
function c400012.dfilter(c,self)
return c:IsSetCard(0x246) and c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_QUICKPLAY) and not c:IsCode(400012)
end
function c400012.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c400012.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c400012.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
if chk==0 then return Duel.IsExistingTarget(c400012.filter,tp,0,LOCATION_MZONE,1,nil) end
Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c400012.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function c400012.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and not tc:IsDisabled() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if Duel.IsExistingMatchingCard(c400012.dfilter,tp,LOCATION_GRAVE,0,1,nil,self) and tc:IsAbleToHand() and Duel.SelectYesNo(tp,aux.Stringid(400012,0)) then
			Duel.BreakEffect()
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
