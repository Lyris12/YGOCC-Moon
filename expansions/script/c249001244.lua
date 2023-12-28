--Space Time Gizmo - Wave Sensor
function c249001244.initial_effect(c)
	--excavate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10321588,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c249001244.target)
	e1:SetOperation(c249001244.operation)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5818294,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e2:SetCondition(c249001244.negcon)
	e2:SetCost(c249001244.negcost)
	e2:SetTarget(c249001244.negtg)
	e2:SetOperation(c249001244.negop)
	c:RegisterEffect(e2)
end
function c249001244.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
function c249001244.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsType(TYPE_MONSTER) and tc:IsAbleToHand() then
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ShuffleHand(tp)
	else
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
function c249001244.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsCode(249001241)
end
function c249001244.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c249001244.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function c249001244.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c249001244.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function c249001244.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end 