--Infinite Gem- Reality
function c249000937.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c249000937.condition)
	e1:SetCost(c249000937.cost)
	e1:SetTarget(c249000937.target)
	e1:SetOperation(c249000937.activate)
	c:RegisterEffect(e1)
end
function c249000937.confilter(c)
	return c:IsSetCard(0x47)
end
function c249000937.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c249000937.confilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>2
end
function c249000937.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function c249000937.filter4(c,e,tp)
	if not (c:GetLevel() > 0) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	local mg=Duel.GetMatchingGroup(c249000937.filter5,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil)
	return mg:CheckWithSumGreater(Card.GetLevel,c:GetLevel(),c)
end
function c249000937.filter5(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
function c249000937.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then	return Duel.IsExistingMatchingCard(c249000937.filter4,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000937.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(c249000937.filter5,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,c249000937.filter4,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=tg:GetFirst()
	if tc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local mat=mg:SelectWithSumGreater(tp,Card.GetLevel,tc:GetLevel(),tc)	
		Duel.Remove(mat,POS_FACEUP,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end