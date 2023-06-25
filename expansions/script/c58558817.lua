--created by LeonDuvall
--Dixy Nix, Flibberty Cartoonist
local s,id,o=GetID()
function s.initial_effect(c)
	--1 Flip monster with 1000 or less ATK Cannot be targeted for attacks while you control a face-down monster, but does not prevent your opponent from attacking you directly. If this card is Link Summoned: You can discard 1 card; Set 1 "Flibberty" card directly from your Deck. If a monster is Set or Special Summoned face-down to the zone this card points to: You can flip it face-up. You can only use each effect of "Dixy Nix, Flibberty Cartoonist" once per turn.
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
