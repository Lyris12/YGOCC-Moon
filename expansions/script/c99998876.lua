--created by Walrus
--Voidictator Rune - Energy Renewal
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only use the 2 effect of "Voidictator Rune - Energy Renewal" once per turn. 1 Activate 1 of the following effects (but you cannot activate that same effect of "Voidictator Rune - Energy Renewal" again this turn): ● Add 1 "Voidictator Energy" card from your Deck to your hand. ● Return 1 of your banished "Voidictator Energy" cards to the GY. ● Banish 1 "Voidictator Energy" card from your GY. 2 If this card is banished because of a "Voidictator" card you own: You can activate this effect; add 1 of your banished "Voidictator" cards to your hand, except "Voidictator Rune - Energy Renewal".
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
