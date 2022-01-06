--Primalgeddon Savior
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--fusion material
	local mat_list={cid.ffilter1,aux.FilterBoolFunction(Card.IsFusionSetCard,0x487),cid.ffilter3}
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,false,false,table.unpack(mat_list))
	--activate limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(cid.condition)
	e1:SetValue(cid.aclimit)
	c:RegisterEffect(e1)
	--halve stats
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(cid.atktg)
	e4:SetValue(cid.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e5:SetValue(cid.defval)
	c:RegisterEffect(e5)
end
--FUSION MATERIAL
function cid.ffilter1(c)
	return c:IsFusionSetCard(0x487) and c:IsFusionType(TYPE_FUSION+TYPE_SYNCHRO)
end
function cid.ffilter3(c)
	return not c:IsFusionType(TYPE_PENDULUM+TYPE_PANDEMONIUM+TYPE_EFFECT)
end
--ACTIVATE LIMIT
function cid.condition(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function cid.aclimit(e,re,tp)
	return true
end
--HALVE STATS
function cid.atktg(e,c)
	return true
end
function cid.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
function cid.defval(e,c)
	return math.ceil(c:GetDefense()/2)
end