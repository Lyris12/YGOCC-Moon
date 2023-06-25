--created by LeonDuvall
--Aster, Magitate Terraemotus
local s,id,o=GetID()
function s.initial_effect(c)
	--"Magitate" monsters you control gain 200 ATK/DEF for each different Attribute among Level 5 "Magitate" monsters you control. Once per turn(Quick Effect): You can banish 1 "Concentrated Magitate" card from your GY, then target 1 "Magitate" monster you control; this turn, that monster is unaffected by your opponent's card effects.
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
