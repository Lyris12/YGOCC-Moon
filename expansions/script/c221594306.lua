--created by Walrus
--Voidictator Demon - The Gate Keeper
local s,id,o=GetID()
function s.initial_effect(c)
	--3 DARK Fiend monsters, including a "Voidictator" monster / You can only control 1 "Voidictator Demon - The Gate Keeper". You can only use the 1 and 3 effects of "Voidictator Demon - The Gate Keeper" once per turn. 1 If this card is Link Summoned: You can banish the top 5 cards of your Deck. 2 Up to thrice per turn, if your opponent Special Summons a Link Monster: This card gains that monster's effects until the end of the next turn. 3 If this card leaves the field due to an opponent's card, or if this card is banished because of a "Voidictator" card you own: Return this card to the Extra Deck, then, all "Voidictator" monsters you currently control gain 1000 ATK until the End Phase.
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
