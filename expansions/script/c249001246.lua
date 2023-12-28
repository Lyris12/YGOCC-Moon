--Space Time Gizmo Shield Charm
function c249001246.initial_effect(c)
	--to grave
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c249001246.indcon)
	e1:SetOperation(c249001246.indop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--end battle phase
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34710660,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,249001246+EFFECT_COUNT_CODE_DUEL)
	e4:SetCondition(c249001246.condition)
	e4:SetCost(aux.bfgcost)
	e4:SetOperation(c249001246.operation)
	c:RegisterEffect(e4)
	--avoid damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
function c249001246.cfilter(c)
	return c:IsFaceup() and c:IsCode(249001241)
end
function c249001246.indcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001246.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c249001246.indop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TRUE)
	e1:SetValue(c249001246.indct)
	e1:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function c249001246.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
function c249001246.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and Duel.IsExistingMatchingCard(c249001246.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c249001246.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
