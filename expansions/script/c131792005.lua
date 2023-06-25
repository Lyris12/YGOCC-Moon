--created by LeonDuvall
--Corentin, Magitate Tempestas
local s,id,o=GetID()
function s.initial_effect(c)
	--"Magitate" monsters you control cannot be flipped face-down, or destroyed by Spell/Trap cards or effects. Once per turn, when your opponent activates a card or effect that targets a "Magitate" card(s) you control (Quick Effect): You can banish 1 "Concentrated Magitate" card from your GY; negate the effect, and if you do, shuffle that card into the Deck.
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
