local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,s.mfilter,4,3)
	c:EnableReviveLimit()  

end
function s.mfilter(c)
	return not c:IsType(TYPE_EFFECT)
end
