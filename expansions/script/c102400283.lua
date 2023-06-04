--created by Lyris
--半物質のリッチ
local s,id,o=GetID()
function s.initial_effect(c)
	--You can Special Summon this card (from your hand) by returning 1 of your banished "Antemattr" monsters to the Deck or Extra Deck. During your Main Phase: You can banish both 1 of your Spatial Monsters and 1 Spell/Trap your opponent controls. You can only use this effect of "Antemattr Lich" once per turn.
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
