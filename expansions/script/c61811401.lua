--created by Swag
--Dread Bastille - Oratorio
local s,id,o=GetID()
function s.initial_effect(c)
	--You can discard this card; send 1 "Dread Bastille" monster from your Deck to the GY, except "Dread Bastille - Oratorio". You can target 1 "Dread Bastille" card you control; send it to the GY, and if you do, Special Summon this card from your GY. If this card is Special Summoned: You can target 1 card on the field; destroy it, and if you do, draw 1 card. You can only use each effect of "Dread Bastille - Oratorio" once per turn.
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
