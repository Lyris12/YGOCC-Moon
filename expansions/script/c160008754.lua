--Guren Valkyria
function c160008754.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c160008754.matfilter,1)	
end

function c160008754.matfilter(c)
	return c:IsLevel(1)
end