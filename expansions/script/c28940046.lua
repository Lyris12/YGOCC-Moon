--Astralost Twinglow
local ref,id=GetID()
Duel.LoadScript("Astralost.lua")
function ref.initial_effect(c)
	--Fusion
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,ref.matfilter,2,true)
	--Floodgate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetTarget(ref.actfilter)
	c:RegisterEffect(e1)

end
function ref.matfilter(c,fc,sub,mg,sg)
	return not sg or sg:FilterCount(aux.TRUE,c)==0
		or (sg:IsExists(Card.IsLevel,1,c,c:GetLevel())
			and not (sg:IsExists(Card.IsRace,1,c,c:GetRace()) or sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute())))
end

--Floodgate
function ref.actfilter(e,re,tp)
	local g=Duel.GetMatchingGroup(Astralost.Is,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttackBelow(g:GetMaxGroup(Card.GetAttack))
end
