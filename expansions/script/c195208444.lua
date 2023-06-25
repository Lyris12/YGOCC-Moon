--created by Seth
--Mextro Dextras
local s,id,o=GetID()
function s.initial_effect(c)
	--1 "Mextro " non-Link monster If this card is Link Summoned: Add 1 "Mextro" monster from your Deck to your hand. During the Main Phase (Quick Effect): You can banish 1 "Mextro" card in your GY; Special Summon 1 Link 2 or lower "Mextro" Link Monster from your GY, but it's effects are negated, then that monster is treated as being co-linked to this card. You cannot Special Summon monsters the turn you activate this effect, except "Mextro" monsters. You can only use each effect of "Mextro Dextras" once per turn.
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
