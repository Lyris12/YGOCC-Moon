--created by LeonDuvall
--Skypiercer Ingenieurkorps
local s,id,o=GetID()
function s.initial_effect(c)
	--Add 1 "Skypiercer" card from your Deck to your hand, except "Skypiercer Ingenieurkorps", then, if you control "Skypiercer Airfield", draw 1 card. If you control a "Skypiercer" monster and "Skypiercer Airfield": You can banish this card from your GY, then target 2 "Skypiercer" monsters in your GY; add them to your hand. You can only use this effect of "Skypiercer Ingenieurkorps" once per turn. You can only activate 1 "Skypiercer Ingenieurkorps" per turn. If a "Skypiercer" card(s) you control would be destroyed, you can return this banished card to the GY instead.
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
