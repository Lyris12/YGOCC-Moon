--Dracosis Rage
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY|CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Activate(summon)
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_DISABLE_SUMMON|CATEGORY_DESTROY|CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetCondition(s.condition1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target1)
	e2:SetOperation(s.activate1)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x300),tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c)
	return c:IsSetCard(0x300) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		s.operation(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x300),tp,LOCATION_MZONE,0,1,nil)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	if Duel.Destroy(eg,REASON_EFFECT)>0 then
		s.operation(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(aux.FaceupFilter(Card.IsSetCard,0x300),tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e3)
	end
end
