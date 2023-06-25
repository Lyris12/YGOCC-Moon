--created by Walrus
--Voidictator Deity - Vera the Grand Judge
local s,id,o=GetID()
function s.initial_effect(c)
	--1 DARK Fiend Tuner + 1+ non-Tuner "Voidictator" monsters / You can only control 1 "Voidictator Deity - Vera the Grand Judge". You can only use the 1 and 3 effects of "Voidictator Deity - Vera the Grand Judge" once per turn. 1 If this card is Synchro Summoned: You can destroy 1 card your opponent controls, and if you do, your opponent cannot activate cards or effects with that same name until the end of the next turn. 2 Up to thrice per turn, if your opponent Special Summons a Synchro Monster: This card gains that monster's effects until the end of the next turn. 3 If this card leaves the field due to an opponent's card, or if this card is banished because of a "Voidictator" card you own: Return this card to the Extra Deck, then, you can banish up to 3 "Voidictator" cards from your hand or GY.
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
