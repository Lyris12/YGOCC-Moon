--Deptheaven on Earth
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	Deptheaven.EnableAltSummon(c,function(c) return c:GetSummonLocation()==LOCATION_EXTRA end,LOCATION_EXTRA,Card.IsFaceup)
	Deptheaven.EnableFastSummon(c,ref.efilter,ref.rcfilter)
end
function ref.efilter(e) return e:IsActiveType(TYPE_SPELL+TYPE_TRAP) and e:IsHasType(EFFECT_TYPE_ACTIVATE) end
function ref.rcfilter(c) return c:IsRace(RACE_FAIRY+RACE_FISH) end
