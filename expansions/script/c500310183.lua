function c500310183.initial_effect(c)
--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(500310183,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c500310183.discon)
	e1:SetCost(c500310183.cost)
	e1:SetTarget(c500310183.target)
	e1:SetOperation(c500310183.operation)
	c:RegisterEffect(e1)

end
function c500310183.discon(e,tp,eg,ep,ev,re,r,rp)
return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end

function c500310183.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and Duel.CheckLPCost(tp,1500) end
	Duel.SendtoGrave(e:GetHandler(),REASON_DISCARD)
	Duel.PayLPCost(tp,1500)
end
function c500310183.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c500310183.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end

end
