--created by Discord \ Walrus, art from "Supreme King Z-ARC"
--虚空制裁者悪魔アンフォームド・マレボルンス(アナザー宙)
local s,id,o=GetID()
function s.initial_effect(c)
	--1+ "Voidictator" monsters + 1+ DARK Fiend monsters / You can only control 1 "Voidictator Demon - Unformed Malevolence". Three times per turn, if your opponent Special Summons a Spatial Monster: This card gains that monster's effects until the end of the next turn. Monsters your opponent controls must attack this card, if able. You can only use the following effects of "Voidictator Demon - Unformed Malevolence" once per turn. At the start of the Damage Step, if this card is attacked by a monster whose original ATK is lower than this card's DEF: Banish that monster until the End Phase. If this card leaves the field because of an opponent's card, OR if this card is banished by a "Voidictator" card you own: Return this card to the Extra Deck, then, all "Voidictator" monsters you currently control gain 200 ATK for each of your banished "Voidictator" monsters.
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
