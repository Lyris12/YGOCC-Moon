--created by Lyris
--半物質のニュート
local s,id,o=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can add 1 "Antemattr" Spell/Trap from your Deck to your hand. You can only use this effect of "Antemattr Newt" once per turn. Once per turn: You can reveal 1 "Antemattr" monster in your hand; for the rest of this turn, this card's Level becomes that revealed monster's Level, also this card gains 500 DEF x that revealed monster's Level.
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
