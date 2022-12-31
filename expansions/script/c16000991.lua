--Love Song Idol
local cid,id=GetID()
function cid.initial_effect(c)
	 aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
	aux.AddEvoluteProc(c,nil,3,cid.filter1,1,1)  
	--Conjoint Procedure
	aux.AddOrigConjointType(c)
	aux.EnableConjointAttribute(c,3)
 --special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(cid.target)
	e1:SetCost(cid.cost)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
 --special summon
	local e13=Effect.CreateEffect(c)
	e13:SetDescription(aux.Stringid(id,0))
	e13:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e13:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e13:SetCountLimit(1)
	e13:SetTarget(cid.target)
	e13:SetOperation(cid.operation)
	c:RegisterEffect(e13)
   --pierce
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e5:SetCondition(cid.damcon)
	e5:SetOperation(cid.damop)
	c:RegisterEffect(e5)
   local e42=Effect.CreateEffect(c)
	e42:SetType(EFFECT_TYPE_XMATERIAL)
	e42:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e42)
	local e52=Effect.CreateEffect(c)
	e52:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_CONTINUOUS)
	e52:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e52:SetCondition(cid.damcon)
	e52:SetOperation(cid.damop)
	c:RegisterEffect(e52)
end
function cid.filter1(c,ec,tp)
	return not c:IsType(TYPE_TOKEN)
end
 function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
end  
function cid.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND,0,1,nil,e,tp,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cid.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c==Duel.GetAttacker() and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsDefensePos()
end
function cid.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev*2)
end