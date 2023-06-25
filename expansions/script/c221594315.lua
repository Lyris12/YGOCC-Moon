--created by Walrus
--Voidictator Rune - The Goddess's Wrath
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only use 1 effect of "Voidictator Rune - The Goddess's Wrath" per turn, and only once that turn. ① When your opponent Special Summons a monster from the Extra Deck, or when your opponent Special Summons a Ritual Monster, while you control a "Voidictator" monster: You can banish 3 "Voidictator" cards from your hand or GY; negate that Summon, and if you do, banish that monster face-down. If you control a "Voidictator Deity" or "Voidictator Demon" monster, your opponent cannot activate cards or effects in response to this card's activation. ② If this card is banished because of a "Voidictator" card you own: You can Tribute 1 "Voidictator Servant" monster you control; Set this card, but banish it face-down when it leaves the field.
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
