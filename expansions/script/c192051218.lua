--coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x617),3,3)
	aux.AddXyzProcedureLevelFree(c,cid.mfilter,cid.xyzcheck,2,2)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cid.spcost)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
end
function cid.mfilter(c,xyzc)
	return c:IsSetCard(0x617) and (c:GetLevel()==3 or c:IsCode(id-8))
end
function cid.xyzcheck(g)
	return g:IsExists(Card.IsCode,1,nil,id-8)
end
function cid.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:GetLevel()==3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false)
	end
end
