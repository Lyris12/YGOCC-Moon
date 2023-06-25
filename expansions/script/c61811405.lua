--created by Swag
--Dread Bastille - Serenado
local s,id,o=GetID()
function s.initial_effect(c)
	--2 Level 8 Rock monsters If this card is Xyz Summoned: You can send 1 other card you control or from your hand to the GY, and if you do, add 1 "Dread Bastille" Spell/Trap from your Deck to your hand. During the Main Phase: You can detach 1 material from this card, then target 1 Rock monster in your GY; Special Summon it. If this Xyz Summoned card you control is sent to the GY: You can activate this effect; for the rest of the turn after this effect resolves, the activation and the effects of "Dread Bastille" Spells cannot be negated. You can only use each effect of "Dread Bastille - Serenado" once per turn.
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
