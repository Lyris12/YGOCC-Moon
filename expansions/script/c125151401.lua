--created by LeonDuvall
--Exodice Physhe
local s,id,o=GetID()
function s.initial_effect(c)
	--FLIP: Each player draws 1 card, then, if this effect was activated during the Damage Step, send 1 card your opponent controls to the GY. If this card leaves the field due to your opponent's card: Inflict 100 damage to your opponent, and if you do, Special Summon 1 "Exodice" monster from your Deck, except "Exodice Physhe".
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
