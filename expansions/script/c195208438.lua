--created by Seth
--Mextro Darxstorm
local s,id,o=GetID()
function s.initial_effect(c)
	--2 co-linked "Mextro" monsters If this card is Link Summoned: You can Special Summon 1 level 4 or lower "Mextro" monster from your hand or Deck to your zone this card points to. During the Main Phase (Quick Effect): You can Tribute 1 "Mextro" Link Monster this card points to; destroy face-up Spells/Traps on the field, up to that monsters Link Rating (max. 3). You can only use each effect of "Mextro Darxstorm" once per turn.
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
