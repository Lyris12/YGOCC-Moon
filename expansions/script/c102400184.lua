--created by LionHeartKIng
--フェイトヒーロー・カライスコ
local s,id,o=GetID()
function s.initial_effect(c)
	--2 LIGHT Warrior monsters The total Levels of this card's Fusion Materials must equal 6 or more. Once per battle, during damage calculation, if this card battles an opponent's monster (Quick Effect): You can halve the ATK of that opponent's monster, during that damage calculation only. Once per turn, if this card was Fusion Summoned using monsters whose combined Level equals 10 or more: You can inflict 800 damage to your opponent.
	local tp=c:GetControler()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e0:SetCountLimit(1,5001+EFFECT_COUNT_CODE_DUEL)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetOperation(function()
		local tk=Duel.CreateToken(tp,5000)
		Duel.SendtoDeck(tk,nil,SEQ_DECKTOP,REASON_RULE)
	end)
	Duel.RegisterEffect(e0,tp)
end
