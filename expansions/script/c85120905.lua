--created by LeonDuvall
--The Reforged Cosmos
local s,id,o=GetID()
function s.initial_effect(c)
	--This card's name becomes "Macro Cosmos" while on the field, in the GY or banished. When this card resolves: You can Special Summon 1 "Helios - The Primordial Sun" from your hand or Deck, also, for the rest of the turn you cannot Special Summon monsters, except LIGHT Pyro monsters. While you control "Helios - The Primordial Sun" or "Helios Duos Megistus", any card sent to the GY is banished instead.
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
