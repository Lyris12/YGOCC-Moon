--created by Seth
--Mextro Dark Empress
local s,id,o=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can Tribute 1 "Mextro" Link Monster you control; this card gains ATK equal to that monster's ATK in the GY. If this face-up card leaves the field: You can Special Summon 1 "Mextro" Link Monster from your GY, and if you do, that monster gains ATK equal to the ATK this monster had on the field. If this card is in your GY, except the turn this card was sent to the GY (Quick Effect): You can banish this card from your GY, then target 1 Link Monster your opponent controls; until the End Phase, it is treated as a "Mextro" monster, also you can use it as material for the Link Summon of your "Mextro" Link Monster, as if you controlled it. You can only use each effect of "Mextro Dark Empress" once per turn.
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
