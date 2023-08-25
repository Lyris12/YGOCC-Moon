--created by LeonDuvall, coded by Lyris
--The Reforged Cosmos
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,54493213)
	aux.EnableChangeCode(c,30241314,LOCATION_SZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(0xff,0xff)
	e2:SetCondition(s.condition)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp)
	return c:IsCode(54493213) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	if #g==0 or not Duel.SelectEffectYesNo(tp,c) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.limit(e,c,sp,st,spos,tp,se)
	return not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_PYRO))
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(54493213,80887952)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
