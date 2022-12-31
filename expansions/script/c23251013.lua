--Primarch of the Desert
local id,cod=23251013,c23251013
function cod.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cod.spcon)
	e1:SetOperation(cod.spop)
	c:RegisterEffect(e1)
end
function cod.spfilter(c,code)
	return c:IsCode(code) and c:IsAbleToRemoveAsCost()
end
function cod.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,23251001)
		and Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,23251002)
end
function cod.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,cod.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,23251001)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,cod.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,23251002)
	g1:Merge(g2)
	if Duel.Remove(g1,POS_FACEUP,REASON_COST) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end