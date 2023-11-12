--Future and Past Dragon
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,6,s.sumcon,{s.tlfilter,true})
	c:EnableReviveLimit()
	--Target 1 Level 5 or lower monster in the GYs and 1 card on the field; banish the first target and shuffle the second target into the Deck.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,{id,0})
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--Target 1 banished Level 7 or higher monster; shuffle it into the Deck, and if you do, draw 1 card.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
end
function s.lv5filter(c,check)
	return c:IsLevelBelow(5) and (c:IsAbleToRemove() or not check)
end
function s.lv7filter(c,check)
	return c:IsLevelAbove(7) and (c:IsAbleToDeck() or not check)
end
function s.sumcon(e,c)
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.lv5filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil,false) and
		Duel.IsExistingMatchingCard(s.lv7filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil,false)
end
function s.tlfilter(c,e,mg)
	local tp=c:GetControler()
	local ef=e:GetHandler():GetFuture()
	return (c:IsLevel(ef-1) or c:IsLevel(ef+1)) and c:IsType(TYPE_EFFECT)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and Duel.IsExistingTarget(s.lv5filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,true) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(tp,s.lv5filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,true)
	local rm=g1:GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rm,1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local td=g2:GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_TODECK,td,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local ex1,g1=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
	local rm=g1:GetFirst()
	if not rm:IsRelateToEffect(e) then return end
	if Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)==0 then return end
	local ex2,g2=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	local td=g2:GetFirst()
	if not td:IsRelateToEffect(e) then return end
	Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.lv7filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,true) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.lv7filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,true)
	local td=g1:GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_TODECK,td,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
