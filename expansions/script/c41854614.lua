--created by Swag
--Slumber, Deep in the Dreary Forest's Cradle
local s,id,o=GetID()
function s.initial_effect(c)
	--During your opponent's turn, if you control a "Dreary Forest" monster: Target up to 3 cards in your opponent's GY; banish them. You can banish this card from your GY; set 1 "Dreary Forest" Trap from your hand. It can be activated this turn. You can only use each of the previous effects of "Slumber, Deep in the Dreary Forest's Cradle" once per turn. During the turn a "Dreamy Forest" or "Dreary Forest" monster you control transformed, you can activate this card from your hand.
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
