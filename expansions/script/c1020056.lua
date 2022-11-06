--Leggenda Bushido Cerbero
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x4b0),2)
	c:SetSummonLimit(SUMMON_TYPE_LINK)
	--protection
	c:UnaffectedProtection(s.efilter)
	--destroy
	c:Quick(false,0,CATEGORY_DESTROY,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET,nil,LOCATION_MZONE,1,
		nil,
		aux.AttackRestrictionCost(nil,nil,1),
		aux.Target(s.filter,LOCATION_MZONE,LOCATION_MZONE,2,2,nil,nil,CATEGORY_DESTROY),
		aux.DestroyOperation(SUBJECT_THEM)
	)
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and (tc:IsSummonType(SUMMON_TYPE_SPECIAL) or te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL))
end

function s.filter(c,e)
	return c:IsInLinkedZone(e:GetHandler())
end