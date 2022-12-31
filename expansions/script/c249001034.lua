--Ninjistu Art of Summoning
function c249001034.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,249001034+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c249001034.condition)
	e1:SetTarget(c249001034.target)
	e1:SetOperation(c249001034.activate)
	c:RegisterEffect(e1)
end
function c249001034.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2B)
end
function c249001034.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001034.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c249001034.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2B) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c249001034.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c249001034.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function c249001034.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249001034.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
