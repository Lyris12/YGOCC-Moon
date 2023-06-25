--created by LeonDuvall
--Elysia, Magitate Pebble
local s,id,o=GetID()
function s.initial_effect(c)
	--You can discard 1 card; send 1 "Magitate" card from your Deck to the GY, then you can banish 1 "Magitate" card from your GY. You can tribute 1 WATER "Concentrated Magitate" monster; Special Summon this card from your GY, then transform it to [REVERSE] side. You can only use each effect of"Elysia, Magitate Pebble" once per turn.
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
