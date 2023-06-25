--created by LeonDuvall
--Flibberty Hungbalongalogus
local s,id,o=GetID()
function s.initial_effect(c)
	--2+ Effect monsters, including a Flip monster Cannot be targeted or destroyed by card effects while you control a face-down monster. For each face-down monster you control, this card can attack 1 additional time during each Battle Phase. Once per turn: You can target 1 face-down monster you control; flip it face-up, and if you do, this card gains ATK equal to double that monster's DEF until the next End Phase. If this card attacks : You can target 1 Flip monster you control; flip it face-down. You can only use this effect of "Flibberty Hungbalongalogus" once per turn.
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
