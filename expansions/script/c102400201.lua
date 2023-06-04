--created by Discord \ MegaSausage
--ローマ・キー・CDXX
local s,id,o=GetID()
function s.initial_effect(c)
	--This card's Level is doubled during the turn it is Summoned. When this card is Summoned: Declare a card type; excavate the top 5 cards of your Deck, and if they are all the declared type, add 1 "Roman Keys" monster from your Deck to your hand. You can only use this effect of "Roman Keys - CDXX" once per turn.
	local tp=c:GetControler()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e0:SetCountLimit(1,5001+EFFECT_COUNT_CODE_DUEL)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetOperation(function()
		local tk=Duel.CreateToken(tp,5000)
		Duel.SendtoDeck(tk,nil,SEQ_DECKTOP,REASON_RULE)
	end)
	Duel.RegisterEffect(e0,tp)
end
