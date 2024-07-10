--[[
Automatyrant Activation
Automatiranno Attivazione
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Special Summon 1 Level 5 or lower "Automatyrant" monster from your hand, Deck, or GY.
	You cannot Special Summon monsters from the Extra Deck during the turn you activate this effect, except Machine monsters.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,s.cost,s.target,s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	--[[If this card is sent from your hand or Deck to the GY: You can send the top 3 cards of your Deck to the GY, and if you do, shuffle this card into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.tdcon,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e2)
end
function s.counterfilter(c)
	return c:IsRace(RACE_MACHINE) or not c:IsSummonLocation(LOCATION_EXTRA)
end

--E1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(id,1)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_OATH|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_MACHINE)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_AUTOMATYRANT) and c:HasLevel() and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_HAND|LOCATION_DECK)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeck() and Duel.IsPlayerCanDiscardDeck(tp,3)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,3,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() then
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end