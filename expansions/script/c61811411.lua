--created by Swag
--Dread Bastille's Intermezzo
local s,id,o=GetID()
function s.initial_effect(c)
	--When your opponent activates a Spell/Trap, or monster effect, while you control a "Dread Bastille" Xyz Monster: You can send 1 "Dread Bastille" monster from your hand or field to the GY, and if you do, negate the activation, and if you do that, you can attach it to a "Dread Bastille" Xyz Monster you control. During your opponent's Battle Phase: You can banish this card from your GY, then target 1 monster you control and 1 monster your opponent controls; that opponent's monster must attack your targeted monster this turn, if able. You can only use each effect of "Dread Bastille's Intermezzo" once per turn.
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
