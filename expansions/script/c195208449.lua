--created by Seth
--Mextro Pistis Sophia
local s,id,o=GetID()
function s.initial_effect(c)
	--5 co-linked "Mextro" monsters Unaffected by your opponent's card effects. If this card is Link Summoned: Draw 2 cards. Level 8 or lower monsters your opponent controls cannot declare an attack. When your opponent activates a card or effect which would destroy a "Mextro" card(s) you control or add a card from the Deck to their hand (Quick Effect): You can negate the activation. If this card leaves the field: Special Summon 1 Link-3 or lower "Mextro" monster from your GY. You can only use each effect of "Mextro Pistis Sophia" once per turn.
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
