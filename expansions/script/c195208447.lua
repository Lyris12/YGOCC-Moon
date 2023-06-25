--created by Seth
--Mextro Blaxtres
local s,id,o=GetID()
function s.initial_effect(c)
	--2 Co-Linked "Mextro" monsters If this card is Link Summoned: Add 1 level 1 "Mextro" monster from your Deck to your hand. During the Battle Phase (Quick Effect): You can target 1 monster you opponent controls; it's ATK and DEF become 0 until the End Phase.  You can only use each effect of "Mextro Blaxtres" once per turn.
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
