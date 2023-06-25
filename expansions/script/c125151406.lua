--created by LeonDuvall
--Exodice Phish
local s,id,o=GetID()
function s.initial_effect(c)
	--If this card leaves the field due to an opponent's card: Inflict 100 damage to your opponent, and if you do, Special Summon 1 "Exodice" monster from your Deck, except "Exodice Phish". During the Main or Battle Phase (Quick Effect): You can banish this card from the GY, then target 5 Fish monsters in your GY; shuffle them into the Deck, and if you do, draw 2 cards. You can only use this effect of "Exodice Phish" once per turn.
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
