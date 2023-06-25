--created by Jake
--Overload Artificial Intelligence
local s,id,o=GetID()
function s.initial_effect(c)
	--Machine monsters cannot be targeted by your opponents card effects during the turn they are Summoned. Monsters equipped to Machine monsters cannot attack or activate their effects the turn they are Summoned, except Machine monsters. Once per turn: You can target 1 monster on the field; equip 1 Machine monster from your hand to that target. If 2+ Machine monsters are Summoned or leave the field at the same time: destroy this card. You can only activate 1 "Overload Artificial Intelligence" per turn.
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
