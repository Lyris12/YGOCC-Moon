--Muscwole Murdermania
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cid=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cid
end
local id,cid=getID()
function cid.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x777))
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	--atkup
	local e1=Effect.CreateEffect(c)
	--e1:SetDescription(aux.Stringid(12023931,0))
                e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(cid.atktg)
	e1:SetOperation(cid.atkop)
	c:RegisterEffect(e1)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(cid.descon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	--actlimit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(0,1)
	e5:SetValue(1)
	e5:SetCondition(cid.actcon)
	c:RegisterEffect(e5)
end
function cid.dfilter(c)
	return c:IsSetCard(0x777) and c:GetAttack()>=(c:GetBaseAttack()+2100)
end
function cid.afilter(c,tp)
	return c and c:IsSetCard(0x777) and c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsControler(tp) and c:GetAttack()>=(c:GetBaseAttack()+2800)
end
function cid.descon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(cid.dfilter,tp,LOCATION_MZONE,0,1,nil) 
end
function cid.actcon(e)
	local tp=e:GetHandlerPlayer()
	return cid.afilter(Duel.GetAttacker(),tp) or cid.afilter(Duel.GetAttackTarget(),tp)
end
function cid.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x777)
end
function cid.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(cid.atkfilter,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cid.atkfilter,tp,LOCATION_MZONE,0,1,1,c)
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
