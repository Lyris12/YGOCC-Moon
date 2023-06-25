--created by Seth
--Mextro Assassin
local s,id,o=GetID()
function s.initial_effect(c)
	--You can discard this card, then target 2 "Mextro" Link Monsters you control; while both targets are face-up on the field, they are treated as being co-linked to each other. If this card is Special Summoned by the effect of a "Mextro" card: Target 1 "Mextro" Link Monster you control: It gains ATK equal to its Link Rating x 200. You can only use each effect of "Mextro Assassin" once per turn.
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
