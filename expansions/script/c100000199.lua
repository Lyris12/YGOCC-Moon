--[[
Golden Skies - Thanis the Gloryblade
Cielodorato - Thanis la Lamagloria
Card Author: Zerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2,2,s.lcheck)
	--[[If this card is Link Summoned: You can shuffle as many "Golden Skies Treasure" from your GY into the Deck as possible (min. 1),
	and if you do, you can send 1 "Golden Skies Treasure" from your Deck to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.LinkSummonedCond,nil,s.tgtg,s.tgop)
	c:RegisterEffect(e1)
	--[[During the Main Phase, if you have a "Golden Skies Treasure" in your GY: You can Special Summon 1 "Golden Skies" monster from your hand or GY.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(aux.FilterBoolFunction(Card.IsCode,CARD_GOLDEN_SKIES_TREASURE),LOCATION_GRAVE,0,1),
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
	--[[If this card is used as Fusion Material for the Summon of a "Golden Skies" Fusion Monster: You can Set 1 "Golden Skies" Spell from your Deck.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:HOPT()
	e3:SetFunctions(s.setcon,nil,s.settg,s.setop)
	c:RegisterEffect(e3)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,ARCHE_GOLDEN_SKIES)
end

--E1
function s.tdfilter(c,f)
	return c:IsCode(CARD_GOLDEN_SKIES_TREASURE) and f(c)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.tdfilter,tp,LOCATION_GRAVE,0,1,nil,Card.IsAbleToDeck) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(aux.Necro(s.tdfilter),tp,LOCATION_GRAVE,0,nil,Card.IsAbleToDeck)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 and Duel.IsExists(false,s.tdfilter,tp,LOCATION_DECK,0,1,nil,Card.IsAbleToGrave) and Duel.SelectYesNo(tp,STRING_ASK_TO_GY) then
		local tc=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tdfilter,tp,LOCATION_DECK,0,1,1,nil,Card.IsAbleToGrave):GetFirst()
		if tc then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end

--E2
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_GOLDEN_SKIES) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--e3
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return rc:IsType(TYPE_FUSION) and rc:IsSetCard(ARCHE_GOLDEN_SKIES)
end
function s.setfilter(c)
	return c:IsSetCard(ARCHE_GOLDEN_SKIES) and c:IsSpell() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end