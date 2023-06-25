--created by Walrus
--Voidictator Rune - Ultimate Gating Art
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only use each effect of "Voidictator Rune - Guiding Eulogy" once per turn. ① If you control a "Voidictator Deity" monster: Halve the ATK of 1 Special Summoned monster your opponent controls until the End Phase, and if you do, 1 "Voidictator" monster gains that lost ATK. If you control a "Voidictator Deity - Jezebel the Dark Angel", that monster's ATK becomes 0 instead. Your opponent cannot activate cards or effects in response to this card's activation if you control a "Voidictator Deity - Jezebel the Dark Angel". ② If this card is banished by a "Voidictator" card you own: You can target 1 "Voidictator Deity" or "Voidictator Demon" monster you control; all monsters your opponent currently controls lose ATK equal to the ATK of that monster. If a monster(s) ATK is reduced to 0 by this effect, its effects are negated.
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
