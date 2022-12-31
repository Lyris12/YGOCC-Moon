--Mysterious Sylph
function c53313910.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,53313910)
	e1:SetCondition(c53313910.spcon)
	c:RegisterEffect(e1)
	--You can banish this card from your GY, add 1 "Mysterious" Pandemonium monster from your deck to your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,53313911)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c53313910.target)
	e2:SetOperation(c53313910.operation)
	c:RegisterEffect(e2)
end
function c53313910.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xCF6) and not c:IsCode(53313910)
end 
function c53313910.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c53313910.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function c53313910.thfilter(c)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_PANDEMONIUM) and c:IsAbleToHand()
end
function c53313910.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313910.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c53313910.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c53313910.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
