--Extension Rune - Base
local m=80838887
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
	local c=e:GetHandler()
	local tc=e:GetHandler()
	local tp = e:GetHandlerPlayer()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(cm.retcon)
		e1:SetOperation(cm.retop)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.ResetFlagEffect(c,180808882)
end