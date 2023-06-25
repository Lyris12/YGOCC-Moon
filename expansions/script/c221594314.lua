--created by Walrus
--Voidictator Demon - Guardian of Corvus
local s,id,o=GetID()
function s.initial_effect(c)
	--Must be Ritual Summoned with "Voidictator Energy - Ritual Essence". This card cannot be used as a material for the Summon of a monster from the Extra Deck while it is on the field. This effect cannot be negated. You can only use the ① and ② effects of "Voidictator Demon - Guardian of Corvus" once per turn. ① If this card is Ritual Summoned: Banish all Special Summoned monsters your opponent controls, and if you do, this card's original ATK and DEF both become 800 x the number of cards banished this way. ② If this card is banished by a "Voidictator" card you own: You can banish 1 random face-down card from your Extra Deck, face-up; add this card to your hand. ③ Your opponent cannot activate the effects of Special Summoned monsters during the Battle Phase.
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
