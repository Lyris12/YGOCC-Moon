--created by LeonDuvall
--Exodice Feesh
local s,id,o=GetID()
function s.initial_effect(c)
	--Once per turn, you can either: Target 1 WATER monster you control; equip this card to that target, OR: Unequip this card and Special Summon it. If this card is Special Summoned: You can Special Summon 1 "Exodice" monster from your hand, and if you do, equip this card to it, then draw 1 card. You can only use this effect of "Exodice Feesh" once per turn. If this card leaves the field due to an opponent's card: Inflict 100 damage to your opponent, and if you do, Special Summon 1 "Exodice" monster from your Deck, except "Exodice Feesh".
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
