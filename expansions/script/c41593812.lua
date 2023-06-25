--created by LeonDuvall
--Skypiercer Blitzkrieg
local s,id,o=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Skypiercer" monster from your hand, and if you do, it gains 1000 ATK. You can banish this card from your GY; Special Summon 1 "Skypiercer" monster from your Deck. You can only use this effect of "Skypiercer Blitzkrieg" once per turn. You cannot Normal or Special Summoned monsters the turn you use either of this card's effects, except WIND Machine monsters.
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
