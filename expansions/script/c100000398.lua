--[[
Unknown HERO Ghost
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	-- If this card is Normal or Special Summoned: You can target 1 of your banished "HERO" monsters; shuffle it into the Deck, and if you do, and you shuffled an "Unknown HERO" monster into the Deck this way, draw 1 card.
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(id,0)
	e0:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:HOPT()
	e0:SetFunctions(nil,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e0)
	e0:SpecialSummonEventClone(c)
	--If you Ritual or Synchro Summon an "Unknown HERO" monster(s) while this card is in your GY (except during the Damage Step): You can add 1 "Unknown HERO" card from your Deck to your hand, except "Unknown HERO Ghost", and if you do, place this card on the bottom of your Deck.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetLabelObject(aux.AddThisCardInGraveAlreadyCheck(c))
	e1:HOPT()
	e1:SetFunctions(aux.AlreadyInRangeEventCondition(s.cfilter),nil,s.thtg,s.thop)
	c:RegisterEffect(e1)
end	
--E0
function s.tdfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_HERO) and c:IsAbleToDeck()
end
function s.tdfilter2(c)
	return c:IsMonster() and c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExists(true,s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	local tc=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil):GetFirst()
	Duel.SetCardOperationInfo(tc,CATEGORY_TODECK)
	Duel.SetConditionalOperationInfo(s.tdfilter2(tc),0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.ShuffleIntoDeck(tc)>0 and aux.BecauseOfThisEffect(e)(tc) and s.tdfilter2(tc) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

--E1
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO) and c:IsSummonPlayer(tp) and (c:IsSummonType(SUMMON_TYPE_RITUAL) or c:IsSummonType(SUMMON_TYPE_SYNCHRO))
end
function s.thfilter(c)
	return c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.Select(HINTMSG_TOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.DisableShuffleCheck()
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
			Duel.ShuffleDeck(tp)
			if tc:IsControler(tp) and tc:IsLocation(LOCATION_HAND) then
				local c=e:GetHandler()
				if c:IsRelateToChain() then
					Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
				end
			end
		end
	end
end