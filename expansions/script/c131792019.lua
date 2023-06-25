--created by LeonDuvall
--Magitate Detonation
local s,id,o=GetID()
function s.initial_effect(c)
	--If your opponent controls more monsters than you, you can ativate this card from your hand during your turn. When your opponent activates a card or effect while you control a Level 5 "Magitate" monster: You can banish 1 "Concentrated Magitate" card from your GY; negate the activation, and if you do, destroy that card. You can only activate 1 "Magitate Detonation" per turn.
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
