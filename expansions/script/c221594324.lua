--created by Walrus
--Voidictator Demon - Paladin of Corvus
local s,id,o=GetID()
function s.initial_effect(c)
	--10+ banished cards, including at least 5 face-up banished cards - 1 "Voidictator Servant" monster / You can only control 1 "Voidictator Demon - Paladin of Corvus". Three times per turn, if your opponent Special Summons a Time Leap Monster: This card gains that monster's effects until the end of the next turn. You can only use the following effects of "Voidictator Demon - Paladin of Corvus" once per turn. If this card is Time Leap Summoned: You can add 2 "Voidictator Servant" monsters with different names from your Deck to your hand. If this card leaves the field due to an opponent's card, or if this card is banished because of a "Voidictator" card you own: Return this card to the Extra Deck, then, during your next Draw Phase, draw 3 cards instead of 1 for your normal draw.
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
