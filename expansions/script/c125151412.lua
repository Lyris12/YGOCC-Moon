--created by LeonDuvall
--Exodicey Gourmet Fusion
local s,id,o=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Fish Fusion Monster from your Extra Deck, by banishing Fusion Materials listed on it from your field or GY. During your Main Phase, if this card is in your GY, except the turn this card was sent to the GY: You can target 5 banished Fish monsters; shuffle them into the Deck, and if you do, draw 1 card, then inflict 100 damage to your opponent, and if you do, place this card on the bottom of the Deck. You can only use this effect of "Exodicey Gourmet Fusion" once per turn.
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
