--created by Seth
--Mextropolis City
local s,id,o=GetID()
function s.initial_effect(c)
	--While you control a face-up "Mextro" Link Monster, your opponent cannot target face-up "Mextro" Spells/Traps you control with card effects. During your Main Phase 1, if you control no monsters, or all monsters you control are "Mextro" monsters: You can send up to 3 "Mextro" monsters from your hand and/or face-up field to the GY; Special Summon from your Extra Deck, 1 "Mextro" Link Monster whose Link Rating is equal to the number of cards sent, ignoring its Summoning conditions. (This is treated as a Link Summon.) You can only use this effect of "Mextropolis City" once per turn.
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
