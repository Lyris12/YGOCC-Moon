--created by Swag
--Dread Bastille - Rhapsodie
local s,id,o=GetID()
function s.initial_effect(c)
	--During the Main or Battle Phase (Quick Effect): You can discard this card, then target 1 "Dread Bastille" monster you control and 1 monster your opponent controls with less DEF than it; negate that opponent's monster's effects. If a Rock monster(s) is Normal or Special Summoned to your side of the field: You can Special Summon this card from your GY, but banish it if it leaves the field. If this card is Special Summoned: You can send 1 "Dread Bastille" Spell/Trap from your Deck to the GY. You can only use each effect of "Dread Bastille - Rhapsodie" once per turn.
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
