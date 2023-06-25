--created by LeonDuvall
--Primordial Singularity
local s,id,o=GetID()
function s.initial_effect(c)
	--Shuffle 1 banished "Helios - The Primordial Sun", "Helios Duo Megistus", and "Helios Thrice Megistus" into the Deck; Shuffle all banished cards into the Deck(s), also destroy all cards on the field, except "Macro Cosmos". If this card is banished, except the turn it was banished: you can shuffle this card into the Deck; Set 1 Spell/Trap which specifically lists "Helios - The Primordial Sun" directly from your Deck, then, if you control "Macro Cosmos", it can be activated this turn. You can only use each effect of "Primordial Singularity" once per turn.
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
