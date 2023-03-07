--created by Seth, coded by Lyris
--Mextro Gathering
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(aux.SearchTarget(s.filter))
	e1:SetOperation(aux.SearchOperation(s.filter))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsSetCard(0xee5) and c:IsType(TYPE_MONSTER)
end
function s.dfilter(c)
	return s.filter(c) and c:IsAbleToDeck()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_GRAVE,0,5,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_GRAVE,0,5,5,nil)
	if #g<5 then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if g:IsExists(Card.IsLocation,5,nil,LOCATION_DECK+LOCATION_EXTRA) then
		if g:IsExists(Card.IsLocation,5,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
