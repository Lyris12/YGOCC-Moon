--created by Lyris, art from Shadowverse's "Merciless Voiding"
--Hadokenihilism
local s,id,o=GetID()
function s.initial_effect(c)
	--When your opponent activates a card or effect while you have an even number of cards in your GY: Negate the effect, and if you do, place both that card and 1 "Hadoken" card from your field or GY on the bottom of your Deck. You can banish this card from your GY; excavate 3 cards from the bottom of your Deck, and if you do, Set 1 excavated "Hadoken" card to your field, also, place the other excavated cards on top of your Deck in the same order.
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
