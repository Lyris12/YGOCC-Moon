--created by Swag
--The Surprises of the Dreamy Forest
local s,id,o=GetID()
function s.initial_effect(c)
	--During your turn, if you control a "Dreamy Forest" monster: Target up to 2 Spells/Traps your opponent controls; return them to the hand. Your opponent cannot activate the targeted cards in response to this card's activation. If this card is in the GY, except during the turn it was sent there: You can banish this card from your GY, then target 3 "Dreamy Forest" and/or "Dreary Forest" cards with different names in your GY; shuffle them into the Deck, and if you do, draw 1 card. You can only use each effect of "The Surprises of the Dreamy Forest" once per turn.
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
