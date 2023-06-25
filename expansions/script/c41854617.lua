--created by Swag
--Safety, Deep in the Dreary Forest's Lies
local s,id,o=GetID()
function s.initial_effect(c)
	--During your opponent's turn, when your opponent activates a card or effect while you control a "Dreary Forest" monster: You can send 1 other card from your hand or field to the GY; negate the activation, and if you do, banish that card. If a "Dreamy Forest" or "Dreary Forest" monster you control would be destroyed by battle or card effect, you can banish this card from your GY instead. You can only use each effect of "Safety, Deep in the Dreary Forest's Lies" once per turn.
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
