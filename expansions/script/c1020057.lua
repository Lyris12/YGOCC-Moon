--Leggenda Bushido Minotauro
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACES_BEASTS),2)
	--protection
	c:UnaffectedProtection(s.efilter)
	--chain limit
	c:ArmadesEffectField(BATTLE_TIMING_BATTLES,nil,LOCATION_MZONE,0,1,aux.Filter(Card.IsSetCard,0x4b0),
		aux.ThisCardPointsToCond(s.filter,1)
	)
	--SS
	c:SentToGYFieldTrigger(s.cfilter,false,0,CATEGORY_SPECIAL_SUMMON,true,LOCATION_MZONE,true,
		nil,
		nil,
		aux.SSToEitherFieldTarget(nil,LOCATION_HAND,0,1,nil,nil,nil,nil,nil,nil,aux.ZoneThisCardDoesNotPointTo(0),aux.ZoneThisCardDoesNotPointTo(1)),
		aux.SSToEitherFieldOperation(nil,LOCATION_HAND,0,1,1,nil,nil,nil,nil,nil,nil,aux.ZoneThisCardDoesNotPointTo(0),aux.ZoneThisCardDoesNotPointTo(1))
	)
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and (tc:IsSummonType(SUMMON_TYPE_SPECIAL) or te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL))
end

function s.filter(c,e,tp)
	return c:IsControler(tp) and c:IsInLinkedZone(e:GetHandler())
end

function s.cfilter(c,e)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousSetCard(0x4b0) and c:WasInLinkedZone(e:GetHandler())
end