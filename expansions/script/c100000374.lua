--[[
Vacuous Null
Nullo Vacuo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 Level 1 monster
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLevel,1),1,1)
	--[[If this card is Link Summoned: You can add 1 "Power Vacuum Zone" from your Deck or GY to your hand, or if you control "Power Vacuum Zone", add 1 monster with 0 ATK and DEF from your Deck or GY
	to your hand, instead.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetFunctions(
		aux.LinkSummonedCond,
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e1)
	--[[During the Main Phase, if you control "Power Vacuum Zone" (Quick Effect): You can Tribute this card; Special Summon 2 monsters with 0 ATK/DEF from your hand and/or GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetHintTiming(TIMING_MAIN_END)
	e2:SetFunctions(s.spcon,aux.TributeSelfCost,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
--E1
function s.thfilter(c,check)
	if not c:IsAbleToHand() then return false end
	if not check then
		return c:IsCode(CARD_POWER_VACUUM_ZONE)
	else
		return c:IsMonster() and c:IsStats(0,0)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),tp,LOCATION_ONFIELD,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,check) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local check=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),tp,LOCATION_ONFIELD,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,check)
	if #g>0 then
		Duel.Search(g)
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsStats(0,0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local exc=e:IsCostChecked() and e:GetHandler() or nil
		return Duel.GetMZoneCount(tp,exc)>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,2,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.GetMZoneCount(tp)>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,2,2,nil,e,tp)
	if #g==2 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end