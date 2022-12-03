--Magical Pendulum Art - Repulsion Barrier
function c249001206.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c249001206.condition)
	e1:SetTarget(c249001206.target)
	e1:SetOperation(c249001206.activate)
	c:RegisterEffect(e1)
end
function c249001206.cfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:GetControler()==tp
end
function c249001206.cfilter2(c)
	return c:IsPosition(POS_FACEUP) and c:IsSetCard(0x98)
end
function c249001206.condition(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not Duel.IsExistingMatchingCard(c249001206.cfilter2,tp,LOCATION_MZONE,0,1,nil) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(c249001206.cfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function c249001206.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c249001206.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		if Duel.Destroy(eg,REASON_EFFECT) then
			if Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil)
				and Duel.SelectYesNo(tp,507) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
				local g=Duel.SelectMatchingCard(tp,IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
				Duel.HintSelection(g)
				Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end