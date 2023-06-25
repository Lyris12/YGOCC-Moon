--created by LeonDuvall
--Helios - Reformation of the Sun
local s,id,o=GetID()
function s.initial_effect(c)
	--You control "Macro Cosmos" - "Helios Trice Megistus" This card's name becomes "Helios - The Primordial Sun" while on the field, in the GY or banished. This effect cannot be negated. This card's original ATK and DEF are each equal to the number of banished cards x 700 This card can attack each monster your opponent controls, once each. If this card is destroyed or banished, by battle or card effect: Special Summon it, and if you do, it gains 700 ATK/DEF.
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
