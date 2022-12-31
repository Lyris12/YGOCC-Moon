--Medivatale Undyne
function c160008785.initial_effect(c)
	 c:EnableReviveLimit()
	aux.AddOrigEvoluteType(c)
   aux.AddEvoluteProc(c,nil,5,aux.FilterBoolFunction(Card.IsSetCard,0xab5),2)
end

