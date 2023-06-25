--created by Seth
--Mextro Axtreem
local s,id,o=GetID()
function s.initial_effect(c)
	--1 "Mextro" non-Link monster If this card is Link Summoned: Add 1 "Mextro" Spell/Trap from your Deck to your hand. During the Battle Phase, when your opponent activates a card or effect that would destroy a "Mextro" card(s) you control (Quick Effect): You can Tribute this card; negate the activation, and if you do, destroy it. You can only use each effect of "Mextro Axtreem" once per turn.
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
