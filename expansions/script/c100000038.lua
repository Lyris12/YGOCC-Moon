--Fascination du Vaisseau
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[This card can be used to Ritual Summon any Insect Ritual Monster from your hand or face-up Extra Deck.
	You must also Tribute monsters from your hand or field whose total Levels equal or exceed the Level of the Ritual Monster you Ritual Summon.]]
	local e1=aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND|LOCATION_EXTRA,nil,nil,true)
	e1:Desc(0)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_INSECT)
end