--Chaotic Magical Arena
function c249001222.initial_effect(c)
	aux.AddCodeList(c,249001218)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,249001222+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c249001222.activate)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,249001218))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c249001222.cost)
	e3:SetTarget(c249001222.target)
	e3:SetOperation(c249001222.operation)
	c:RegisterEffect(e3)
end
function c249001222.filter(c)
	return c:IsCode(249001218) or aux.IsCodeListed(c,249001218)
end
function c249001222.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c249001222.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(249001222,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
function c249001222.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function c249001222.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001218.costfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249001218.costfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249001222.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c249001222.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.BreakEffect()
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end