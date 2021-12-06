--HDDRom&Ram
--coded by Concordia
function c210925340.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c210925340.mfilter,2,2)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c210925340.atkval)
	c:RegisterEffect(e1)
	--Extra Attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30270176,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c210925340.atkcon)
	e2:SetTarget(c210925340.atktg)
	e2:SetOperation(c210925340.atkop)
	c:RegisterEffect(e2)
end
function c210925340.mfilter(c)
	return c:IsSetCard(0xf08) or c:IsSetCard(0xf09)
end
function c210925340.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf08)
end
function c210925340.atkval(e,c)
	return Duel.GetMatchingGroup(c210925340.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)*200
end
function c210925340.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler() and aux.bdcon(e,tp,eg,ep,ev,re,r,rp)
end
function c210925340.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToBattle() and not e:GetHandler():IsHasEffect(EFFECT_EXTRA_ATTACK) end
end
function c210925340.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
end