--created by Walrus
--Voidictator Rune - Origin's Realm
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only activate 1 "Voidictator Rune - Origin's Realm" per turn. 1 When this card is activated, you can add 1 "Voidictator Energy" card and 1 "Voidictator" Ritual Monster from your Deck or GY to your hand. 2 Your opponent cannot apply or activate the effects of monsters with the same Card Type (Ritual, Fusion, Synchro, Xyz, Pendulum, Pandemonium, Link, Bigbang, Spatial, Time Leap.) as "Voidictator Deity" and "Voidictator Demon" monsters you control. 3 If this card is banished because of a "Voidictator" card you own: You can banish 1 "Voidictator" card from your hand or GY; Set this card.
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
