--created by LeonDuvall
--Skypiercer Zeppelin
local s,id,o=GetID()
function s.initial_effect(c)
	--2 WIND Machine monsters If this card is targeted for an attack or by a card effect (Quick Effect): Destroy this card and that card. You can target 2 WIND Machine monsters in your GY; Special Summon them, and if you do, their Levels become equal to their combined original Levels, but negate their effects, then, immediately after this effect resolves, Xyz Summon 1 WIND Machine Xyz Monster using those 2 monsters only, also, for the rest of this turn you cannot Special Summon monsters, except WIND Machine monsters. You can only use this effect of "Skypiercer Zeppelin" once per turn.
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
