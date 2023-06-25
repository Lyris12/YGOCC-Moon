--created by Walrus
--Voidictator Rune - Gates of Perdition
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only use each effect of "Voidictator Rune - Gates of Perdition" once per turn, and you can only activate 1 "Voidictator Rune - Gates of Perdition" per turn. When this card is activated, you can banish the top cards of your Deck, up to the number of monsters your opponent controls. During your turn, you cannot Summon monsters from the Extra Deck, except "Voidictator" monsters, also you can ignore the effects of your "Voidictator" monsters that prevent them from being used as material. If you control at least 3 of the following face-up "Voidictator" monsters (1 "Voidictator Deity", 1 "Voidictator Demon", and 1 "Voidictator Servant"), all face-up "Voidictator Deity" and "Voidictator Demon" monsters you control are unaffected by your opponent's card effects.
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
