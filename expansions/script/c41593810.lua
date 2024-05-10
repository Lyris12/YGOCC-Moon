--created by LeonDuvall
--Skypiercer Airfield
local s,id,o=GetID()
function s.initial_effect(c)
	--If a "Skypiercer" monster you control attacks a Defense Position monster, inflict piercing battle damage to your opponent. "Skypiercer" monsters you control gain 500 ATK. Cannot be targeted or destroyed by your opponent's card effects while you control a "Skypiercer" monster. Once per turn: You can return 1 banished "Skypiercer" card to the GY; excavate the top 3 cards of your Deck, add 1 excavated "Skypiercer" card to your hand, and if you do, send the rest to the GY, otherwise, shuffle them into the Deck. You can only activate 1 "Skypiercer Airfield" per turn.
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
