--created by Lyris, art from Shadowverse's "Cutthroat, Discord Convict"
--Psychic Hadoken
local s,id,o=GetID()
function s.initial_effect(c)
	--2+ monsters with different Types Any card that would be banished is placed on the bottom of the Deck instead. Once per turn: You can place 1 "Hadoken" card from your GY or that is banished on the bottom of the Deck, then target 1 card your opponent controls; banish 1 card its owner controls.
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
