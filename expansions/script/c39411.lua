--Dracosis Trade-Out
function c39411.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c39411.condition)
	e1:SetTarget(c39411.cost)
	e1:SetTarget(c39411.target)
	e1:SetOperation(c39411.operation)
	e1:SetCountLimit(2,39411+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
function c39411.cfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER)
end
function c39411.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39411.cfilter,1,nil)
end
function c39411.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,39411)==0 end
	Duel.RegisterFlagEffect(tp,39411,RESET_CHAIN,0,1)
end
function c39411.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c39411.filter(c)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c39411.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c39411.filter,tp,LOCATION_DECK,0,nil)
	if g and not (g:GetCount()>0) then return end
	local tc=g:Select(tp,1,1,nil)
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
