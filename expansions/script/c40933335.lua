function c40933335.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40933335,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,40933335)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c40933335.spcon)
	e1:SetTarget(c40933335.sptg)
	e1:SetOperation(c40933335.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Banish
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40933335,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,40933334)
	e3:SetCondition(aux.exccon)
	e3:SetCost(c40933335.cost)
	e3:SetTarget(c40933335.target)
	e3:SetOperation(c40933335.operation)
	c:RegisterEffect(e3)
end
function c40933335.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x19)
end
function c40933335.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_BATTLE and eg:IsExists(c40933335.cfilter,1,nil,tp)
end
function c40933335.filter(c,e,tp)
	return c:IsSetCard(0x19) and c:IsCanBeSpecialSummoned(e,130,tp,false,false)
end
function c40933335.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c40933335.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c40933335.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c40933335.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,130,tp,tp,false,false,POS_FACEUP_DEFENSE)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+0x1ff0000,0,0)
	end
end
function c40933335.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c40933335.filter1(c,g)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x19) and c.material and g:IsExists(c40933335.filter2,1,nil,c)
end
function c40933335.filter2(c,fc)
	return c:IsCode(table.unpack(fc.material))
end
function c40933335.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,130,tp,false,false)
end
function c40933335.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c40933335.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingTarget(c40933335.filter1,tp,LOCATION_MZONE,0,1,nil,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectTarget(tp,c40933335.filter1,tp,LOCATION_MZONE,0,1,1,nil,g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,1,0,0)
end
function c40933335.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(c40933335.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,2,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:FilterSelect(tp,c40933335.filter2,1,1,nil,tc)
		Duel.SpecialSummon(sg,130,tp,tp,false,false,POS_FACEUP)
		local tc2=sg:GetFirst()
		tc2:RegisterFlagEffect(tc2:GetOriginalCode(),RESET_EVENT+0x1ff0000,0,0)
	end
end