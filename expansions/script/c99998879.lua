--created by Walrus
--Voidictator Rune - Execution of the Divine
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only use 1 effect of "Voidictator Rune - Execution of the Divine" per turn, and only once that turn. If you control a face-up "Voidictator Demon - Guardian of Corvus": Banish as many random face-down cards from your opponent's Extra Deck, face-down, up to the number of "Voidictator" cards with different names among your banished cards (or their entire Extra Deck, if less than that number), and if you do, 1 "Voidictator Demon - Guardian of Corvus" you control gains 800 ATK/DEF for each card banished by this effect. If you banished 10 or more cards by this effect, halve your opponent's LP. You cannot conduct your Battle Phase during the turn you activate this effect. If this card is banished by a "Voidictator" card you own: You can target 1 face-up "Voidictator Demon - Guardian of Corvus" you control; its ATK/DEF becomes 0, and if it does so by this effect, gain LP equal to that lost DEF, then inflict damage to your opponent equal to half of that lost ATK.
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
