--False Reality Funeral and Rebirth
local s,id=GetID()
function s.initial_effect(c)
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1,id)
		e1:SetCost(s.cost)
		e1:SetTarget(s.target)
		e1:SetOperation(s.activate)
		c:RegisterEffect(e1)
end
	function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
	function s.cfilter(c,e,tp)
	return c:IsSetCard(0x83e) and c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
	function s.filter1(c,e,tp,code)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x83e) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
	function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,code)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabelObject(g:GetFirst())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
	function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,e,tp,sc:GetCode())
	local g0=g:Select(tp,1,1,nil)
	if g0:GetCount()>0 then
		Duel.SpecialSummon(g0,0,tp,tp,false,false,POS_FACEUP)
	end
end