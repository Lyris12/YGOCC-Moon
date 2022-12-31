--Pink Magician Gal
function c160001239.initial_effect(c)
  --link summon
	aux.AddLinkProcedure(c,c160001239.mfilter,2)
	c:EnableReviveLimit()
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c160001239.rmtarget)
	e2:SetTargetRange(0xff,0xff)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(160001239)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTargetRange(0xff,0xff)
	e3:SetTarget(c160001239.checktg)
	c:RegisterEffect(e3)  
end
function c160001239.mfilter(c)
	return  not c:IsLinkType(TYPE_EFFECT)
end
function c160001239.rmtarget(e,c)
	return c:IsSetCard(0xc50) and not c:IsLocation(LOCATION_PZONE)
end
function c160001239.checktg(e,c)
	return not c:IsPublic()
end

