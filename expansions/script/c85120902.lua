--created by LeonDuvall
--Radiant Child of Light
local s,id,o=GetID()
function s.initial_effect(c)
	--This card's original ATK/DEF are each equal to the number of banished cards x 50. When your opponent activates a card or effect (Quick Effect): You can banish this card from your hand or field and 1 other card from your hand; banish that card. You can only use this effect of "Radiant Child of Light" once per turn.
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
