--created by Lyris, art from Shadowverse's "Cultivate Life"
--Hadoken Nurtration
local s,id,o=GetID()
function s.initial_effect(c)
	--When this card is activated: Look at 6 cards from the bottom of your Deck, and if you do, place them on the bottom of your Deck in any order. You can only activate 1 "Hadoken Nurtration" per turn. During the turn a "Hadoken" card(s) was excavated from your Deck, all your "Hadoken" monsters gain 100 ATK for each. Once per turn: You can excavate 3 cards from the bottom of your Deck, and if you do, you can send cards your opponent controls to the GY, up to the number of excavated "Hadoken" cards, also place the excavated cards on the top of the Deck in the same order.
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
