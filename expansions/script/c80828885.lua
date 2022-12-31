--Effect Rune - Draw
local m=80828883
local cm=_G["c"..m]

function cm.initial_effect(c)
	aux.I_Am_Runic(c)
	aux.Normal_Runic_Attach(c)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CUSTOM+18080888)
	e3:SetCountLimit(1)
	e3:SetOperation(cm.desop)
	c:RegisterEffect(e3)
end

function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	local tp = e:GetHandlerPlayer()
	Duel.Draw(tp,1,REASON_EFFECT)
end