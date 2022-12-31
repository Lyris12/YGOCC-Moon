--Extension Rune - Base
local m=80838881
local cm=_G["c"..m]

function cm.initial_effect(c)
	aux.I_Am_Runic(c)
	aux.Normal_Runic_Attach(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetCondition(cm.condition)
	e1:SetOperation(cm.extop)
	c:RegisterEffect(e1)
end

function cm.condition(e,tp,eg,ep,ev,re,r,rp)	
	local c=e:GetHandler()
	return c:GetFlagEffect(180808882) > 0
end

function cm.extop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(cm.dlval1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.ResetFlagEffect(c,180808882)
end

function cm.dlval1(e,re,dam,r,rp,rc)
	return dam + 100
end