--DSS Hunter
function c249001215.initial_effect(c)
	c:SetUniqueOnField(1,0,249001215)
	--banish
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(2)
	e1:SetCost(c249001215.cost)
	e1:SetTarget(c249001215.target)
	e1:SetOperation(c249001215.operation)
	c:RegisterEffect(e1)
end
function c249001215.rcostfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsSetCard(0x1B7) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function c249001215.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001215.rcostfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249001215.rcostfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249001215.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function c249001215.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001215.rfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA+LOCATION_GRAVE)
end
function c249001215.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249001215.rfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	local tg=g:GetFirst()
	if tg==nil then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c249001215.rmlimit)
	e1:SetLabel(tg:GetAttribute())
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if tg:IsAttribute(ATTRIBUTE_LIGHT) and Duel.IsPlayerCanDraw(tp,1)
		and Duel.SelectYesNo(tp,aux.Stringid(249001215,0)) then
		Duel.BreakEffect()
		local ct=Duel.Draw(tp,1,REASON_EFFECT)
		if ct==0 then return end
		local dc=Duel.GetOperatedGroup():GetFirst()
		if Duel.SelectYesNo(tp,1123) then
			Duel.BreakEffect()
			Duel.Recover(tp,1000,REASON_EFFECT)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
			if g:GetCount()>0 then
				Duel.HintSelection(g)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(-1000)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				g:GetFirst():RegisterEffect(e2)
			end
		end
	end
	if tg:IsAttribute(ATTRIBUTE_DARK) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(249001215,1)) then
		Duel.BreakEffect()
		g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
	if tg:IsAttribute(ATTRIBUTE_FIRE) and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(249001215,2)) then
		Duel.BreakEffect()
		g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			local tc=nil
			local tg=g:GetMinGroup(Card.GetAttack)
			if tg:GetCount()>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local sg=tg:Select(tp,1,1,nil)
				Duel.HintSelection(sg)
				tc=sg:GetFirst()
			else
				tc=tg:GetFirst()
			end
			if Duel.Destroy(tc,REASON_EFFECT)>0 then
				Duel.Damage(1-tp,math.ceil(tc:GetPreviousAttackOnField() / 2),REASON_EFFECT)
			end
		end
	end
	if tg:IsAttribute(ATTRIBUTE_WATER) and Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(249001215,3)) then
		Duel.BreakEffect()
		g=Duel.SelectMatchingCard(tp,aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
	if tg:IsAttribute(ATTRIBUTE_WIND) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) 
		and Duel.SelectYesNo(tp,aux.Stringid(249001215,4)) then
		Duel.BreakEffect()
		g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil,TYPE_SPELL+TYPE_TRAP)
		if g:GetCount()>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	if tg:IsAttribute(ATTRIBUTE_EARTH) and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,0,false,false) 
		and Duel.SelectYesNo(tp,aux.Stringid(249001215,5)) then
		Duel.BreakEffect()
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,0,false,false)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
		Duel.SpecialSummonComplete()
	end
end
function c249001215.rmlimit(e,c,tp,r,re)
	return c:IsAttribute(e:GetLabel()) and c:IsControler(tp) and re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsCode(249001215) and r==REASON_EFFECT
end