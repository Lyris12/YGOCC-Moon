--created by Seth
--Mextro Diatron
local s,id,o=GetID()
function s.initial_effect(c)
	--3 co-linked "Mextro" monsters Cannot be destroyed by card effects. During your Main Phase: You can discard up to 3 cards; Special Summon 1 "Mextro" Link Monster from your Extra Deck or GY, with a Link Rating equal to the number of cards discarded to activate this effect, and if you do, that monster is treated as co-linked to this card while face-up on the field, also it cannot attack. During the turn you activate this effect, you cannot Special Summon monsters from the Extra Deck, except Link Monsters. You can only use this effect of "Mextro Diatron" once per turn.
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
