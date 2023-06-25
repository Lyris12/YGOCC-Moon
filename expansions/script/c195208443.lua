--created by Seth
--Mextro Laboratory
local s,id,o=GetID()
function s.initial_effect(c)
	--If you control no "Mextro" Link Monsters, destroy this card. You can only use 1 of the following "Mextro Laboratory" effects per turn, and only once that turn.  ● You can pay 1000 LP; immediately after this effect resolves, Link Summon 1 "Mextro" Link Monster using "Mextro" monster(s) you control as material.  ● During the Main Phase: You can pay 1000 LP; add 1 "Mextro" Spell/Trap from your Deck to your hand, also for the rest of this turn, you cannot activate cards, or the effects of cards, with the same name as that card.
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
