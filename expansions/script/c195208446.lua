--created by Seth
--Mextro Trixia
local s,id,o=GetID()
function s.initial_effect(c)
	--1 "Mextro" non-Link Monster If this card is Link Summoned: Target 1 "Mextro" Link Monster you control; it gains 500 ATK. You can Tribute this card, then target up to 3 "Mextro" Link Monsters you control; while all of those targets are face-up on the field, they are treated as being co-linked to each other. You can only use each effect of "Mextro Trixia" once per turn.
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
