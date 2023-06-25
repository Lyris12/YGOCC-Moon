--created by Walrus
--Voidictator Servant - Gate Magician
local s,id,o=GetID()
function s.initial_effect(c)
	--While you control this card and 1 "Voidictator Deity" or "Voidictator Demon" monster, your opponent cannot control face-up Pandemonium Cards in their Spell/Trap Zone. Up to twice per turn: You can target 1 "Voidictator" card in your GY; banish it. This card cannot be used as a material for the Summon of a monster from the Extra Deck while it is on the field. This effect cannot be negated. You can only use each effect of "Voidictator Servant - Gate Magician" once per turn. You can Special Summon this card (from your hand or from face-up in your Extra Deck) by sending 1 "Voidictator Servant" monster you control to the GY. If this card is Normal or Special Summoned: You can banish up to 2 "Voidictator" cards from your GY; this card gains 800 ATK for each card banished by this effect. If this card is banished because of a "Voidictator" card you own: You can either Set this card in your Spell/Trap Zone, OR; shuffle this card into the Deck.
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
