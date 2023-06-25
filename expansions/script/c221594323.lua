--created by Walrus
--Voidictator Deity - Sauriel the Cosmic Arbiter
local s,id,o=GetID()
function s.initial_effect(c)
	--2 Level 8 or higher Neutral DARK Fiend monsters, including a "Voidictator" monster / You can only control 1 "Voidictator Deity - Sauriel the Cosmic Arbiter". Three times per turn, if your opponent Special Summons a Bigbang Monster: This card gains that monster's effects until the end of the next turn. You can only use the following effects of "Voidictator Deity - Sauriel the Cosmic Arbiter" once per turn. If this card is Bigbang Summoned: You can activate this effect; banish 1 random face-down card from your Extra Deck face-up, and if you do, this card gains ATK and DEF equal to that card's ATK. If this card leaves the field due to an opponent's card, or if this card is banished because of a "Voidictator" card you own: Return this card to the Extra Deck, then, you can inflict damage to your opponent equal to the highest ATK among monsters your opponent controls (your choice, if tied).
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
