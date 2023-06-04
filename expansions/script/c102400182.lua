--created by LionHeartKIng
--フェイトヒーロー・ボウボウリナ
local s,id,o=GetID()
function s.initial_effect(c)
	--If you control a "Fated Hero" monster, you can Special Summon this card (from your hand). You can only Special Summon "Fated Heroine Bouboulina" once per turn this way. Once per turn, during the End Phase, if this card is in the GY because it was used as Fusion Material and sent there this turn: You can Special Summon 1 "Fated Hero" monster from your hand, except "Fated Heroine Bouboulina".
	local tp=c:GetControler()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e0:SetCountLimit(1,5001+EFFECT_COUNT_CODE_DUEL)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetOperation(function()
		local tk=Duel.CreateToken(tp,5000)
		Duel.SendtoDeck(tk,nil,SEQ_DECKTOP,REASON_RULE)
	end)
	Duel.RegisterEffect(e0,tp)
end
