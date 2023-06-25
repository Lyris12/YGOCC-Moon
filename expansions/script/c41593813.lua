--created by LeonDuvall
--Skypiercer Air Superiority
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate 1 of the following effects. ● If you control no monsters OR if you control "Skypiercer Airfield": Special Summon 1 "Skypiercer" monster from your Deck. ● If you control a "Skypiercer" Xyz monster: Destroy 1 card your opponent controls. If you control a "Skypiercer" monster: You can banish this card from your GY; draw 1 card. You can only activate 1 "Skypiercer Air Superiority" once per turn. You cannot Special Summon monsters the turn you use any of this card's effects, except WIND Machine mosnters.
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
