--Fairy Attack Force
function c160002329.initial_effect(c)
	c:EnableReviveLimit()
	  --synchro summon
	aux.AddOrigEvoluteType(c)
   aux.AddEvoluteProc(c,nil,1,aux.TRUE,1,1)
end

