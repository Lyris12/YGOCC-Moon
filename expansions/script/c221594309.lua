--created by Walrus
--Voidictator Demon - The Unending Flame
local s,id,o=GetID()
function s.initial_effect(c)
	--2 Level 4 DARK Fiend monsters, including a "Voidictator" monster / You can only control 1 "Voidictator Demon - The Unending Flame". You can only use the 1 and 3 effects of "Voidictator Demon - The Unending Flame" once per turn. 1 If this card is Xyz Summoned: You can attach up to 5 banished cards to this card as material. This card's ATK become 400 x the number of materials attached to this card. 2 Up to thrice per turn, if your opponent Special Summons an Xyz Monster: This card gains that monster's effects until the end of the next turn. 3 If this card leaves the field due to an opponent's card, or if this card is banished because of a "Voidictator" card you own: Return this card to the Extra Deck, then, you can Special Summon 1 "Voidictator Servant" from your hand or GY.
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
