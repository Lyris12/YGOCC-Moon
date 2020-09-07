--Sunken Variamori
function c111765871.initial_effect(c)
 --banishing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(111765871,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c111765871.dkcon)
	e1:SetTarget(c111765871.dktg)
	e1:SetOperation(c111765871.dkop)
	e1:SetCountLimit(2,111765871)
	c:RegisterEffect(e1)
--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(111765871,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCountLimit(1,111765872)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c111765871.spcon1)
	e2:SetTarget(c111765871.sptg1)
	e2:SetOperation(c111765871.spop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e3)
end
--banishing
function c111765871.dkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c111765871.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp-1,LOCATION_DECK)
end
function c111765871.dkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetDecktopGroup(1-tp,2)
	Duel.DisableShuffleCheck()
	Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
end
--special summmon
function c111765871.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
function c111765871.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c111765871.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end