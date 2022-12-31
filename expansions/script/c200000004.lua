--Naval Gears - Z19
local cid,id=GetID()
function cid.initial_effect(c)
--If summon, summon from hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66809920,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(cid.sumtg)
	e2:SetOperation(cid.sumop)
	c:RegisterEffect(e2)
	--if in back row and card set, sp summon and destroy set
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(16898077,2))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_MSET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(cid.accon1)
	e5:SetTarget(cid.sptg)
	e5:SetOperation(cid.spop)
	c:RegisterEffect(e5)
	local e1=e5:Clone()
	e1:SetCode(EVENT_SSET)
	c:RegisterEffect(e1)
	local e3=e5:Clone()
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetCondition(cid.accon2)
	c:RegisterEffect(e3)
	local e4=e5:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(cid.accon3)
	c:RegisterEffect(e4)
end
--if in back row and card set, sp summon and destroy set
function cid.accon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(tp) or eg:GetFirst():IsControler(1-tp)
end
function cid.filter2(c,tp)
	return (c:IsControler(tp) or c:IsControler(1-tp)) and bit.band(c:GetPreviousPosition(),POS_FACEUP)~=0 and bit.band(c:GetPosition(),POS_FACEDOWN)~=0
end
function cid.accon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.filter2,1,nil,tp)
end
function cid.filter3(c,tp)
	return (c:IsControler(tp) or c:IsControler(1-tp)) and c:IsFacedown()
end
function cid.accon3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.filter3,1,nil,tp)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	if not c:IsRelateToEffect(e) then return end
	 if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
	 if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT)	 
end
end
end
--If summon, summon from hand
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x700) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4) and not c:IsCode(id)
end
function cid.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cid.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
end