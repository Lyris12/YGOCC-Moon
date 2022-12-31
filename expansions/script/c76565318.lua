--Ritmi Mistici - Arpista Angelico
--Script by XGlitchy30
function c76565318.initial_effect(c)
	c:EnableCounterPermit(0x1555)
	--remove counters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,76565318)
	e1:SetTarget(c76565318.target)
	e1:SetOperation(c76565318.operation)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1x)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,76165318)
	e2:SetCost(c76565318.spcost)
	e2:SetTarget(c76565318.sptg)
	e2:SetOperation(c76565318.spop)
	c:RegisterEffect(e2)
end
--filters
function c76565318.gfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x7555)
end
function c76565318.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x7555) and c:IsCanRemoveCounter(c:GetControler(),0x1555,1,REASON_EFFECT)
end
function c76565318.costfilter(c)
	return c:IsSetCard(0x7555) and c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsCanRemoveCounter(c:GetControler(),0x1555,1,REASON_COST)
end
function c76565318.spfilter(c,e,tp)
	return c:IsSetCard(0x7555) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--remove counters
function c76565318.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroupCount(c76565318.gfilter,tp,LOCATION_SZONE,0,nil)
	local ct=Duel.GetMatchingGroupCount(c76565318.filter,tp,LOCATION_SZONE,0,nil)
	if chk==0 then return ct>0 and ct==g end
end
function c76565318.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroup(c76565318.filter,tp,LOCATION_SZONE,0,nil)
	for rm in aux.Next(ct) do
		if rm:IsCanRemoveCounter(tp,0x1555,1,REASON_EFFECT) then
			rm:RemoveCounter(tp,0x1555,1,REASON_EFFECT)
		end
	end
end
--spsummon
function c76565318.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76565318.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,c76565318.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	if g:GetCount()>0 then
		g:GetFirst():RemoveCounter(tp,0x1555,1,REASON_COST)
	end
end
function c76565318.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c76565318.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c76565318.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c76565318.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end