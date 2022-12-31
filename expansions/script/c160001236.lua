--Electrical Socket
function c160001236.initial_effect(c)
  --link summon
	aux.AddLinkProcedure(c,c160001236.mfilter,3)
	c:EnableReviveLimit()  
end
function c160001236.mfilter(c)
	return  not c:IsLinkType(TYPE_EFFECT)
end