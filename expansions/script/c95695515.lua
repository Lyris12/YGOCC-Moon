--Shrine of the Lotus Blade
--Commissioned by: Leon Duvall
--Scripted by: Remnancee & Lyris
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	c:EnableCounterPermit(0x3ff)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--Add counter
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_FZONE)
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(cid.ctcon)
	e2:SetOperation(cid.ctop)
	c:RegisterEffect(e2)
	--cannot be target/indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetCondition(cid.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(cid.indcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--pierce
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_PIERCE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3ff))
	e5:SetCondition(cid.pcon)
	c:RegisterEffect(e5)
	--atk
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3ff))
	e6:SetValue(1000)
	e6:SetCondition(cid.acon)
	c:RegisterEffect(e6)
	--double attack
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3ff))
	e7:SetValue(1)
	e7:SetCondition(cid.atkcon)
	c:RegisterEffect(e7)
	--act limit
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_CHAINING)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCondition(cid.chaincon)
	e8:SetOperation(cid.chainop)
	c:RegisterEffect(e8)
end
--Add counter
function cid.ctcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local c=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and c:IsSetCard(0x3ff) and e:GetHandler():GetFlagEffect(1)>0
end
function cid.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x3ff,1)
end
--cannot be target/indestructable
function cid.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x3ff)>=1
end
--pierce
function cid.pcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x3ff)>=2
end
--atk
function cid.acon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x3ff)>=3
end
--double attack
function cid.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x3ff)>=4
end
--act limit
function cid.chaincon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x3ff)>=5
end
function cid.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x3ff) and re:IsActiveType(TYPE_SPELL) then
		Duel.SetChainLimit(cid.chainlm)
	end
end
function cid.chainlm(e,rp,tp)
	return not e:GetHandler():IsType(TYPE_MONSTER)
end