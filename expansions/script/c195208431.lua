--created by Seth
--Mextro Hopeseeker
local s,id,o=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned during your Main Phase: You can Special Summon 1 "Mextro" Link Monster from your GY with a Link Rating equal to the number of "Mextro" Link Monsters you control (max. 3). If this card is used as material for the Link Summon of a "Mextro"  Link Monster: Draw 1 card. You can only use each effect of "Mextro Hopeseeker" once per turn.
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
