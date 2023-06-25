--created by LeonDuvall
--Spark of the Primordial Sun
local s,id,o=GetID()
function s.initial_effect(c)
	--If you control "Macro Cosmos", you can Special Summon this card (from your hand). Once per turn: You can excavate the top 5 cards of your Deck, add 1 "Helios - The Primordial Sun" or 1 card which specifically lists the card "Helios - The Primordial Sun" from among them to your hand, and if you do, banish the remaining cards and this card. Otherwise, shuffle your Deck. If you control "Helios - The Primordial Sun" or "Helios Duo Megistus": You can shuffle this banished card into the Deck; add 1 "Helios Thrice Megistus" from your Deck to your hand, and if you do, draw 1 card. You can only use each effect of "Spark of the Primordial Sun" once per turn.
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
