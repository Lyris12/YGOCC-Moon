--Mage-Core of Future
function c249001267.initial_effect(c)
	aux.EnableDualAttribute(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(249001267,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,249001267)
	e1:SetCondition(c249001267.condition)
	e1:SetCost(c249001267.cost)
	e1:SetOperation(c249001267.operation)
	c:RegisterEffect(e1)
end
function c249001267.cfilter(c)
	return c:IsFaceup() and c:IsCode(249001261)
end
function c249001267.condition(e,tp,eg,ep,ev,re,r,rp)
	return aux.IsDualState(e) and Duel.IsExistingMatchingCard(c249001267.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c249001267.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function c249001267.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001267.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c249001267.droperation)
	Duel.RegisterEffect(e1,tp)
end
function c249001267.droperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,249001267)
	Duel.Draw(tp,2,REASON_EFFECT)
end