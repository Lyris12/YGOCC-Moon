--created by LeonDuvall
--Helios - Majesty of Dawn
local s,id,o=GetID()
function s.initial_effect(c)
	--This card's ATK/DEF are equal to the number of banished cards x 100. This card's name becomes "Helios - The Primordial Sun" while in the hand, on the field or banished. You can banish 1 "Spark of the Primordial Sun" you control; Special Summon this card from your hand. If this card is Tributed or banished: You can Special Summon 1 "Helios Duo Megistus" from your Deck, ignoring its Summoning conditions. You can only use this effect of "Helios - Majesty of Dawn" once per turn.
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
