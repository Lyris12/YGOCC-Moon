--created by LeonDuvall
--Reawakening of the Primordial Sun
local s,id,o=GetID()
function s.initial_effect(c)
	--This card's name is also treated as "Macro Cosmos" while on the field. "Helios - The Primordial Sun" you control are unaffected by your opponent's card effects. Once per turn: You can activate 1 of these effects. ● Special Summon 1 "Helios - The Primordial Sun" from your Deck or that is banished. ● If you control "Helios - The Primordial Sun": Set 1 Spell/Trap which specificially lists "Helios - The Primordial Sun" or "Macro Cosmos" directly from your Deck. It can be activated this turn. You can only activate 1 "Reawakening of the Primordial Sun" per turn.
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
