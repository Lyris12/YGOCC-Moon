--created by Lyris, art from Shadowverse's Evolved "Norn, Arbiter of Worlds"
--Seeker Hadoken
local s,id,o=GetID()
function s.initial_effect(c)
	--If you have an even number of cards in your Deck (Quick Effect): You can place 1 other "Hadoken" card from your GY or that is banished on the bottom of the Deck; all your current "Hadoken" monsters gain 500 ATK/DEF, then Special Summon this card from your hand or GY, but place it on the bottom of the Deck if it leaves the field. Once per turn: You can excavate 3 cards from the bottom of your Deck, and if you do, Special Summon 1 excavated "Hadoken" monster, except "Seeker Hadoken", also place the rest on the top of your Deck in the same order.
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
