--Dolphin
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:GetCode()>30200 and tc:GetCode()<30230 end)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(scard.dcon)
	e1:SetTarget(scard.target)
	e1:SetOperation(scard.operation)
	e1:SetCountLimit(1,s_id)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCondition(scard.d2con)
	c:RegisterEffect(e2)
end
function scard.dcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_BATTLE)
end
function scard.d2con(e,tp,eg,ep,ev,re,r,rp)
	if ((e:GetHandler():IsReason(REASON_EFFECT)) or e:GetHandler():IsReason(REASON_COST))
	and re:IsHasType(0xFFD) and re:GetHandler():IsType(TYPE_EFFECT)
	and not e:GetHandler():IsPreviousLocation(LOCATION_DECK) then return true end
end
function scard.filter(c)
	return c:IsMantra() and c:IsAbleToHand() and not c:IsCode(s_id)
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(scard.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,scard.filter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
end
