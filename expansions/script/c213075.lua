--Eternnal Journey
function c213075.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,213075+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c213075.target)
	e1:SetOperation(c213075.activate)
	c:RegisterEffect(e1)
end
function c213075.tgfilter(c)
	return c:IsSetCard(0x2700) and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
end
function c213075.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c213075.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c213075.thcfilter(c)
	return c:IsSetCard(0x2700) and c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function c213075.thfilter(c,tc)
	return c:IsCode(213080)
		and c:IsAbleToHand()
end
function c213075.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,c213075.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE)
		and Duel.IsExistingMatchingCard(c213075.thcfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(c213075.thfilter,tp,LOCATION_DECK,0,1,nil,tc)
		and Duel.SelectYesNo(tp,aux.Stringid(213075,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c213075.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
		Duel.BreakEffect()
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
