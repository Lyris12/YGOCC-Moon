--created by LeonDuvall
--Cosmic Conversion
local s,id,o=GetID()
function s.initial_effect(c)
	--If you control "Macro Cosmos" or "Helios - The Primordial Sun": Target 1 card your opponent controls; banish it. If this card is banished while you control "Helios - The Primordial Sun": You can add 1 card which specifically lists "Helios - The Primrodial Sun" from your Deck to your hand, except "Cosmic Conversion". You can only activate 1 "Cosmic Conversion" per turn.
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
