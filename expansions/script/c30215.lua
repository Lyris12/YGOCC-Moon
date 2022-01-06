--Mantra Kitsune
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:GetCode()>30200 and tc:GetCode()<30230 end)
	--Bounce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(scard.bcon)
	e1:SetCost(scard.cost)
	e1:SetTarget(scard.target)
	e1:SetOperation(scard.operation)
	e1:SetCountLimit(1,s_id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
function scard.bcon(e,tp,eg,ep,ev,re,r,rp)
	return ((e:GetHandler():IsReason(REASON_EFFECT)) or e:GetHandler():IsReason(REASON_COST))
	and re:IsHasType(0xFFD)
	and re:GetHandler():IsMantra()
end
function scard.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
