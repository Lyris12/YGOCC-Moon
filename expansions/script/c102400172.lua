--created by Lyris
--リージル・ケンタウルス
local s,id,o=GetID()
function s.initial_effect(c)
	--You can Special Summon this card (from your hand) to your opponent's field in Attack Position by Tributing 1 monster they control, then shift control to this card's owner during the End Phase. If this card is Normal or Special Summoned: Its owner cannot Link Summon until the end of the next turn, also they Special Summon 1 "Mirage Token" (Beast-Warrior-Type/LIGHT/Level 6/ATK 2200/DEF 1600), also, if it was Summoned using its own procedure, negate the effect of your next Trap Card or effect that resolves this turn, and if you do, Set that card face-down. You can only use this effect of "Rigil Kentaurus" once per turn.
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
