--created by LeonDuvall
--Exodice Fish
local s,id,o=GetID()
function s.initial_effect(c)
	--1 Fish Tuner + 1+ Non-tuner WATER monsters Cannot be targeted by card effects. If this card is Synchro Summoned: You can banish 2 Fish monsters from your hand or GY; Special Summon 1 "Exodice" monster from your Deck. If this card leaves the field due to your opponent's card: Inflict 100 damage to your opponent, and if you do, Special Summon 1 "Exodice" monster from your Deck. If this card you control is used as Synchro Material for a Fish monster, you can treat it as a non-Tuner.
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
