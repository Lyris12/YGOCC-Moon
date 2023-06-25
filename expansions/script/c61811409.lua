--created by Swag
--Dread Bastille's Composition
local s,id,o=GetID()
function s.initial_effect(c)
	--Target 1 Level 8 or higher Rock Monster in your GY; send 1 "Dread Bastille" monster with a different name from your Deck to the GY, and if you do, Special Summon the targeted monster. You can banish this card from your GY and discard 1 card; add 1 "Dread Bastille's Overture" from your Deck or GY to your hand. You can only use each effect of "Dread Bastille's Composition" once per turn.
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
