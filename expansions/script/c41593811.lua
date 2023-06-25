--created by LeonDuvall
--Skypiercer Tactical Strike
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects. ● If you control no monsters OR you control "Skypiercer Airfield": Special Summon 1 "Skypiercer" monster from your hand or GY, and if you do, it gains 1000 DEF. ● If you control a Level/Rank 5 "Skypiercer" monster: Target 1 card your opponent controls: negate its effects, and if you do, destroy it. If you control a "Skypiercer" monster: You can discard 1 card; add this card from your GY to your hand. You can only use each effect of "Skypiercer Tactical Strike" once per turn. You cannot Special Summon monsters the turn you use any of this card's effects, except WIND Machine monsters.
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
