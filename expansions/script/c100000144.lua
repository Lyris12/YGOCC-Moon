--[[
Sisters of Harmony
Sorelle dell'Armonia
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_BIGBANG),aux.FilterBoolFunction(Card.IsFusionType,TYPE_LINK),true)
	--[[If this card is Special Summoned: You can return to the Extra Deck, 1 "Keeper of Harmony" and 1 "Emissary of Harmony" from among your cards in your GY,
	and/or your face-up banished cards; shuffle up to 3 monsters with different Vibes from the field into the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,s.tdcost,s.tdtg,s.tdop)
	c:RegisterEffect(e1)
	--[[If you Synchro Summoned using this card as material: You can Special Summon 1 "Keeper of Harmony", or 1 "Emissary of Harmony", from your Extra Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:HOPT()
	e2:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c,tp,code)
	return c:IsFaceupEx() and c:IsCode(code) and c:IsAbleToExtraAsCost()
		and (not tp or Duel.IsExists(false,s.cfilter,tp,LOCATION_GB,0,1,c,nil,CARD_EMISSARY_OF_ARMONY))
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.cfilter,tp,LOCATION_GB,0,1,nil,tp,CARD_KEEPER_OF_ARMONY)
	end
	local g1=Duel.Select(HINTMSG_TODECK,false,tp,s.cfilter,tp,LOCATION_GB,0,1,1,nil,tp,CARD_KEEPER_OF_ARMONY)
	local g2=Duel.Select(HINTMSG_TODECK,false,tp,s.cfilter,tp,LOCATION_GB,0,1,1,g1,nil,CARD_EMISSARY_OF_ARMONY)
	g1:Merge(g2)
	if #g1>0 then
		Duel.HintSelection(g1)
		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.tdfilter(c)
	return c:IsFaceup() and c:HasVibe() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,PLAYER_ALL,LOCATION_MZONE)
end
function s.gcheck(g)
	return g:GetClassCount(Card.GetVibe)==#g
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g<=0 then return end
	Duel.HintMessage(tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,1,3,nil)
	if #sg>0 then
		Duel.HintSelection(sg)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_SYNCHRO~=0
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_KEEPER_OF_ARMONY,CARD_EMISSARY_OF_ARMONY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end