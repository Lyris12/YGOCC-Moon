--Sword Whipper
function c160001231.initial_effect(c)
  --link summon
	aux.AddLinkProcedure(c,c160001231.mfilter,2)
	c:EnableReviveLimit()  
end
function c160001231.mfilter(c)
	return  not c:IsLinkType(TYPE_EFFECT)
end