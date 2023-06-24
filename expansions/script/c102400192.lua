--created by Lyris
--パズル・クリボー
local s,id,o=GetID()
function s.initial_effect(c)
	--During your opponent's Main Phase 1 (Quick Effect): You can discard this card; it becomes the Battle Phase of this turn, then take 1 "Kuriboh" monster from your Deck, and either add it to your hand or Special Summon it. At the start of your opponent's Battle Phase: You can banish this card from your GY, then target 1 monster your opponent controls; this turn, your opponent cannot declare an attack with other monsters if it can attack, also it must attack, if able.
	local tp=c:GetControler()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e0:SetCountLimit(1,5001+EFFECT_COUNT_CODE_DUEL)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetOperation(function()
		local tk=Duel.CreateToken(tp,5000)
		Duel.SendtoDeck(tk,nil,SEQ_DECKBOTTOM,REASON_RULE)
		c5000.ops(f0,tp)
	end)
	Duel.RegisterEffect(e0,tp)
end
