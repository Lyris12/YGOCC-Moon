--Paintress Seiu
local cid,id=GetID()
function cid.initial_effect(c)
c:EnableReviveLimit()
       aux.AddOrigEvoluteType(c)
     aux.AddEvoluteProc(c,nil,7,aux.TRUE,2,function(ec,tp,g) return g:FilterCount(cid.filter3,nil)==1 end)
end


function cid.filter3(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_DARK)
end