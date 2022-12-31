function c1553060.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1553060+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c1553060.target)
	e1:SetOperation(c1553060.activate)
	c:RegisterEffect(e1)
end
function c1553060.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xFA0) and c:IsAbleToGrave()
end
function c1553060.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_HAND) and chkc:IsControler(tp) and c1553060.filter(chkc) end
	if chk==0 then
		local g1=Duel.GetDecktopGroup(tp,3)
		local tc=g1:GetFirst()
		if not tc:IsAbleToHand()
			or not Duel.IsExistingMatchingCard(c1553060.filter,tp,LOCATION_HAND,0,1,nil) then return false end
		local g1=Duel.GetDecktopGroup(tp,3)
		return g1:FilterCount(Card.IsAbleToRemove,nil)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_DECK)
end
function c1553060.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,c1553060.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g2:GetCount()>0 then
		Duel.SendtoGrave(g2,REASON_DISCARD)
		Duel.BreakEffect()
		local g1=Duel.GetDecktopGroup(tp,3)
		Duel.ConfirmCards(1-tp,g1)
		if g1:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=g1:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
			g1:Sub(sg)
			if sg:GetCount()>0 then
				Duel.DisableShuffleCheck()
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
			if g1:GetCount()>0 then
				Duel.DisableShuffleCheck()
				Duel.SendtoHand(g1,nil,REASON_EFFECT)
			end
		end
	end
end
