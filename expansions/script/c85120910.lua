--created by LeonDuvall
--Primordial Cubicle
local s,id,o=GetID()
function s.initial_effect(c)
	--When this card is activated: You can add 1 LIGHT Pyro monster from your Deck to your hand. If you Normal or Special Summon "Helios - The Primordial Sun": You can activate 1 of the following effects, depending on whose turn it is. ● Your turn: Add 1 "Helios Duo Megistus" or "Helios Thrice Megistus" from your Deck to your hand, then you can destroy 1 card your opponent controls. ● Opponent's Turn: Set 1 Spell/Trap which specifically lists "Helios - The Primordial Sun" directly from your Deck. It can be activated this turn. You can only use each effect of "Primordial Cubicle" once per turn.
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
