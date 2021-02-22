--Card-Mistress Stellar Angel
function c249000594.initial_effect(c)
	--lvchange
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3606728,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c249000594.lvcon)
	e1:SetTarget(c249000594.lvtg)
	e1:SetOperation(c249000594.lvop)
	c:RegisterEffect(e1)
	--to hand 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92826944,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(c249000594.cost2)
	e2:SetTarget(c249000594.target2)
	e2:SetOperation(c249000594.operation2)
	c:RegisterEffect(e2)
end
function c249000594.confilter(c)
	return c:IsSetCard(0x1D4) and (not c:IsCode(249000594)) and c:IsFaceup()
end
function c249000594.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249000594.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function c249000594.lvfilter(c,lv)
	return c:IsFaceup() and ((c:GetLevel()>0 and c:GetLevel()~=lv) or (c:GetRank()>0 and c:GetRank()~=lv))
end
function c249000594.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c249000594.lvfilter(chkc,e:GetHandler():GetLevel()) end
	if chk==0 then return Duel.IsExistingTarget(c249000594.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler():GetLevel()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c249000594.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e:GetHandler():GetLevel())
end
function c249000594.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lvrk
		if tc:GetRank()>0 then lvrk = tc:GetRank() else lvrk = tc:GetLevel() end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lvrk)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		c:RegisterEffect(e1)
	end
end
function c249000594.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c249000594.filter2(c)
	return c:IsSetCard(0x1D4) and c:IsAbleToHand()
end
function c249000594.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_GRAVE and c249000594.filter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c249000594.filter2,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c249000594.filter2,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c249000594.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
