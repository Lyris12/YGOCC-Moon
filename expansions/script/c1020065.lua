--created by Jake
--Bushido God Hopeful Evolved Phoenix
local s,id,o=GetID()
function s.initial_effect(c)
	local tp=c:GetControler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e1:SetCountLimit(1,5001+EFFECT_COUNT_CODE_DUEL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetOperation(function()
		Duel.SendtoDeck(Duel.CreateToken(0,5000),0,SEQ_DECKTOP,REASON_RULE)
	end)
	Duel.RegisterEffect(e1,0)
end
