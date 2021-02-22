--ミューズアンコールµ

--scripted by Warspite
function c8089720.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,8089720+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c8089720.condition)
	e1:SetCost(aux.musecost(1,1,aux.Stringid(8089720,1),nil))
	e1:SetTarget(c8089720.target)
	e1:SetOperation(c8089720.activate)
	c:RegisterEffect(e1)
end
function c8089720.filter(c)
	return c:IsSetCard(0x16a) and c:IsType(TYPE_MONSTER)
end
function c8089720.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(c8089720.filter,tp,LOCATION_MZONE,0,1,nil) 
end
function c8089720.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c8089720.spfilter(c,e,tp)
	return c:IsSetCard(0x16a) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c8089720.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		and Duel.Destroy(eg,REASON_EFFECT)~=0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c8089720.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) 
		and Duel.SelectYesNo(tp,aux.Stringid(8089720,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c8089720.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end