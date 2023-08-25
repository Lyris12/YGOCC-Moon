--Bigbang Counter
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent activates a card or effect: Destroy 1 Bigbang Monster you control, and if you do, negate the activation, then apply the following effect depending on the destroyed monster's Vibe on the field.
	--● Neutral: Banish that opponent's card.
	--● Positive: inflict 1000 damage to your opponent.
	--● Negative: Draw 1 card.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_BIGBANG) and c:HasVibe()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local vb=g:GetFirst():GetVibe()
	if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		if vb==0 then
			Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		end
		if vb==1 then
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
		if vb==-1 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end