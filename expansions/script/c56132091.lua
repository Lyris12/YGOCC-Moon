--Torrential Currents
--Script by APurpleApple
local s = c56132091
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Protec
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(aux.indsval)
	e2:SetTarget(s.tg)
	c:RegisterEffect(e2)
end

function s.tg(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
