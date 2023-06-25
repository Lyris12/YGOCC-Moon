--created by Walrus
--Voidictator Energy - Revolution Essence
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only control 1 "Voidictator Energy - Revolution Essence". You can only activate 1 "Voidictator Energy - Revolution Essence" per turn. 1 During your Main Phase: You can activate this effect; Special Summon 3 Level 4 "Voidictator Servant" monsters from your hand or GY, but their effects are negated, also shuffle them into the Deck when they leave the field. 2 Once per turn: You can banish 1 "Voidictator" monster from your GY, face-down; for the rest of this turn, you do not need to detach materials from "Voidictator" Xyz Monsters you control to activate their effects. 3 If this card is banished by a "Voidictator" card you own: Shuffle this card into the Deck, and if you do, banish 1 Set card your opponent controls.
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
