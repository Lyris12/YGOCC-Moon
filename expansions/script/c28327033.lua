--灯火之魔女·凉意
local m=28327033
local cm=_G["c"..m]
Duel.LoadScript("c28327000.lua")
function cm.initial_effect(c)
	Yukino.ShikiNoAkari(c)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(cm.distg)
	c:RegisterEffect(e2)
	--negate attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,m)
	e3:SetCondition(cm.condition)
	e3:SetOperation(cm.operation)
	c:RegisterEffect(e3)
end
function cm.distg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and d:IsType(TYPE_RITUAL) and c:IsRace(RACE_SPELLCASTER)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
