--Qwei, Hollohom Avenger
local ref,id=GetID()
xpcall(function() require("expansions/script/Hollohom") end,function() require("script/Hollohom") end)
function ref.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,Hollohom.ID,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),1,true,true)
	
end
