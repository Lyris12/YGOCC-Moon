--created by Jake
--Essence Synthesizer
local s,id,o=GetID()
function s.initial_effect(c)
	--2 monsters, including at least 1 Positive or Negative monster Monsters on the field lose ATK/DEF (whichever is higher) equal to half their original ATK/DEF (whichever is lower). If a Neutral monster is Special Summoned to a zone this card points to (Quick Effect): You can target 1 face-up Positive or Negative monster your opponent controls; negate its effects until the end of this turn, and if you do, make its ATK/DEF equal to the lowest original ATK/DEF on the field. You can only use this effect of "Essence Synthesizer" once per turn.
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
