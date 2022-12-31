--Impianto Macchine Deltaingranaggi
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--activate
	c:Activate()
	--ss
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:HOPT()
	e1:SetCondition(aux.AND(aux.MainPhaseCond(0),aux.LocationGroupCond(s.cfilter,LOCATION_MZONE,0)))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--upon being destroyed
	c:DestroyedTrigger(true,1,CATEGORY_SPECIAL_SUMMON,nil,true,aux.ByCardEffect(1),nil,aux.SSTarget(s.spfilter2,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE),aux.SSOperation(s.spfilter2,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE))
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfa6)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xfa6) and c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,c:GetLevel())
end
function s.filter(c,lv)
	return c:IsFaceup() and c:IsSetCard(0xfa6) and c:IsLevel(lv)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.spfilter2(c,e,tp)
	return c:IsSetCard(0xfa6) and c:HasLevel() and c:IsLevelBelow(7)
end