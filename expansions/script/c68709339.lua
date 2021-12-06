--HDD RR
--scripted by concordia
function c68709339.initial_effect(c)
 	--link summon
    aux.AddLinkProcedure(c,c68709339.lfilter,2,2)
    c:EnableReviveLimit()
    --atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c68709339.atkval)
	c:RegisterEffect(e2)
	--chain attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68709339,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1)
	e3:SetCondition(c68709339.atcon)
	e3:SetOperation(c68709339.atop)
	c:RegisterEffect(e3)
end
function c68709339.lfilter(c)
    return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xf08) or c:IsSetCard(0xf09))
end
function c68709339.filter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xf08) or c:IsSetCard(0xf09))
end
function c68709339.atkval(e,c)
    local g=Duel.GetMatchingGroup(c68709339.filter,c:GetControler(),LOCATION_GRAVE,0,nil)
    local ct=g:GetClassCount(Card.GetCode)
    return ct*200
end
function c68709339.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and c:GetFlagEffect(72989439)==0
		and c:IsChainAttackable()
end
function c68709339.atop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack()
end