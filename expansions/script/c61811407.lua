--created by Swag
--Dread Bastille - Concerto
local s,id,o=GetID()
function s.initial_effect(c)
	--3+ Level 8 "Dread Bastille" monsters This card's original DEF is equal to the number of materials attached to it x 1500. You can only use each of the following effects of "Dread Bastille - Concerto" once per turn. If this card is Xyz Summoned: You can attach 1 of your "Dread Bastille" cards that is banished or in the GY to this card as material. (Quick Effect): You can detach 1 material from this card; Special Summon 1 Level 8 Rock monster from your Deck in Defense Position. If this Xyz Summoned card you control is sent to the GY: You can gain LP equal to the DEF it had while face-up on the field, and if you do, draw 1 card.
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
