--Mage-Core of Rebirth
function c249001263.initial_effect(c)
	aux.EnableDualAttribute(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(249001263,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,249001263)
	e1:SetCondition(c249001263.condition)
	e1:SetCost(c249001263.cost)
	e1:SetTarget(c249001263.target)
	e1:SetOperation(c249001263.operation)
	c:RegisterEffect(e1)
end
function c249001263.cfilter(c)
	return c:IsFaceup() and c:IsCode(249001261)
end
function c249001263.condition(e,tp,eg,ep,ev,re,r,rp)
	return aux.IsDualState(e) and Duel.IsExistingMatchingCard(c249001263.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c249001263.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function c249001263.filter(c,e,sp)
	return not c:IsCode(249001263) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
function c249001263.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c249001263.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingTarget(c249001263.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c249001263.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c249001263.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
