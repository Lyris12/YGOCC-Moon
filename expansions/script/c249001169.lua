--Dark Caller
function c249001169.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetDescription(aux.Stringid(51960178,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c249001169.cost)
	e1:SetTarget(c249001169.target)
	e1:SetOperation(c249001169.operation)
	c:RegisterEffect(e1)
end
function c249001169.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c249001169.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001169.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c249001169.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	if dc:IsType(TYPE_MONSTER) and c:IsRelateToEffect(e)
	and Duel.SelectYesNo(tp,526) then
		Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,dc)
		Duel.ShuffleHand(tp)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(800)
		c:RegisterEffect(e1)
	elseif dc:IsType(TYPE_SPELL) and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249001169.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
	and Duel.SelectYesNo(tp,526) then
		Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,dc)
		Duel.ShuffleHand(tp)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001169.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	Duel.SpecialSummonComplete()
	elseif dc:IsType(TYPE_TRAP) and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	and Duel.SelectYesNo(tp,526) then
		Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,dc)
		Duel.ShuffleHand(tp)
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		local tc=g:GetFirst()
		if tc then Duel.Destroy(tc,REASON_EFFECT) end
	end
end