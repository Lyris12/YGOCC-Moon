--created by LeonDuvall
--Exodice Phich
local s,id,o=GetID()
function s.initial_effect(c)
	--If this card leaves the field due to an opponent's card: Inflict 100 damage to your opponent, and if you do, Special Summon 1 "Exodice" monster from your Deck, except "Exodice Phich". If this card is Special Summoned from your Deck or GY: You can Tribute this card; Special Summon as many banished Level 3 or lower WATER Fish monsters as possible, and if you do, each player takes 100 damage for each, also, until the end of your next turn, you cannot Special Summon monsters, except WATER monsters. You can only use this effect of "Exodice Phich" once per turn.
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
