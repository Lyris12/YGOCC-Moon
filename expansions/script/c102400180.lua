--created by LionHeartKIng
--フェイトヒーロー・ミアオーリス
local s,id,o=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can send 1 "Fated Hero" monster from your Deck to the GY, except "Fated Hero Miaoulis". Once per turn, during your Main Phase: You can increase this card's Level by 1, and if you do, if this card's Level becomes 5 or higher, Fusion Summon 1 "Fated Hero" monster from your Extra Deck, using monsters you control as Fusion Materials, including this card.
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
