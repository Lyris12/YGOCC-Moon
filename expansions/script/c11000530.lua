--Shya Return Fire
function c11000530.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11000530+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c11000530.cost)
	e1:SetTarget(c11000530.target)
	e1:SetOperation(c11000530.activate)
	c:RegisterEffect(e1)
end
function c11000530.cfilter(c,tp)
	return c:IsSetCard(0x1F3) and (c:IsControler(tp) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_XYZ)
end
function c11000530.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c11000530.cfilter,1,nil,tp) end
	local sg=Duel.SelectReleaseGroup(tp,c11000530.cfilter,1,1,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function c11000530.filter(c,e,tp)
	return c:IsSetCard(0x1FD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11000530.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c11000530.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c11000530.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c11000530.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end