--created by Jake
--Emerald Veins Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	--If this card is in your hand: You can pay half your LP, then target 1 Level 5 or lower Dragon monster you control; Special Summon this card, and if that target was a Normal Monster, you can make this cards Level become reduced by the targets Level until the end of this turn, but banish both this card and the target if either the field. You can only Special Summon Dragon monsters during the turn you activate this effect. You can only use the effect of "Emerald Veins Dragon" once per Duel.
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
