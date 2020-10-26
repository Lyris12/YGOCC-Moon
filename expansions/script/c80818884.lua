--Trigger Rune - Total Destruction
local m=80818884
local cm=_G["c"..m]

function cm.initial_effect(c)
	aux.I_Am_Runic(c)
	aux.Normal_Runic_Attach(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(cm.condition)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end

function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	Duel.RaiseSingleEvent(c,EVENT_CUSTOM+18080888,re,0,0,p,0)
end