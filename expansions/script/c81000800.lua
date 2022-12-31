--Verglascent's Paragon Rune
local id=81000800
local m=81000800
local cm=_G["c"..id]
local cid=_G["c"..id]

function cid.initial_effect(c)
	Auxiliary.I_Am_Paragon(c)
	Auxiliary.I_Am_Runic(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(cid.acop)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_EXTRA) 
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(cm.sdcon)
	e3:SetOperation(Auxiliary.sdop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1996))
	e4:SetValue(cid.atkval)
	c:RegisterEffect(e4)
end


function cid.sdcon(e,tp,eg,ep,ev,re,r,rp)
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	return ct1>=(ct2+3) 
end

function cid.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsSetCard(0x1996) and e:GetHandler():GetFlagEffect(1)>0 then
		Duel.GainRP(e:GetHandlerPlayer(),50)
	end
end

function cid.atkval(c)
	local g=Duel.GetFieldGroup(c:GetOwner(),0,LOCATION_MZONE):Filter(cid.atkfilter,nil)
	return (g:GetSum(Card.GetBaseAttack)-g:GetSum(Card.GetAttack)) * 0.5
end

function cid.atkfilter(c)
	return c:GetAttack()<=c:GetBaseAttack()
end

--Card.GetBaseAttack - 