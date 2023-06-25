--created by Seth
--Mextro Midas
local s,id,o=GetID()
function s.initial_effect(c)
	--4 Co-Linked "Mextro" monsters Unaffected by your opponent's card effects. If this card is Link Summoned: Gain 1000 LP, also place Machine Counters on this card equal to the number of "Mextro" Link Monsters on the field and in your GY (max. 10). If a "Mextro" Link Monster(s) is Special Summoned, place 1 Machine Counter on this card. When this card declares an attack: Target 1 Spell/Trap your opponent controls; shuffle it into the Deck. (Quick Effect): You can remove 4 Machine Counters from this card to activate 1 of these effects; ● Shuffle 1 card your opponent controls into the Deck. ● Negate the effects of 1 face-up card your opponent controls.
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
