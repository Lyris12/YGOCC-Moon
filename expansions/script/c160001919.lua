--Seavinoli
function c160001919.initial_effect(c)
		--link summon
	aux.AddLinkProcedure(c,c160001919.matfilter,4,4)
	c:EnableReviveLimit()
end


function c160001919.matfilter(c)
	return not c:IsLinkType(TYPE_TOKEN)
end