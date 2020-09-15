--Chroma-Distortion Revival Angel
function c249000498.initial_effect(c)
	--revive
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,249000498)
	e1:SetCost(c249000498.cost)
	e1:SetTarget(c249000498.target)
	e1:SetOperation(c249000498.operation)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25206027,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c249000498.spcon)
	e2:SetTarget(c249000498.sptg)
	e2:SetOperation(c249000498.spop)
	c:RegisterEffect(e2)
end
function c249000498.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function c249000498.filter(c,e,tp)
	return (c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_XYZ)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c249000498.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c249000498.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c249000498.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c249000498.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c249000498.overlayfilter(c)
	return (not c:IsHasEffect(EFFECT_NECRO_VALLEY)) and (not c:IsType(TYPE_MONSTER))
end
function c249000498.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if tc:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(c249000498.overlayfilter,tp,LOCATION_GRAVE,0,1,nil) then
			local g=Duel.SelectMatchingCard(tp,c249000498.overlayfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.Overlay(tc,g)
			end
		end
	end
end
function c249000498.spfilter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp and c:IsType(TYPE_MONSTER)
end
function c249000498.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c249000498.spfilter,1,nil,tp)
end
function c249000498.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c249000498.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end