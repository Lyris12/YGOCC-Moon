--created by Lyris, art found by DiegoGisbertLlorens of DeviantArt
--機氷竜インドラ
local s,id,o=GetID()
function s.initial_effect(c)
	if not s.global_check then
		s.global_check=true
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
end
