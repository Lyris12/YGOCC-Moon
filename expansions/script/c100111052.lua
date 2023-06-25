--created by Jake
--Stopwatch Knight
local s,id,o=GetID()
function s.initial_effect(c)
	--The ATK of this card is the turn count x300. Once per turn, if the turn count changes (Quick Effect): You can target 1 monster you control; until the end of this turn, it gains ATK equal to its Level x100. If this card is sent to the GY: You can target 1 Cyberse monster in your GY, except a Link Monster; add it to your hand, and if you do, increase the turn count by that monsters original Level. You can only use each effect of "Stopwatch Knight" once per turn.
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
