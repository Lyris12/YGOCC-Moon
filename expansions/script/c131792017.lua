--created by LeonDuvall
--Magitate Flux
local s,id,o=GetID()
function s.initial_effect(c)
	--When this card is activated: You can Special Summon 1 "Magitate" monster from your hand. If a "Magitate" monster is banished from your GY: You can send 1 "Concentrated Magitate" monster from your Extra Deck to the GY. If this card is destroyed by your opponent's card effect: You can banish this card from your GY; add 1 "Magitate" card from your Deck to your hand. You can only activate 1 "Magitate Flux" per turn.
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
