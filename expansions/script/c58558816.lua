--created by LeonDuvall
--Flibberty Schizmaspatleblap
local s,id,o=GetID()
function s.initial_effect(c)
	--When you actviate this card, you can also discard 1 monster; Special Summon 1 Flip monster from your GY iin face-down Defense Position, then, if you discarded a monster when you activated this card, Special Summon 1 "Flibberty" monster from your Deck with the same Attribute as the discarded monster in face-up or face-down Defense Position. During the Main Phase, except the turn this card was sent to the GY: You can banish this card from your GY, then target 1 face-down or "Flibberty" monster you control; change it to face-up or face-down Defense Position. You can only use each effect of "Flibberty Schizmaspatleblap" once per turn.
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
