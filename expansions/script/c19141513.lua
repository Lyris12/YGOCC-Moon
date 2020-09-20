--created by Windy Gurls, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.op)
	c:RegisterEffect(e2)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1015,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x1015,2,REASON_COST)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsSetCard,Card.IsAbleToHand),tp,LOCATION_DECK,0,1,nil,0xa40) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,sp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsSetCard,Card.IsAbleToHand),tp,LOCATION_DECK,0,1,1,nil,0xa40)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,0x1015,1)
	if chk==0 then return #g>1 or g:IsExists(Card.IsCanAddCounter,1,nil,0x1015,2) end
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,0x1015,1)
	if not (#g>1 or g:IsExists(Card.IsCanAddCounter,1,nil,0x1015,2)) then return end
	for i=1,2 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
		g:Select(tp,1,1,nil):GetFirst():AddCounter(0x1015,1)
	end
end
