--Final Will of the Overseer
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.afilter(c)
	return (c:IsFaceup() and c:IsCode(1553110)) or (Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil))
end
function s.bfilter(c)
	return c:IsFaceup() and c:IsCode(1553090)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(1553085)
end
function s.dfilter(c)
	return c:IsFaceup() and c:IsCode(1553120)
end
function s.efilter(c)
	return c:IsCode(1553120)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_ONFIELD,0,1,nil) then return false end
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.efilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil)
		local g2=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_ONFIELD,0,nil)
		if g:GetCount()>0 and g2:GetCount()<=0 and Duel.GetLocationCountFromEx(tp,LOCATION_MZONE)>0 
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

