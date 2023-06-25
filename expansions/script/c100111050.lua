--created by Jake
--Armored Terrabiter
local s,id,o=GetID()
function s.initial_effect(c)
	--If this card is sent to the GY: You can target 1 monster you control, then use one of the following effects ● Until the end of this turn, treat this card's Attribute and Type as the Attribute and Type as that target's while this card is in the GY. ● Until the end of this turn, treat that target's Attribute and Type as this card's Attribute and Type while its face-up on the field. You can only use the effect of "Armored Terrabiter" once per turn.
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
