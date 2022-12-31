--Kitseki Esilae
--Script by XGlitchy30
function c88523903.initial_effect(c)
	--deck destruction
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88523903,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c88523903.ddcon)
	e1:SetCost(c88523903.ddcost)
	e1:SetTarget(c88523903.ddtg)
	e1:SetOperation(c88523903.ddop)
	c:RegisterEffect(e1)
end
--filters
--deck destruction
function c88523903.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0x215a)
end
function c88523903.ddcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c88523903.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x215a)
	local ct=g:GetClassCount(Card.GetCode)
	if chk==0 then return ct>1 and Duel.IsPlayerCanDiscardDeck(1-tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
function c88523903.ddop(e,tp,eg,ep,ev,re,r,rp)
	--name check
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x215a)
	local ct=g:GetClassCount(Card.GetCode)
	if ct<=1 then return end
	----------
	local fix=0
	if math.fmod(ct,2)~=0 then 
		fix=ct-1
	else
		fix=ct
	end
	local discard=fix/2
	Duel.DiscardDeck(1-tp,discard,REASON_EFFECT)
end