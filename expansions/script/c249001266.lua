--Mage-Core of Gaia
function c249001266.initial_effect(c)
	aux.EnableDualAttribute(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(249001266,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,249001266)
	e1:SetCondition(c249001266.condition)
	e1:SetCost(c249001266.cost)
	e1:SetTarget(c249001266.target)
	e1:SetOperation(c249001266.operation)
	c:RegisterEffect(e1)
end
function c249001266.cfilter(c)
	return c:IsFaceup() and c:IsCode(249001261)
end
function c249001266.condition(e,tp,eg,ep,ev,re,r,rp)
	return aux.IsDualState(e) and Duel.IsExistingMatchingCard(c249001266.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c249001266.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function c249001266.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001266.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	if dc:IsSetCard(0x237) and Duel.IsPlayerCanDraw(tp,1)
		and Duel.SelectYesNo(tp,aux.Stringid(69584564,0)) then
		Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,dc)
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.ShuffleHand(tp)
	end
end