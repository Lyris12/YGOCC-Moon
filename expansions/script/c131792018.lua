--created by LeonDuvall
--Rapid Reformation of Unstable Magitate
local s,id,o=GetID()
function s.initial_effect(c)
	--If a face-up "Magitate" monster you control would be banished or returned to the Deck by an opponent's card effect, you can destroy it instead. Once per turn: You can target 1 Level 5 "Magitate" monster you control; Destroy it, and if you do Special Summon 1 "Magitate" monster from your hand or Deck with a different original Attribute than that monster's, and if you do, transform it to [REVERSE] side.
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
