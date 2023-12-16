--Gale Barrier
function c249001063.initial_effect(c)
	aux.AddCodeList(c,249001056)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c249001063.condition)
	e1:SetTarget(c249001063.target)
	e1:SetOperation(c249001063.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c249001063.handcon)
	c:RegisterEffect(e2)
end
function c249001063.cfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:GetControler()==tp
end
function c249001063.cfilter2(c)
	return c:IsPosition(POS_FACEUP) and c:IsCode(249001056)
end
function c249001063.condition(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not Duel.IsExistingMatchingCard(c249001063.cfilter2,tp,LOCATION_ONFIELD,0,1,nil) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(c249001063.cfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function c249001063.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function c249001063.activate(e,tp,eg,ep,ev,re,r,rp)
	if 	Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
	and Duel.SelectYesNo(tp,505) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.HintSelection(g)
		Duel.SendToHand(g,nil,REASON_EFFECT)
	end
end
function c249001063.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)<Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)
end