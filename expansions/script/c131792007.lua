--created by LeonDuvall
--Cindy, Magitate Infernum
local s,id,o=GetID()
function s.initial_effect(c)
	--If a Level 5 "Magitate" monster you control attacks a Defense Position monster, inflict piercing battle damage to your opponent. Once per turn(Quick Effect): You can target 1 monster your opponent controls, then banish 1 "Concentrated Magitate" card from your GY; destroy that monster, and if you do, deal 400 damage to your opponent.
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
