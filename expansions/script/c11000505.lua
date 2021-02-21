--Shya Novice
function c11000505.initial_effect(c)
	--atklimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11000505,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,11000505)
	e2:SetCondition(c11000505.condition)
	e2:SetTarget(c11000505.sptg)
	e2:SetOperation(c11000505.spop)
	c:RegisterEffect(e2)
end
function c11000505.condition(e,tp,eg,ep,ev,re,r,rp)
	return (e:GetHandler():IsReason(REASON_COST)
		and (re:GetHandler():IsSetCard(0x1FD) or re:GetHandler():IsCode(11000525)))
		or ((re:GetHandler():IsSetCard(0x1FD) or re:GetHandler():IsCode(11000525)) 
		and bit.band(r,REASON_EFFECT)~=0)
		and not e:GetHandler():IsReason(REASON_BATTLE)
end
function c11000505.spfilter(c,e,tp)
	return c:IsSetCard(0x1FD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11000505.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c11000505.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c11000505.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c11000505.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c11000505.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c11000505.splimit(e,c)
	return not (c:IsSetCard(0x1FD) or c:IsSetCard(0x1F3))
end
