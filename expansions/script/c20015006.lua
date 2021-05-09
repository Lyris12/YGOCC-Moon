--Pastel Palettes - Luminous Once More
--Script by XyLeN
function c20015006.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20015006+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c20015006.activate)
	c:RegisterEffect(e1)
	--target limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x880))
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
function c20015006.tdfilter(c)
	return c:IsSetCard(0x880) and c:IsAbleToDeck()
end
function c20015006.thfilter(c)
	return not aux.LvL6or7Check(c) and c:IsSetCard(0x880) and c:IsAbleToHand()
end
function c20015006.tgfilter(c)
	return aux.LvL6or7Check(c) and c:IsSetCard(0x880) and c:IsAbleToGrave()
end
function c20015006.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c20015006.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(20015006,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,1,3,nil)
		Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
		local thcheck=Duel.IsExistingMatchingCard(c20015006.thfilter,tp,LOCATION_DECK,0,1,nil)
		local tgcheck=Duel.IsExistingMatchingCard(c20015006.tgfilter,tp,LOCATION_DECK,0,1,nil)
		if thcheck and tgcheck and Duel.SelectYesNo(tp,aux.Stringid(20015006,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local r1=Duel.SelectMatchingCard(tp,c20015006.thfilter,tp,LOCATION_DECK,0,1,1,nil) 
			if Duel.SendtoHand(r1,nil,REASON_EFFECT) then
				Duel.ConfirmCards(1-tp,r1)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local r2=Duel.SelectMatchingCard(tp,c20015006.tgfilter,tp,LOCATION_DECK,0,1,1,nil) 
				Duel.SendtoGrave(r2,REASON_EFFECT)
			end
		end
		Duel.ShuffleDeck(tp)
	end
end