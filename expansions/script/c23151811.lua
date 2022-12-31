--Palude Tossica || Toxic Swamp
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk down
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.atktg)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--quick act
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(s.quickact)
	c:RegisterEffect(e2)
end
--atk down
function s.atktg(e,c)
	return not c:IsRace(RACE_REPTILE)
end
function s.valfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_REPTILE) and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.valfilter,e:GetHandlerPlayer(),LOCATION_GRAVE+LOCATION_EXTRA,0,nil)*-150
end
--quickact
function s.quickact(e,c)
	return c:IsType(TYPE_PANDEMONIUM) and c:IsSetCard(0x9fa)
end