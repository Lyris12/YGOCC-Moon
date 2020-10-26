--Effect Rune - Minor Restoration
local m=80828886
local cm=_G["c"..m]

function cm.initial_effect(c)
	aux.I_Am_Runic(c)
	aux.Normal_Runic_Attach(c)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CUSTOM+18080888)
	e3:SetCountLimit(1)
	e3:SetOperation(cm.effop)
	c:RegisterEffect(e3)
end

function cm.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
-- Insert Effect Here
	Duel.Recover(c:GetOwner(),500,REASON_EFFECT)

--
	c:RegisterFlagEffect(180808882,RESET_PHASE+PHASE_END,0,1)
end	
