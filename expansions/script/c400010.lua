--Untergang Lebenserstarrung
function c400010.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,400010+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c400010.condition)
	e1:SetCost(c400010.cost)
	e1:SetTarget(c400010.target)
	e1:SetOperation(c400010.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(400010,ACTIVITY_SPSUMMON,c400010.counterfilter)
end
function c400010.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
function c400010.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c)return c:IsFaceup() and c:IsSetCard(0x246) end,tp,LOCATION_MZONE,0,1,nil)
end
function c400010.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(400010,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c400010.splimit)
	Duel.RegisterEffect(e1,tp)
end
function c400010.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
function c400010.filter(c,e,tp)
	return c:IsSetCard(0x246) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c400010.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c400010.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
function c400010.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c400010.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,400009,0x246,0x4011,1700,1000,4,RACE_FAIRY,ATTRIBUTE_WATER)
		and Duel.IsExistingMatchingCard(function(c)return c:IsSetCard(0x246) and c:IsType(TYPE_QUICKPLAY) and not c:IsCode(400013) end,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(400010,0)) then
			Duel.BreakEffect()
			local token=Duel.CreateToken(tp,400009)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
