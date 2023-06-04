--created by Lyris
--半物質のシード
local s,id,o=GetID()
function s.initial_effect(c)
	--You can banish this card from your hand; shuffle up to 3 "Antemattr" monsters from your GY and/or that are banished into the Deck, except "Antemattr Seed", then draw 1 card. If this card is banished: You can change all your opponent's monsters to face-down Defense Position, also, you can change the Space of 1 of your Spatial Monsters after that. You can only use each effect of "Antemattr Seed" once per turn.
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
