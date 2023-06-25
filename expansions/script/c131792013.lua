--created by LeonDuvall
--Radiant Concentrated Magitate
local s,id,o=GetID()
function s.initial_effect(c)
	--1 Level 4 or lower non-WIND "Magitate" monster If a Level 5 "Magitate" monster is destroyed: You can return this banished card to the Extra Deck; Special Summon 1 "Magitate" monster from your GY, then transform it to [REVERSE] side. You can only use this effect of "Radiant Concentrated Magitate" once per turn.
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
