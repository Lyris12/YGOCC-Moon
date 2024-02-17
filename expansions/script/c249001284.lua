--Cyber-Varia-Magic Link Shield
function c249001284.initial_effect(c)
	c:SetUniqueOnField(1,0,249001284)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c249001284.condition)
	c:RegisterEffect(e1)
	--halve damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(c249001284.val)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c249001284.target)
	e3:SetValue(c249001284.indct)
	c:RegisterEffect(e3)
end
function c249001284.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1FD)
end
function c249001284.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001284.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c249001284.val(e,re,dam,r,rp,rc)
	return math.floor(dam/2)
end
function c249001284.target(e,c)
	return c:IsSetCard(0x1FD) or c:IsType(TYPE_LINK)
end
function c249001284.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end