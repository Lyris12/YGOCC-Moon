--created by Swag
--Dread Bastille - Cantata
local s,id,o=GetID()
function s.initial_effect(c)
	--You can discard this card; add 1 "Dread Bastille" card from your Deck to your hand, except "Dread Bastille - Cantata". If a "Dread Bastille" card is sent from your hand or field to the GY, while this card is in your hand or the GY: You can Special Summon this card, but banish it if it leaves the field. You cannot Special Summon monsters during the turn you activate this effect, except Rock monsters. If this card is Special Summoned: You can activate 1 of the following effects: ● Activate 1 "Dread Bastille's Overture" from your Deck. ● Place 4 Soulflame Counters on a "Dread Bastille's Overture" you control. You can only use each effect of "Dread Bastille - Cantata" once per turn.
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
