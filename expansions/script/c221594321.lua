--created by Walrus
--Voidictator Energy - Ritual Essence
local s,id,o=GetID()
function s.initial_effect(c)
	--This card can be used to Ritual Summon any "Voidictator" Ritual Monster. You must also Tribute DARK Fiend monsters from your hand or field, or return your banished Level 4 or lower DARK Fiend monsters to the GY, whose total Levels equal or exceed the Level of the Ritual Monster you are Ritual Summoning. If this card is banished because of a "Voidictator" card you own: You can banish 1 "Voidictator Servant" monster from your hand or GY; add this card to your hand. You can use this effect of "Voidictator Energy - Ritual Essence" up to twice per turn.
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
