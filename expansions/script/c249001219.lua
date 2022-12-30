--Chaotic Magic Circle
function c249001219.initial_effect(c)
	aux.AddCodeList(c,249001218)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c249001219.target)
	e1:SetOperation(c249001219.activate)
	c:RegisterEffect(e1)
	--draw 
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCondition(aux.exccon)
	e2:SetCost(c249001219.cost2)
	e2:SetTarget(c249001219.target2)
	e2:SetOperation(c249001219.operation2)
	c:RegisterEffect(e2)
end
function c249001219.filter(c)
	return c:IsCode(249001218) and c:IsAbleToHand()
end
function c249001219.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001219.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c249001219.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001219.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c249001219.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function c249001219.filter2(c)
	return c:IsCode(249001218) and c:IsAbleToDeck() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function c249001219.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_GRAVE+LOCATION_REMOVED and c249001219.filter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c249001219.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c249001219.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function c249001219.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
