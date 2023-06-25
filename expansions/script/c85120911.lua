--created by LeonDuvall
--Praise the Immortal Sun
local s,id,o=GetID()
function s.initial_effect(c)
	--When your opponent activates a card or effect while you control "Helios - The Primordial Sun" and "Macro Cosmos": Negate the activation, and if you do, destroy it. While this card is banished, except the turn it was banished: You can shuffle this card into the Deck; Set 1 Spell/Trap which specifically lists "Helios - The Primordial Sun" directly from your Deck, except "Praise the Immortal Sun". You can only activate 1 "Praise the Immortal Sun" per turn.
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
