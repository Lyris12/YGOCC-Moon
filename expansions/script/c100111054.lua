--created by Jake
--Crush Cyberse Virus
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate only while you control only Link Monsters. Banish 1 Link Monster you control or in your GY; destroy all Link Monsters your opponent controls whose LINK is higher than that banished monster's, and if you do, your opponent must send 1 Link Monster from their Extra Deck to the GY for each monster destroyed by this effect with higher original ATK than the ATK of the banished monsters (if able). You can only activate "Crush Cyberse Virus" once per turn.
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
