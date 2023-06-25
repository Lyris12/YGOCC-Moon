--created by LeonDuvall
--On The Practical Applications of Concentrated Magitate
local s,id,o=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Magitate" monster from your Deck with the same attribute as a "Concentrated Magitate" monster you control. If this card is banished from your GY: You can return 1 card your opponent controls to the hand. You can only 1 effect of "On The Practical Applications of Concentrated Magitate" per turn, and only once that turn.
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
Card.IsConcentratedMagitate=Card.IsConcentratedMagitate or function(c) return c:GetCode()>131792009 and c:GetCode()<131792017 end
