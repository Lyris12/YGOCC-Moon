--Sands Rammus
function c11000136.initial_effect(c)
	c:EnableUnsummonable()
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11000136,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,11000136)
	e2:SetCondition(c11000136.spcon2)
	e2:SetTarget(c11000136.sptg2)
	e2:SetOperation(c11000136.spop2)
	c:RegisterEffect(e2)
end
function c11000136.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function c11000136.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c11000136.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end