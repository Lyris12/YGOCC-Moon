--created & coded by Lyris, art from Shadowverse's "Craftsman's Pride"
--Hadokenstruction
local s,id,o=GetID()
Card.IsHadoken=Card.IsHadoken or function(c) return c:GetCode()>102400019 and c:GetCode()<102400034 end
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.IsPlayerCanDraw(tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local ct=0
	for i=0,2 do
		local tc=Duel.GetFieldCard(tp,LOCATION_DECK,i)
		for p=0,1 do Duel.ConfirmCards(p,tc,true) end
		if tc:IsHadoken() then ct=ct+1 end
	end
	Duel.Draw(tp,ct,REASON_EFFECT)
	for i=1,3 do Duel.MoveSequence(Duel.GetFieldCard(tp,LOCATION_DECK,0),SEQ_DECKTOP) end
	Duel.SortDecktop(tp,tp,3)
end
function s.filter(c)
	return c:IsFaceupEx() and c:IsHadoken() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	aux.PlaceCardsOnDeckBottom(tp,Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,e:GetHandler()))
end
