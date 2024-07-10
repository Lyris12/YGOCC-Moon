--[[
Automatyrant Recall
Automatiranno Richiamo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Activate 1 of the following effects.
	● Shuffle as many of your face-up banished "Automatyrant" cards, Equip Spell Cards, and Machine Union monsters into the Deck as possible, then send the top 3 cards of your Deck to the GY.
	● Target 5 cards in your GY (any combination of "Automatyrant" cards, Machine Union monsters, and/or Equip Spells); shuffle those targets into the Deck, then draw 2 cards.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is sent from your hand or Deck to the GY: You can send the top 3 cards of your Deck to the GY, and if you do, shuffle this card into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.tdcon,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e2)
end
s.has_text_type=TYPE_UNION

--E1
function s.tdfilter(c)
	return c:IsFaceup() and (c:IsSetCard(ARCHE_AUTOMATYRANT) or c:IsSpell(TYPE_EQUIP) or (c:IsMonster(TYPE_UNION) and c:IsRace(RACE_MACHINE))) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	local b1=Duel.IsExists(true,s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) and Duel.IsPlayerCanDiscardDeck(tp,3)
	local b2=Duel.IsExists(true,s.tdfilter,tp,LOCATION_GRAVE,0,5,nil) and Duel.IsPlayerCanDraw(tp,2)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,1,b1,b2)
	if opt==0 then
		e:SetCategory(CATEGORY_TODECK|CATEGORY_DECKDES)
		e:SetProperty(0)
		local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
		Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
	elseif opt==1 then
		e:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local g=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_GRAVE,0,5,5,nil)
		Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
	Duel.SetTargetParam(opt)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if opt==0 then
		local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
		if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
			Duel.DiscardDeck(tp,3,REASON_EFFECT)
		end
	elseif opt==1 then
		local g=Duel.GetTargetCards():Filter(s.tdfilter,nil):Filter(Card.IsControler,nil,tp)
		if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
			Duel.BreakEffect()
			Duel.Draw(tp,2,REASON_EFFECT)
		end
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