--created by LeonDuvall
--Aerin, Magitate Divinitatum
local s,id,o=GetID()
function s.initial_effect(c)
	--If a Level 5 "Magitate" monster you control battles an opponent's monster, that opponent's monster has its effects negated during the battle phase only, also your opponent cannot activate cards or effects until the end of the Damage Step. Once per turn (Quick Effect): you can banish 1 "Concentrated Magitate" card from your GY; Special Summon 1 "Magitate" monster from your hand or GY, except "Aerin, Magitate Shade", and if you do, transform it to [REVERSE] side, then draw 1 card.
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
