--Medivatale Bahamut
function c160008806.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigEvoluteType(c)
   aux.AddEvoluteProc(c,nil,7,aux.FilterBoolFunction(Card.IsSetCard,0xab5),2)
end


