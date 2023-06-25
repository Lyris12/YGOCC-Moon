--created by Swag
--Dread Bastille's Cadence
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only activate this card during your turn. Until the end of your opponent's next turn, swap the ATK and DEF of all "Dread Bastille" monsters you control, also, "Dread Bastille" Xyz Monsters you control inflict piercing battle damage to your opponent. If a "Dread Bastille" Xyz Monster(s) you control would be destroyed by battle or card effect, you can banish this card from your GY instead. If a "Dread Bastille" card you control is destroyed by battle or card effect, while this card is banished: You can place it on either the top or the bottom of your Deck. You can only use each effect of "Dread Bastille's Cadence" once per turn.
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
