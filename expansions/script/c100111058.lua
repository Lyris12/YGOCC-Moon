--created by Jake
--Rapid Fire Bat
local s,id,o=GetID()
function s.initial_effect(c)
	--2+ Level 6 monsters If this card is Xyz Summoned using only DARK or Winged Beast monsters: inflict 400 damage to your opponent for each material attached to this card. This Xyz Summoned card cannot be targeted by monster effects while it has material attached to it. Once per turn (Quick Effect): You can detach 1 material from this card; Special Summon 1 DARK Winged Beast monster from your Deck in face-up Defense Position with its effects negated, but banish it when it leaves the field. You can only use this effect of "Rapid Fire Bat" once per turn.
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
