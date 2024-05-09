--created by LeonDuvall, coded by Lyris, fixed by XGlitchy30
--The Reforged Cosmos
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MACRO_COSMOS,CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_HELIOS_DUO_MEGISTUS)
	aux.EnableChangeCode(c,CARD_MACRO_COSMOS,LOCATION_SZONE|LOCATION_GRAVE|LOCATION_REMOVED)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_IGNORE_RANGE|EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0xff,0xff)
	e2:SetCondition(s.condition)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp)
	return c:IsCode(CARD_HELIOS_THE_PRIMORDIAL_SUN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_HAND)
end
function s.activate(e,tp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK|LOCATION_HAND,0,nil,e,tp)
	if #g==0 or not Duel.SelectEffectYesNo(tp,c) then return end
	Duel.HintMessage(tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(c)
	e1:Desc(1,id)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.limit(e,c,sp,st,spos,tp,se)
	return not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_PYRO))
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_HELIOS_DUO_MEGISTUS)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
