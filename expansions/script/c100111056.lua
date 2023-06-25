--created by Jake
--Novavoid Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	--1 DARK Tuner + 1+ non-Tuner monsters Once per turn: You can target 1 monster your opponent controls; destroy it. This card cannot directly during the turn you activate this effect. If your opponent's monster activates an effect that would negate and destroy a card(s) you control: You can Tribute this card; negate that effect, and if you do, banish it. During the End Phase, if this effect was activated this turn (and was not negated): You can Special Summon this card from your GY.
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
