--created by Swag
--Dread Bastille - Étude
local s,id,o=GetID()
function s.initial_effect(c)
	--You can discard this card, then target 1 of your "Dread Bastille" monsters that is banished or in the GY, except "Dread Bastille - Étude"; Special Summon it. If this card is detached from a Xyz Monster to activate it's effects: You can Special Summon this card. If this card is Special Summoned: You can return 1 "Dread Bastille" card in your GY to your hand. You can only use each effect of "Dread Bastille - Étude" once per turn.
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
