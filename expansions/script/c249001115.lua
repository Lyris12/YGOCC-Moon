--Sacred-Element Gathering
function c249001115.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c249001115.target)
	e1:SetOperation(c249001115.activate)
	c:RegisterEffect(e1)
end
function c249001115.filter(c)
	return c:IsSetCard(0x1229) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c249001115.disfilter(c)
	return c:IsSetCard(0x229) and c:IsDiscardable()
end
function c249001115.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001115.filter,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(c249001115.disfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function c249001115.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	if Duel.DiscardHand(tp,c249001115.disfilter,1,1,REASON_EFFECT+REASON_DISCARD) ~= 0 then
		local g=Duel.SelectMatchingCard(tp,c249001115.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
		if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,1108) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
