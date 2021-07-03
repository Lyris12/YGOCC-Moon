--Medivatale Ponady
function c160008786.initial_effect(c)
	  c:EnableReviveLimit()
	aux.AddOrigEvoluteType(c)
   aux.AddEvoluteProc(c,nil,4,aux.FilterBoolFunction(Card.IsSetCard,0xab5),1)
end

