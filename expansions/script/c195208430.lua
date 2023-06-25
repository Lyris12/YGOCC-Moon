--created by Seth
--Mextro Sightseeker
local s,id,o=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: Excavate the top 3 cards of your Deck, and if you do, you can add 1 excavated "Mextro" card to your hand, also shuffle the rest into your Deck, then, if the added card is a monster, you can Special Summon it. If this card is used as material for the Link Summon of a "Mextro" Link Monster: Gain 1000 LP, then you can activate 1 "Mextro" Field Spell from your  Deck or GY. You can only use each effect of "Mextro Sightseeker" once per turn.
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
