--created by Lyris, art from "The Wyvern"
--ザ☆機光襲雷
local s,id,o=GetID()
function s.initial_effect(c)
	--Each time a Monster Card(s) is destroyed, decrease this card's Energy by 1 for each destroyed card. (Quick Effect): You can increase this card's Energy by 1, then target 1 "Blitzkrieg" Monster Card you control; Take 1 "Blitzkrieg" monster in your Deck or face-up Extra Deck, and either place it in your Pendulum Zone or Special Summon it, then destroy that target. You can only use this effect of "The Blitzkrieg Meklight" once per turn. If your opponent declares an attack that targets this card, destroy this card. After this card is Special Summoned, your "Blitzkrieg" cards cannot be destroyed by your opponent's card effects for the rest of that turn, except Monster Cards.
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
