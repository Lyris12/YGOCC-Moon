--created by LeonDuvall
--Exodice Premier Wrangling
local s,id,o=GetID()
function s.initial_effect(c)
	--Each time an "Exodice" monster you control leaves the field, due to an opponent's card, place 1 Noodlin' Counter on this card. Once per turn: You can target 1 "Exodice" monster you control; flip it face-down, and if you do, place 1 Noodlin' Counter on this card. Once per turn: You can remove 3 Noodlin' Counters from this card; Spceial Summon 1 "Exodice" monster from your hand or GY in face-up or face-down Defense Position. Once per turn: You can discard 1 card; add 1 "Exodice" card from your Deck to your hand, and if you do, place 1 Noodlin' Counter on this card. "You can only control 1 "Exodice Premier Wrangling"
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
