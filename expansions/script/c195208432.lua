--created by Seth
--Mextro Citizen
local s,id,o=GetID()
function s.initial_effect(c)
	--During your Main Phase, except the turn this card was sent to the GY: You can shuffle this card from your GY into the Deck; Special Summon 1 Level 5 or higher "Mextro" monster from your hand. You can only use this effect of "Mextro Citizen" once per turn. A "Mextro" Link Monster that was Link Summoned using this card as material gains this effect. ●This card can attack twice during each Battle Phase.
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
