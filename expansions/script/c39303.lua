function c39303.initial_effect(c)
	aux.AddFusionProcCode2(c,39301,39302,true,false)
	c:EnableReviveLimit()
	--Remove
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c39303.rmtg)
	e3:SetOperation(c39303.rmop)
	e3:SetCountLimit(1,39303)
	c:RegisterEffect(e3)
end
function c39303.filter(c)
	return c:GetCode()>39300 and c:GetCode()<39326 and c:IsAbleToHand() and not c:IsCode(39311,39312)
end
function c39303.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39303.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c39303.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c39303.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c39303.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
