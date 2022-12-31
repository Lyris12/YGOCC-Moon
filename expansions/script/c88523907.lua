--Kitseki Sake
--Script by XGlitchy30
function c88523907.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c88523907.condition)
	e1:SetTarget(c88523907.target)
	e1:SetOperation(c88523907.activate)
	c:RegisterEffect(e1)
end
--filters
function c88523907.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x215a)
end
--Activate
function c88523907.condition(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not Duel.IsExistingMatchingCard(c88523907.cfilter,tp,LOCATION_MZONE,0,2,nil) then return false end
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function c88523907.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and Duel.IsPlayerCanDiscardDeck(1-tp,2) then
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,2)
	end
end
function c88523907.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
	end
end