--HDD Uzume
--Coded by Concordia,cred Moon Burst
function c68709377.initial_effect(c)
    --link summon
    aux.AddLinkProcedure(c,c68709377.lfilter,2)
    c:EnableReviveLimit()
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68709377,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c68709377.negcon)
	e1:SetCost(c68709377.negcost)
	e1:SetTarget(c68709377.negtg)
	e1:SetOperation(c68709377.negop)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCountLimit(1)
	e2:SetTarget(c68709377.indtg)
	e2:SetValue(c68709377.indval)
	c:RegisterEffect(e2)
end
function c68709377.lfilter(c)
    return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xf09) or c:IsSetCard(0xf08))
end
function c68709377.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf09) and c:IsType(TYPE_MONSTER)
end
function c68709377.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)  and ep==1-tp
		and Duel.IsExistingMatchingCard(c68709377.filter,tp,LOCATION_MZONE,0,3,nil)
end
function c68709377.cfilter(c,rtype)
	return c:IsType(rtype) and c:IsAbleToGraveAsCost() and c:IsSetCard(0xf08)
end
function c68709377.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rtype=bit.band(re:GetActiveType(),0x7)
	if chk==0 then return Duel.IsExistingMatchingCard(c68709377.cfilter,tp,LOCATION_HAND,0,1,nil,rtype) end
	Duel.DiscardHand(tp,c68709377.cfilter,1,1,REASON_COST,nil,rtype)
end
function c68709377.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function c68709377.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev) 
end
function c68709377.indtg(e,c)
	return c:IsSetCard(0xf09)
end
function c68709377.indval(e,re,r,rp)
    return r&REASON_BATTLE+REASON_EFFECT~=0
end