--Level Find
function c249000112.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c249000112.target)
	e1:SetOperation(c249000112.activate)
	c:RegisterEffect(e1)
end
function c249000112.filter(c)
	return c:IsSetCard(0x41) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsHasEffect(EFFECT_NECRO_VALLEY)
end
function c249000112.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000112.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c249000112.filter2(c)
	return c:IsSetCard(0x41) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c249000112.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c249000112.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)	and Duel.IsExistingMatchingCard(c249000112.filter2,tp,LOCATION_HAND,0,1,g:GetFirst())
			and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,507) then
			local g2=Duel.SelectMatchingCard(tp,c249000112.filter2,tp,LOCATION_HAND,0,1,1,g:GetFirst())
			Duel.ConfirmCards(1-tp,g2)
			Duel.SendtoDeck(g2,nil,2,REASON_EFFECT)
			Duel.ShuffleDeck(tp)
			Duel.Draw(tp,1,REASON_EFFECT)
		end
		Duel.ConfirmCards(1-tp,g)
	end
end
