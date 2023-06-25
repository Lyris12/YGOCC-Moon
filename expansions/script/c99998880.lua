--created by Walrus
--Voidictator Servant - Shield of Corvus
local s,id,o=GetID()
function s.initial_effect(c)
	--This card cannot be used as a material for the Summon of a monster from the Extra Deck while it is on the field. This effect cannot be negated. You can only use each effect of "Voidictator Servant - Shield of Corvus" once per turn. 1 If your opponent declares a direct attack while this card is in your hand (Quick Effect): You can Special Summon this card, and if you do, end the Battle Phase. 2 If this card is banished because of a "Voidictator" card you own: You can shuffle this card into the Deck; Special Summon 1 Level 4 "Voidictator Servant" monster from your hand or GY.
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
