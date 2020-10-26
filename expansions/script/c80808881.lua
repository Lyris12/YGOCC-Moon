--Lesser Rune of Strength
local m=80808881
local cm=_G["c"..m]
function cm.initial_effect(c)
	aux.I_Am_Runic(c)
	aux.Normal_Runic_Attach(c)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
end