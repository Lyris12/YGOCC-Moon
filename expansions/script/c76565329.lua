--Ritmi Mistici - Classicalista Celestiale
--Script by XGlitchy30
function c76565329.initial_effect(c)
	aux.AddLinkProcedure(c,nil,2,2,c76565329.lcheck)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x1555)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,76565329)
	e1:SetCost(c76565329.spcost)
	e1:SetTarget(c76565329.sptg)
	e1:SetOperation(c76565329.spop)
	c:RegisterEffect(e1)
end
--filters
function c76565329.lcheck(g)
	return g:GetClassCount(Card.GetLinkRace)==g:GetCount() and g:GetClassCount(Card.GetLinkAttribute)==g:GetCount()
end
function c76565329.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7555) and c:IsType(TYPE_SPELL) and c:IsCanRemoveCounter(c:GetControler(),0x1555,1,REASON_COST)
end
function c76565329.spfilter(c,e,tp)
	return c:IsSetCard(0x7555) and c:GetLevel()>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--spsummon
function c76565329.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76565329.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,c76565329.costfilter,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
	if g and g:IsFaceup() then
		g:RemoveCounter(tp,0x1555,1,REASON_COST)
	end
end
function c76565329.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c76565329.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c76565329.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c76565329.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end