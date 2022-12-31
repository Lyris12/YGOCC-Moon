--Emperor
function c11000146.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c11000146.condition)
	e1:SetTarget(c11000146.target)
	e1:SetOperation(c11000146.activate)
	c:RegisterEffect(e1)
end
function c11000146.cfilter(c)
	return c:IsFaceup() and c:IsCode(11000130)
end
function c11000146.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c11000146.cfilter,tp,LOCATION_MZONE,0,1,nil) and tp~=Duel.GetTurnPlayer()
end
function c11000146.filter(c)
	return c:IsAttackPos() and c:IsAbleToDeck()
end
function c11000146.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11000146.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(c11000146.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c11000146.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c11000146.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end
