--created by Swag
--Deep, Deep in the Dreary Forest's Maze
local s,id,o=GetID()
function s.initial_effect(c)
	--You can only activate 1 "Deep, Deep in the Dreary Forest's Maze" per turn. During your opponent's turn: Target 1 monster your opponent controls with less ATK than the highest ATK or DEF (whichever is higher) among "Dreamy Forest" and "Dreary Forest" monsters you control; equip it to a "Dreamy Forest" or "Dreary Forest" monster you control as an Equip Spell with the following effects: ●If this card is equipped to a "Dreamy Forest" monster, your opponent cannot activate cards, or the effects of cards, with the same name as this card during your turn. If this card is equipped to a "Dreary Forest" monster, your opponent cannot activate cards, or the effects of cards, with the same name as this card during their turn.
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
