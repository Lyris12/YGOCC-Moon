--Dracosis Hunting Tactic
function c39414.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetDescription(aux.Stringid(84389640,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c39414.condition)
	e2:SetOperation(c39414.operation)
	e2:SetCountLimit(1,39414+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e2)
end
function c39414.condition(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return false end
	return (a:IsPosition(POS_FACEUP_ATTACK) and a:IsSetCard(0x300) and d:IsPosition(POS_FACEUP_ATTACK)) or
		(d:IsPosition(POS_FACEUP_ATTACK) and d:IsSetCard(0x300) and a:IsPosition(POS_FACEUP_ATTACK))
end
function c39414.operation(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc or not bc:IsLocation(LOCATION_MZONE) then return end
	if not e:GetHandler():IsRelateToEffect(e) or not bc or not bc:IsRelateToEffect(e) or not bc:IsControler(1-tp) or not ac or not ac:IsRelateToEffect(e) or not ac:IsControler(1-tp) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	e1:SetValue(bc:GetAttack())
	ac:RegisterEffect(e1)
end
