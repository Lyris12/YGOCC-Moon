--created by LeonDuvall
--Champion of The Primordial Sun - Solaire
local s,id,o=GetID()
function s.initial_effect(c)
	--2 Level 6 LIGHT Pyro monsters This card's original ATK/DEF are each equal to the number of banished cards x 400. This card's name becomes "Helios Duo Megistus" while on the field. Once per turn (Quick Effect): You can detach 1 material; your opponent cannot activate any banished card effects this turn. If this card is Tributed or banished while you control "Macro Cosmos": You can return this card to the Extra Deck; banish all cards from the GYs. You can only use this effect of "Champion of The Primordial Sun - Solaire" once per turn.
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
