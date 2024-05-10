--created by LeonDuvall
--The Legendary Fisherman of Lake Exodice
local s,id,o=GetID()
function s.initial_effect(c)
	--3+ Level 3 or lower Fish monsters If this card is Fusion Summoned: You can target any number of banished Fish monsters; shuffle them into the Deck, and if you do, inflict 100 damage to your opponent for each, then, if you shuffled 5 or more cards into the Deck, add 1 WATER Fish monster from your Deck to your hand. If this card leaves the field due to an opponent's card: You can Special Summon 1 WATER Fish Synchro monster from your Extra Deck (This is treated as a Synchro Summon.) You can only use each effect of "The Legendary Fisherman of Lake Exodice" once per turn.
	local tp=c:GetControler()
	local ef=Effect.CreateEffect(c)
	ef:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ef:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	ef:SetCountLimit(1,5001+EFFECT_COUNT_CODE_DUEL)
	ef:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	ef:SetOperation(function()
		local tk=Duel.CreateToken(tp,5000)
		Duel.SendtoDeck(tk,nil,SEQ_DECKBOTTOM,REASON_RULE)
		c5000.ops(ef,tp)
	end)
	Duel.RegisterEffect(ef,tp)
end
