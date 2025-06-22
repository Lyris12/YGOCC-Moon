--[[
Unknown HERO Ambush
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	--Special Summon 1 "Unknown HERO" monster from your hand or GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--If this Set card in its owner's control is destroyed by an opponent's card effect: You can Special Summon 2 "HERO" monsters from your hand or GY with different original names (including at least 1 "Unknown HERO" monster), and if you do, they gain 500 ATK/DEF until the end of the turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SHOPT()
	e2:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
	--If this card is in your GY: You can target 1 "HERO" monster or "Fusion" Spell in your GY; shuffle both it and this card into the Deck, then draw 1 card.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetRelevantTimings()
	e3:SHOPT()
	e3:SetFunctions(nil,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e3)
end

--E1
function s.spfilter(c,e,tp)
	return c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=c:GetOwner()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousControler(p) and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(ARCHE_HERO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfirst(c)
	return c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp)
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetMZoneCount(tp)>=2
			and xgl.SelectUnselectGroup(0,g,e,tp,2,2,xgl.ogdncheck,0,nil,nil,nil,nil,nil,s.spfirst)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,2,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,nil,2,tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetMZoneCount(tp)<2 then return end
	local g=Duel.GetMatchingGroup(aux.Necro(s.spfilter2),tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp)
	if #g<2 then return end
	local sg=xgl.SelectUnselectGroup(0,g,e,tp,2,2,xgl.ogdncheck,1,tp,HINTMSG_SPSUMMON,nil,nil,nil,s.spfirst)
	if #sg~=2 then return end
	local c=e:GetHandler()
	for sc in aux.Next(sg) do
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			sc:UpdateATKDEF(500,500,RESET_PHASE|PHASE_END,{c,true})
		end
	end
	Duel.SpecialSummonComplete()
end

--E3
function s.tdfilter(c)
	return ((c:IsMonster() and c:IsSetCard(ARCHE_HERO)) or (c:IsSpell() and c:IsSetCard(ARCHE_FUSION))) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.tdfilter(chkc) end
	if chk==0 then return c:IsAbleToDeck()
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,c) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() then
		local g=Group.FromCards(c,tc)
		if Duel.ShuffleIntoDeck(g)==2 then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end