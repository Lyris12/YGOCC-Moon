--created by Swag
--Dread Bastille - Rondo
local s,id,o=GetID()
function s.initial_effect(c)
	--You can discard this card; Special Summon 1 "Dread Bastille" monster from your Deck, except "Dread Bastille - Rondo". You cannot Special Summon monsters during the turn you activate and resolve this effect, except Rock monsters. You can banish 1 other "Dread Bastille" card from your GY; Special Summon this card from your GY, but banish it if it leaves the field. If this card is Special Summoned: You can target 1 card in your opponent's GY; banish it. You can only use each effect of "Dread Bastille - Rondo" once per turn.
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
