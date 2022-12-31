--Medivatale Scorpiude
function c160008787.initial_effect(c)
   c:EnableReviveLimit()
	aux.AddOrigEvoluteType(c)
   aux.AddEvoluteProc(c,nil,8,aux.FilterBoolFunction(Card.IsSetCard,0xab5),2)
end

