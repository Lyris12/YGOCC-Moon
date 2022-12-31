--Steinitz's Castling
--Keddy was here~
local function ID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
--[[Target 2 "Steinitz" monsters in your Main Monster Zone that do not have opponent's monsters in their columns; switch their locations, and if you do, 
they're unaffected by your opponent's card effects until the end of this turn. You can only activate 1 "Steinitz's Castling" per turn.]]
local id,cod=ID()
function cod.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cod.target)
	e1:SetOperation(cod.activate)
	c:RegisterEffect(e1)
end
function cod.colfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1-tp)
end
function cod.cfilter(c,tp)
	local g=c:GetColumnGroup()
	local og=g:FilterCount(cod.colfilter,nil,tp)
	return c:IsFaceup() and c:IsSetCard(0x63d0) and og==0 and c:GetSequence()<5
		and Duel.IsExistingMatchingCard(cod.cfilter2,tp,LOCATION_MZONE,0,1,c,tp)
end
function cod.cfilter2(c,tp)
	local g=c:GetColumnGroup()
	local og=g:FilterCount(cod.colfilter,nil,tp)
	return c:IsFaceup() and c:IsSetCard(0x63d0) and og==0 and c:GetSequence()<5
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g1=Duel.SelectMatchingCard(tp,cod.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g2=Duel.SelectMatchingCard(tp,cod.cfilter2,tp,LOCATION_MZONE,0,1,1,g1,tp)
	local g3=g1+g2
	Duel.SetTargetCard(g3)
end
function cod.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	Duel.SwapSequence(tc1,tc2)
end