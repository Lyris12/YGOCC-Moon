--created by Swag
--Dread Bastille's Overture
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only control 1 "Dread Bastille's Overture". When this card is activated, place 4 Soulflame Counters on it. When a Level 8 or higher Rock monster that can be Normal Summoned/Set is sent to your GY, place 1 Soulflame Counter on this card (max 12). Once per turn, you can remove Soulflame Counters from this card in multiples of 4; apply the following effects in sequence based on the amount removed: ● 4+: Add 1 "Dread Bastille" monster from your Deck to your hand. ● 8+: Special Summon 1 Level 8 or higher Rock monster from your hand or GY. ● 12: Banish 1 monster your opponent controls with less ATK than the highest DEF among Rock monsters you control, face-down.
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
