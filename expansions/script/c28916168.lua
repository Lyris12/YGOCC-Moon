--Coded by Kinny~
local ref=_G['c'..28916168]
local id=28916168
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(ref.atkcon)
	e3:SetTarget(ref.atktg)
	e3:SetValue(ref.atkval)
	c:RegisterEffect(e3)
	--Immune
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(ref.etarget)
	e4:SetValue(ref.efilter)
	c:RegisterEffect(e4)
end

--ATK
function ref.atkcon(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
end
function ref.atktg(e,c)
	return c==Duel.GetAttacker() and c:IsSetCard(1856)
end
function ref.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),0,LOCATION_MZONE,nil,TYPE_MONSTER)*200
end

--Immune
function ref.etarget(e,c)
	return c:IsSetCard(1856) and c:IsPosition(POS_ATTACK)
end
function ref.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end