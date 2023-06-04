--created by Lyris, art from "The Star Dragon"
--ザ☆機夜光襲雷
local s,id,o=GetID()
function s.initial_effect(c)
	--Each time a Monster Card(s) is destroyed, increase this card's Energy by 1 for each destroyed card. Once per turn (Quick Effect): You can decrease this card's Energy by 1, then target 1 "Blitzkreig" monster in your GY or that is banished, except "The Blitzkrieg Meknight"; either place it in your Pendulum Zone or Special Summon it. If your opponent declares an attack that targets this card, destroy this card. After this card is Special Summoned, your other "Blitzkrieg" monsters gain 300 ATK, also they are unaffected by your opponent's card effects that would not destroy them.
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
