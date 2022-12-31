--Gelatyna Cartografa
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x296),1,1)
	c:EnableReviveLimit()
	--ss
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.hspcost)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
end
function s.cf(c,e,tp)
	return c:IsMonster() and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsDestructable(e,REASON_COST,tp) and e:GetHandler():GetLinkedGroup():IsContains(c)
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetMZoneCount(tp,c)>0)
end
function s.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cf,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,s.cf,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.Destroy(g,REASON_COST)
	end
end
function s.hspfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(0x296) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local check = (e:GetLabel()==1) or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.hspfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end