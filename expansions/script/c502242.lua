--Unveiled White Crusader
--scripted by Rawstone
local s,id=GetID()
function s.initial_effect(c)
		--sset
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_HAND)
		e1:SetCountLimit(1,id)
		e1:SetCost(s.cost)
		e1:SetTarget(s.target)
		e1:SetOperation(s.operation)
		c:RegisterEffect(e1)
		--negate
		local e2=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetCode(EVENT_CHAINING)
		e2:SetCountLimit(1,id+500)
		e2:SetCost(aux.bfgcost)
		e2:SetCondition(s.spcon)
		e2:SetTarget(s.distg)
		e2:SetOperation(s.spop)
		c:RegisterEffect(e2)
end
	function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
	function s.filter(c)
	return c:IsCode(502240) and c:IsSSetable()
end
	function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
	function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
	function s.negcfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_FUSION) and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,49306994)
end
	function s.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
	function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(s.negcfilter,tp,LOCATION_MZONE,0,1,nil)
end
	function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
	function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		if Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tc=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil)
		Duel.HintSelection(tc)
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end