--created by Jake
--Synchrobanger
local s,id,o=GetID()
function s.initial_effect(c)
	local tp=c:GetControler()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e0:SetCountLimit(1,5001+EFFECT_COUNT_CODE_DUEL)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetOperation(function()
		local tk=Duel.CreateToken(0,5000)
		Duel.SendtoDeck(tk,0,SEQ_DECKTOP,REASON_RULE)
	end)
	Duel.RegisterEffect(e0,0)
end
