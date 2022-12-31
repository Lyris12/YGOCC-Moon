--Majestic Mage Knight
function c249000780.initial_effect(c)
	c:SetSPSummonOnce(249000780)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),1)
	--summon success
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c249000780.sumsuc)
	c:RegisterEffect(e1)
	--add spell/trap
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c249000780.stcost)
	e2:SetTarget(c249000780.sttg)
	e2:SetOperation(c249000780.stop)
	c:RegisterEffect(e2)
end
function c249000780.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLP(tp) >= 3000 then return end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTarget(c249000780.tg)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	Duel.RegisterEffect(e2,tp)
	local e1=e2:Clone()
	e1:SetValue(aux.tgoval)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	Duel.RegisterEffect(e1,tp)
end
function c249000780.tg(e,c)
	return c:IsFaceup() and (c:IsType(TYPE_XYZ) or c:IsSetCard(0x3F))
end
function c249000780.stcostfilter1(c)
	return c:IsSetCard(0x103F) and c:IsAbleToRemoveAsCost()
end
function c249000780.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000780.stcostfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249000780.stcostfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249000780.stfilter1(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.IsExistingMatchingCard(c249000780.stfilter2,tp,LOCATION_DECK,0,1,nil,c:GetType())
	and ((c:IsLocation(LOCATION_HAND) and c:IsDiscardable()) or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove()))
end
function c249000780.stfilter2(c,type)
	return c:GetType()==type and c:IsAbleToHand()
end
function c249000780.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000780.stfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c249000780.stop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.SelectMatchingCard(tp,c249000780.stfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g1:GetFirst()
	if g1:GetCount() > 0 and ((tc:IsLocation(LOCATION_HAND) and Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD) ~=0) or (tc:IsLocation(LOCATION_GRAVE) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) ~=0))  then	
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,c249000780.stfilter2,tp,LOCATION_DECK,0,1,1,nil,g1:GetFirst():GetType())
		if g2:GetCount()>0 then
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end