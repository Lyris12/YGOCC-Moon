--created by Walrus
--Voidictator Rune - Gating Art
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate 1 of the following effects (but you cannot use that same effect of "Voidictator Rune - Gating Art" again this turn): ● Add 1 "Voidictator" monster from your Deck or GY to your hand. ● Special Summon 1 of your banished "Voidictator" monsters. ● Return 1 "Voidictator" monster you control to the hand. If this card is banished because of a "Voidictator" card you own: You can activate this effect; add 1 of your banished "Voidictator" cards to your hand, except "Voidictator Rune - Gating Art". You can only use this effect of "Voidictator Rune - Gating Art" once per turn.
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
