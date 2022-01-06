--Vocaldiva Suono Paradisiaco
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.AND(aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE)),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1)
	c:EnableReviveLimit()
	--flip face-down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.flipcon)
	e1:SetTarget(cid.fliptg)
	e1:SetOperation(cid.flipop)
	c:RegisterEffect(e1)
	--Pierce face-down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cid.atkcon)
	e2:SetOperation(cid.atkop)
	c:RegisterEffect(e2)
	--banish deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FLIP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(cid.rmcon)
	e3:SetTarget(cid.rmtg)
	e3:SetOperation(cid.rmop)
	c:RegisterEffect(e3)
end
--FLIP FACEDOWN
--filters
function cid.flipfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
---
function cid.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cid.fliptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.flipfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(cid.flipfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	end
	Duel.SetChainLimit(cid.chlimit)
end
function cid.chlimit(e,ep,tp)
	return tp==ep
end
function cid.flipop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.flipfilter,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		local pos=POS_FACEDOWN
		if tc:IsLocation(LOCATION_MZONE) then pos=POS_FACEDOWN_DEFENSE end
		Duel.ChangePosition(tc,pos)
		tc=g:GetNext()
	end
end
--PIERCE FACEDOWN
function cid.atkcon(e)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return a and d and d:IsPosition(POS_FACEDOWN_DEFENSE)
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	c:RegisterEffect(e2)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e5:SetCondition(cid.damcon)
	e5:SetOperation(cid.damop)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	c:RegisterEffect(e5)
end
function cid.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c==Duel.GetAttacker() and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsDefensePos()
end
function cid.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev*2)
end
--BANISH DECK
--filters
---------
function cid.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
function cid.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local rg=Duel.GetDecktopGroup(1-tp,5)
		return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and rg:FilterCount(Card.IsAbleToRemove,nil)==5 
	end
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	end
	local rg=Duel.GetDecktopGroup(1-tp,5)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,5,0,0)
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangePosition(g:GetFirst(),POS_FACEUP)
		if g:GetFirst():IsFacedown() then return end
		Duel.BreakEffect()
		local rg=Duel.GetDecktopGroup(1-tp,5)
		Duel.DisableShuffleCheck()
		Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
	end
end