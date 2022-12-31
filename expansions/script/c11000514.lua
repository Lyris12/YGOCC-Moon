--Past of the Shya
function c11000514.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,0)
	e1:SetCondition(c11000514.condition)
	e1:SetTarget(c11000514.target)
	e1:SetOperation(c11000514.activate)
	c:RegisterEffect(e1)
end
function c11000514.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END and Duel.GetTurnPlayer()==tp
end
function c11000514.filter(c,tid)
	return c:IsSetCard(0x1FD) and c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid and not c:IsReason(REASON_RETURN)
		and c:IsAbleToDeck()
end
function c11000514.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c10537981.filter(chkc,Duel.GetTurnCount()) end
	if chk==0 then return Duel.IsExistingTarget(c11000514.filter,tp,LOCATION_GRAVE,0,1,nil,Duel.GetTurnCount()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c11000514.filter,tp,LOCATION_GRAVE,0,99,99,nil,Duel.GetTurnCount())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c11000514.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		if Duel.SendtoDeck(sg,nil,2,REASON_EFFECT) then
			Duel.ShuffleDeck(tp)
			Duel.BreakEffect()
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
end