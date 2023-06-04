--created by Lyris, art by httydquackson.fl of Instagram
--European Voice Accent Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	--2 LIGHT monsters If a card or effect, with a different name than this card's Accented Materials, would resolve while it is banished, negate that effect. When a Level 5 or higher monster your opponent controls activates its effect (Quick Effect): You can activate this effect; the activated effect becomes "For the rest of this turn, neither player takes damage if the amount is less than or equal to this card's current ATK or DEF (whichever is higher).". You can only use each effect of "European Voice Accent Dragon" once per turn.
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
