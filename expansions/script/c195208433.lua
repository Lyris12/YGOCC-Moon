--created by Seth
--Mextro Observer
local s,id,o=GetID()
function s.initial_effect(c)
	--During your Main Phase: You can discard this card; Special Summon 1 Level 4 or lower "Mextro" monster from your hand or GY in Defense Position. If this card is used as material for the Link Summon of a "Mextro" monster: Look at the top 3 cards of your Deck, then you can reveal 1 "Mextro" card among them, and add it to your hand, also shuffle the rest into the Deck. (Quick Effect): You can shuffle this card from your GY into the Deck; return 1 "Mextro" Link Monster from your GY to the Extra Deck. You can only use each effect of "Mextro Observer" once per turn.
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
