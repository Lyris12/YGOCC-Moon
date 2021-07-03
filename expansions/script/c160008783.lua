--Medivatale Griffin
function c160008783.initial_effect(c)
   c:EnableReviveLimit()
	aux.AddOrigEvoluteType(c)
   aux.AddEvoluteProc(c,nil,7,aux.FilterBoolFunction(Card.IsSetCard,0xab5),2)
end

