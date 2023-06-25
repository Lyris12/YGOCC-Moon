--created by Walrus
--Voidictator Energy - Origin Essence
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only control 1 "Voidictator Energy - Origin Essence". You can only activate 1 "Voidictator Energy - Origin Essence" per turn. 1 During your Main Phase: You can activate this effect; Fusion Summon 1 "Voidictator Deity" Fusion Monster from your Extra Deck, by using "Voidictator" monsters from your hand or field as materials. You can also banish 1 "Voidictator" monster from your GY as a material. 2 Once per turn: You can target 1 "Voidictator Servant" monster you control; until the End Phase, it is treated as a Tuner. 3 If this card is banished by a "Voidictator" card you own: Shuffle this card into the Deck, and if you do, banish 1 Set card your opponent controls.
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
