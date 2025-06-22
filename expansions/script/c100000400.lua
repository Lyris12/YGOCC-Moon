--[[
Unknown HERO Witness
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	aux.AddCodeList(c,id)
	--During your Main Phase, if this card is in your hand: You can reveal 1 "Unknown HERO" Ritual Monster in your hand; Special Summon this card, and if you do, you can Special Summon 1 Level 2 or lower "Unknown HERO" monster from your hand, Deck, or GY. You cannot Special Summon other monsters during the turn you activate this effect, except "HERO" monsters.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES|CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		aux.SSRestrictionCost(aux.ArchetypeFilter(ARCHE_HERO),true,nil,id,nil,1,true,
			aux.RevealCost(s.rvfilter,1,1,nil)
		),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)                                                          
	--If a "HERO" Ritual, Fusion, Synchro, Xyz, or Link Monster(s) is Special Summoned to your field while this card is in your GY (except during the Damage Step): You can send 1 "HERO" monster from your hand or Deck to the GY, except "Unknown HERO Witness", and if you do, and you sent an "Unknown HERO" monster to the GY this way, Special Summon this card from your GY, otherwise add this card to your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON|CATEGORY_TOHAND|CATEGORY_GRAVE_ACTION|CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetLabelObject(aux.AddThisCardInGraveAlreadyCheck(c))
	e2:HOPT()
	e2:SetFunctions(aux.AlreadyInRangeEventCondition(s.cfilter),nil,s.tgtg,s.tgop)
	c:RegisterEffect(e2)
end	
--E1
function s.rvfilter(c)
	return c:IsMonster(TYPE_RITUAL) and c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExists(false,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
			local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
			if tc then
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
		Duel.SpecialSummonComplete()
	end
end

--E2
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsMonster(TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK) and c:IsSetCard(ARCHE_HERO)
end
function s.tgfilter(c,spchk,thchk)
	return c:IsMonster() and c:IsSetCard(ARCHE_HERO) and not c:IsCode(id) and c:IsAbleToGrave()
		and ((spchk and c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO)) or (thchk and not c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO)))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local spchk=Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local thchk=c:IsAbleToHand()
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,spchk,thchk)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local spchk,thchk=true,true
	if c:IsRelateToChain() then
		spchk=Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		thchk=c:IsAbleToHand()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp,spchk,thchk)
	if #g>0 and Duel.SendtoGraveAndCheck(g) and c:IsRelateToChain() then
		local tc=Duel.GetGroupOperatedByThisEffect(e):GetFirst()
		if tc then
			local setc=tc:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO)
			if setc and Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
				Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
			elseif not setc then
				Duel.Search(c)
			end
		end
	end
end