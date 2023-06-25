--created by LeonDuvall
--The Floating Village Atop Lake Exodice
local s,id,o=GetID()
function s.initial_effect(c)
	--Level 3 or lower WATER Fish monsters you control gain 100 DEF for each Level 3 or lower WATER Fish monster in your GY or that is banished. The first time each turn your opponent activates a card or effect in response to the effect of a Fish monster that was activated in the GY, negate the activation. If this card is activated: You can Special Summon 1 "Exodice" monster from your hand or GY, and if you do, if it is your opponent's turn, draw 1 card. You can only activate 1 "The Floating Village Atop Lake Exodice" per turn.
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
