--created by Seth, coded by Lyris & Rawstone, bugfixes by somen00b
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcCode2(c,cid.matfilter1,cid.matfilter2,false,false)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(cid.splimit)
	c:RegisterEffect(e0)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(cid.value)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(cid.actcon)
	c:RegisterEffect(e1)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCountLimit(1,id)
	e5:SetCondition(aux.bdcon)
	e5:SetCost(cid.drcost)
	e5:SetTarget(cid.destg)
	e5:SetOperation(cid.desop)
	c:RegisterEffect(e5)
end
function cid.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION) or not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function cid.value(e,c)
	return Duel.GetMatchingGroupCount(cid.atkfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)*300
end
	function cid.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x83e)
end
	function cid.cfilter(c)
	return c:IsSetCard(0x83e) and c:IsAbleToRemoveAsCost()
end
	function cid.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
	function cid.cfilter2(c)
	return c:IsLocation(LOCATION_REMOVED) and c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x83e) and c:IsAbleToDeckAsCost()
end
	function cid.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter2,tp,LOCATION_REMOVED,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(Duel.SelectMatchingCard(tp,cid.cfilter2,tp,LOCATION_REMOVED,0,3,3,e:GetHandler()),nil,2,REASON_COST)
end
	function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
	function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsChainAttackable() then
			Duel.ChainAttack()
	end
end
	function cid.matfilter1(c)
	return c:IsFusionType(TYPE_SYNCHRO) and c:IsFusionSetCard(0x83e)
end
	function cid.matfilter2(c)
	return c:IsFusionType(TYPE_FUSION) and c:IsFusionSetCard(0x83e)
end
