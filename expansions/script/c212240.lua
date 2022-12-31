--Wondertain Wondershot
function c212240.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetCountLimit(1,212240)
	e1:SetTarget(c212240.target)
	e1:SetOperation(c212240.activate)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,212241)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c212240.thtg)
	e2:SetOperation(c212240.thop)
	c:RegisterEffect(e2)
end
function c212240.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c212240.cfilter(c)
	return c:IsSetCard(0x244d) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
function c212240.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(c212240.cfilter,tp,LOCATION_ONFIELD,0,c)
	if chk==0 then return ct>0
		and Duel.IsExistingMatchingCard(c212240.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,c) end
	local g=Duel.GetMatchingGroup(c212240.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
function c212240.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(c212240.cfilter,tp,LOCATION_ONFIELD,0,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c212240.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,c)
	Duel.Destroy(g,REASON_EFFECT)
end
function c212240.thfilter(c)
	return c:IsLocation(LOCATION_REMOVED) and c:IsFaceup() and c:IsSetCard(0x244d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c212240.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c212240.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function c212240.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c212240.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end