--created by Swag, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(aux.AND(cid.condition1,cid.con))
	e2:SetTarget(cid.target1)
	e2:SetOperation(cid.activate1)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(aux.AND(cid.condition,cid.con))
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	local e3=e1:Clone()
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e3:SetCondition(cid.condition2)
	e3:SetTarget(cid.target2)
	e3:SetOperation(cid.operation)
	c:RegisterEffect(e3)
end
function cid.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x412)
end
function cid.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and ep~=tp
end
function cid.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function cid.activate1(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and rp~=tp and Duel.IsChainNegatable(ev)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function cid.filter(c)
	return c:GetSummonLocation()&LOCATION_EXTRA~=0
end
function cid.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and rp~=tp and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard,cid.filter),tp,LOCATION_MZONE,0,1,nil,0x412)
end
function cid.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsAbleToDeck() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoDeck(eg,nil,2,REASON_EFFECT)
	end
end
