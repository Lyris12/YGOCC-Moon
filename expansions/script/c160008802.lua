--Medivatale Flora
function c160008802.initial_effect(c)
   c:EnableReviveLimit()
	aux.AddOrigEvoluteType(c)
   aux.AddEvoluteProc(c,nil,10,aux.FilterBoolFunction(Card.IsSetCard,0xab5),3,3)
end

