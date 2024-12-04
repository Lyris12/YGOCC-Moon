--[[
Special Rule
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	if not s.global_check then
		s.global_check=true
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCountLimit(1,id|EFFECT_COUNT_CODE_DUEL)
		e1:SetOperation(s.regop)
		Duel.RegisterEffect(e1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Debug.Message('These starting hands will be reshuffled since a card must be added from outside the Decks.')
	Debug.Message('New hands will be generated so the added card has a chance to appear in them.')
	local hands=Duel.GetHand(0)+Duel.GetHand(1)
	Duel.SendtoDeck(hands,nil,SEQ_DECKSHUFFLE,REASON_RULE)
	Duel.DisableShuffleCheck(true)
	for p=0,1 do
		local g=Duel.Group(Card.IsOriginalCode,0,LOCATION_DECK,0,nil,id)
		if #g>0 then
			Duel.Exile(g,REASON_RULE)
		end
		if Duel.GetDeckCount(p)+Duel.GetHandCount(p)<40 then
			Debug.Message('Player '..p..' has less than 40 cards in their Main Deck. The Duel cannot proceed.')
			Duel.Win(1-p,WIN_REASON_EXODIA)
			return
		end
	end
	Duel.DisableShuffleCheck(false)
	
	--[[The effect of Convulsion of Nature and Ceremonial Bell remains active for the entire Duel]]
	Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REVERSE_DECK)
	e1:SetTargetRange(1,1)
	Duel.RegisterEffect(e1,0)
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_PUBLIC)
	e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	Duel.RegisterEffect(e2,0)
	
	--[[At the start of the Duel, spawn 1 copy "Gem-Knight Garnet" in each player's Deck.]]
	for p=0,1 do
		local garnet=Duel.CreateToken(p,91731841)
		Duel.SendtoDeck(garnet,nil,SEQ_DECKSHUFFLE,REASON_RULE)
		Duel.ConfirmCards(1-p,garnet)
		Duel.Draw(p,5,REASON_RULE)
	end
end