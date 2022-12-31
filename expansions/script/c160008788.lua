--Medivatale Onibear
function c160008788.initial_effect(c)
   c:EnableReviveLimit()
	aux.AddOrigEvoluteType(c)
   aux.AddEvoluteProc(c,nil,6,aux.FilterBoolFunction(Card.IsSetCard,0xab5),1)
end

