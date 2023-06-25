--created by LeonDuvall
--Birth of the Sun
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate 1 of the following effects. ● If you control no monsters: Add 1 card which specifically lists "Helios - The Primordial Sun" from your Deck to your hand, also, for the rest of the turn you cannot Special Summon monsters, except LIGHT Pyro monsters. ● If you control "Helios - The Primordial Sun": Add 1 card which specifically lists "Macro Cosmos" from your Deck to your hand. If "Macro Cosmos" you control would be destroyed while you control "Helios - The Primordial Sun" or "Helios Duo Megistus", you can return this banished card to the GY instead. You can only activate 1 "Birth of the Sun" per turn.
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
