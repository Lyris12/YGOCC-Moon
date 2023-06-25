--created by Seth
--Mextro Factory
local s,id,o=GetID()
function s.initial_effect(c)
	--You can shuffle 1 "Mextro" monster from your hand into the Deck; add 1 "Mextro" monster with a different Level from your Deck to your hand. If you control 2 or more "Mextro" Link Monsters: You can return up to 3 of those monsters to the Extra Deck; Special Summon "Mextro" monsters from your Deck, up to the number of monsters you returned, whose total Levels equal either the Link Rating of 1 of those returned monsters, or their total Link Rating. you can only use each effect of "Mextro Factory" once per turn.
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
