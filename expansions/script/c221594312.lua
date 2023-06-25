--created by Walrus
--Voidictator Rune - Final Verdict
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only use 1 effect of "Voidictator Rune - Final Verdict" per turn, and only once per turn. You can only activate this card while you control a face-up "Voidictator" card. 1 Banish 1 face-up card your opponent controls, or, if you control a face-up "Voidictator Deity - Vera the Grand Judge", banish up to 3 cards your opponent controls. Your opponent cannot activate cards or effects in response to this effect's activation if you control a face-up "Voidictator Deity - Vera the Grand Judge". 2 If this card is banished because of a "Voidictator" card you own: You can Tribute 1 "Voidictator Servant" monster from your hand or field; Set this card.
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
