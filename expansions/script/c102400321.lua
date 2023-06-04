--created by Discord \ Ace/Verloren, art from "Shellrokket Dragon"
--Sinful Shelrokket Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	--You can Special Summon Pendulum Monsters from your Extra Deck to unlinked Main Monster Zones. You can only use each of the following Pendulum Effects of "Sinful Shelrokket Dragon" once per turn. If this card is placed in the Pendulum Zone by its own effect: Special Summon 1 Level 1 "Rokket" monster from your Deck. If a "Rokket" monster(s) you control is destroyed: Special Summon 1 "Rokket" monster with a lower Level than 1 of those destroyed monsters from your Deck. If a Link Monster's effect is activated that targets this face-up card on the field: You can destroy this card, and if you do, send 1 Fusion, Synchro, Xyz, or Link Monster on the field to the GY. If this face-up card on the field is destroyed by your card effect: You can place it in your Pendulum Zone.
	local tp=c:GetControler()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e0:SetCountLimit(1,5001+EFFECT_COUNT_CODE_DUEL)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetOperation(function()
		local tk=Duel.CreateToken(tp,5000)
		Duel.SendtoDeck(tk,nil,SEQ_DECKBOTTOM,REASON_RULE)
		c5000.ops(f0,tp)
	end)
	Duel.RegisterEffect(e0,tp)
end
