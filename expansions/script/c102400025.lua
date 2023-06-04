--created by Lyris, art from Shadowverse's "Shion, Immortal Aegis"
--Undying Hadoken
local s,id,o=GetID()
function s.initial_effect(c)
	--2 LIGHT monsters Once per turn: You can Special Summon 1 "Hadoken" monster from your Deck, then place 1 card from your hand or field on the bottom of your Deck, except "Undying Hadoken" or the Summoned monster. Once per turn: You can excavate 9 cards from the bottom of your Deck, and if you do, add 1 excavated "Hadoken" card to your hand, also place the rest on top of your Deck in the same order.
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
