--Miss-Fortune Wondertain
function c212250.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(212250,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,212250)
	e1:SetCondition(c212250.condition)
	e1:SetCost(c212250.cost)
	e1:SetTarget(c212250.target)
	e1:SetOperation(c212250.operation)
	c:RegisterEffect(e1)
end
function c212250.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x244d) and c:IsType(TYPE_MONSTER)
end
function c212250.filter2(c)
	return c:IsSetCard(0x244d) and c:IsType(TYPE_MONSTER)
end
function c212250.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.IsExistingMatchingCard(c212250.filter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(c212250.filter2,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil)
end
function c212250.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function c212250.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(c212250.filter2,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c212250.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c212250.filter2,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		Duel.NegateActivation(ev)
	end
end


