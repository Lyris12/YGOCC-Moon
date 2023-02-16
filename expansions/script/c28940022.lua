--Prayer to the Deptheavens
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	Deptheaven.EnableAltSummon(c,aux.TRUE,LOCATION_HAND+LOCATION_GRAVE,Deptheaven.Is)
	Deptheaven.EnableFastSummon(c,ref.efilter,ref.attfilter)
end
function ref.efilter(e) return e:IsActiveType(TYPE_MONSTER) end
function ref.attfilter(c) return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_WATER) end
