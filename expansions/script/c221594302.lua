--created by Walrus
--Voidictator Servant - Gate Architect
local s,id,o=GetID()
function s.initial_effect(c)
	--1 While this card and "Voidictator Servant - Gate Sorceress" are in your Pendulum Zones while you control a "Voidictator Deity" or "Voidictator Demon" monster, the effects of all cards in your opponent's Pendulum Zones, and the effects of all Pendulum Monsters they control, are negated. 2 Once per turn: You can banish up to 3 "Voidictator" cards from your GY; shuffle that many cards from your hand or field into the Deck -1, and if you do, draw cards equal to the number of cards shuffled into the Deck this way. This card cannot be used as a material for the Summon of a monster from the Extra Deck while it is on the field. This effect cannot be negated. You can only use each effect of "Voidictator Servant - Gate Architect" once per turn. 1 You can Special Summon this card (from your hand or face-up from your Extra Deck) by Tributing 1 "Voidictator Servant" monster you control. 2 If this card is Normal or Special Summoned: You can shuffle 3 of your banished cards into the Deck. 3 If this card is banished because of a "Voidictator" card you own: You can either place this card in your Pendulum Zone, OR; shuffle this card into the Deck.
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
