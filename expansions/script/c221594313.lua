--created by Walrus
--Voidictator Rune - Chains of Torment
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only use each effect of "Voidictator Rune - Chains of Torment" once per turn. ① Activate this card only when a monster is Ritual Summoned or Summoned from the Extra Deck to your opponent's side of the field while you control a "Voidictator" monster. Equip this card to that monster. The equipped monster cannot attack, be Tributed, or used as a material for the Summon of a monster from the Extra Deck, also its ATK and DEF become 0. ② If this card is banished because of a "Voidictator" card you own: You can send the top 5 cards of your Deck to the GY, and if you do, place this card on the top of your Deck.
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
