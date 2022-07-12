--Paintress Seiu
local s,id=GetID()
function s.initial_effect(c)
c:EnableReviveLimit()
	   aux.AddOrigEvoluteType(c)
	 aux.AddEvoluteProc(c,nil,7,aux.TRUE,2,function(ec,tp,g) return g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK) end)
end
