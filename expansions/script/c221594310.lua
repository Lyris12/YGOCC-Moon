--created by Walrus
--Voidictator Rune - Guiding Eulogy
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only activate 1 "Voidictator Rune - Raging Flames" per turn. 1 If you control a "Voidictator Demon" monster: Activate as Chain Link 4 or higher; negate the activation of your opponent's cards and effects before this card in this Chain, and if you do, shuffle the negated cards on the field, in the GY, and among your opponent's banished cards into the Deck. If you control a "Voidictator Demon - The Unending Flame", attach those negated cards to it as materials, instead. Your opponent cannot activate cards or effects in response to this effect's activation if you control a face-up "Voidictator Demon - The Unending Flame". 2 If this card is banished because of a "Voidictator" card you own: You can Tribute 1 "Voidictator Servant" monster from your hand or field; Set this card.
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
