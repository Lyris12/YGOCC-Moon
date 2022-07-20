--Geneseed Cherrybind
local cid,id=GetID()
function cid.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.condition)
	 e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)  
   --act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2) 
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
	   
end
function cid.filter(c)
	return c:IsSetCard(0x57b) and c:IsDiscardable()
end
function cid.cfilter(c)
	return c:IsSetCard(0x57b) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	 if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND,0,1,e:GetHandler()) and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		Duel.DiscardHand(tp,cid.filter,1,1,REASON_COST+REASON_DISCARD)
	end
end
  
	
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)  
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		  Duel.SendtoHand(ec,nil,REASON_EFFECT)
	end
end