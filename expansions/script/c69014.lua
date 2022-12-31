--Peach Beach Solemn March
function c69014.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c69014.condition)
	e1:SetTarget(c69014.target)
	e1:SetOperation(c69014.activate)
	e1:SetCountLimit(1,69014)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c69014.handcon)
	c:RegisterEffect(e2)
end
function c69014.cfilter(c)
	return Card.IsFaceup(c) and c:IsSetCard(0x6969)
end
function c69014.condition(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp and Duel.IsExistingMatchingCard(c69014.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
	end
end
function c69014.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		Duel.SetTargetPlayer(1-tp)
	end
end
function c69014.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
function c69014.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x6969) and c:IsType(TYPE_XYZ)
end
function c69014.handcon(e)
	return Duel.IsExistingMatchingCard(c69014.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
