--Change True Power of Vision HERO - Magic Vision
function c249001161.initial_effect(c)
	return
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCondition(c249001161.condition)
	e1:SetTarget(c249001161.target)
	e1:SetOperation(c249001161.operation)
	c:RegisterEffect(e1)
end
function c249001161.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(249001155)
end
function c249001161.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001161.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(tp,249001161)==0
end
function c249001161.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function c249001161.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetLocation()==LOCATION_GRAVE and chkc:GetControler()==tp and c249001161.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c249001161.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c249001161.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function c249001161.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,249001161)~=0 then return end
	Duel.RegisterFlagEffect(tp,249001161,0,0,0)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end