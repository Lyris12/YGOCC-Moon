--created by LionHeartKIng
--フェイトヒーロー・インディペンデンス
local s,id,o=GetID()
function s.initial_effect(c)
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
	--Increase the Level of as many "Fated Hero" monsters as possible you control by 1, and if you do, if the Level of at least 1 of those monsters becomes 5 or higher, Fusion Summon 1 "Fated Hero" Fusion Monster from your Extra Deck, using monsters from your hand or field as Fusion Material. You can only activate 1 "Fated Hero Independence" per turn.
end
