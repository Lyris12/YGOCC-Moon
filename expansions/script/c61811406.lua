--created by Swag
--Dread Bastille - Fugue
local s,id,o=GetID()
function s.initial_effect(c)
	--2+ Level 8 Rock monsters If this card is Xyz Summoned: You can send 1 card from your hand or that you control to the GY, and if you do, add 1 "Dread Bastille" card from your GY to your hand. (Quick Effect): You can detach 1 material from this card, then target 1 monster your opponent controls, destroy it, and if you do, inflict damage to your opponent equal to half of the destroyed monster's ATK. If this Xyz Summoned card you control is sent to the GY while you control a "Dread Bastille" monster; You can target 1 "Dread Bastille" monster you control; Special Summon this card from your GY, and if you do, attach the targeted card to this card as material. You can only use each effect of "Dread Bastille - Fugue" once per turn.
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
