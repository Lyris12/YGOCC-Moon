--Medivatale Deerady
function c160008789.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigEvoluteType(c)
   aux.AddEvoluteProc(c,nil,9,aux.FilterBoolFunction(Card.IsSetCard,0xab5),2)
end

