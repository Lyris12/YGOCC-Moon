--Dracosis Hunting Tactic
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(TIMING_BATTLE_START|TIMING_DAMAGE_STEP)
	e2:HOPT(true)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local a,d=Duel.GetBattleMonster(tp)
	return a and d and a:IsPosition(POS_FACEUP_ATTACK) and a:IsSetCard(0x300) and a:IsRelateToBattle() and d:IsPosition(POS_FACEUP_ATTACK) and d:IsRelateToBattle()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a,d=Duel.GetBattleMonster(tp)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,a,1,a:GetControler(),a:GetLocation(),d:GetAttack())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local a,d=Duel.GetBattleMonster(tp)
	if not a or not d or not a:IsRelateToBattle() or not d:IsRelateToBattle() or not a:IsFaceup() or not d:IsFaceup() or not a:IsControler(tp) or not d:IsControler(1-tp) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
	e1:SetValue(d:GetAttack())
	a:RegisterEffect(e1)
end
