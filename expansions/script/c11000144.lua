--Shurima
function c11000144.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11000144,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c11000144.sptg)
	e1:SetOperation(c11000144.spop)
	c:RegisterEffect(e1)
	--Field destruction
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11000144,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c11000144.descon)
	e2:SetCost(c11000144.descost)
	e2:SetTarget(c11000144.destg)
	e2:SetOperation(c11000144.desop)
	c:RegisterEffect(e2)
end
function c11000144.spfilter(c,e,tp)
	return c:IsCode(11000130) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
		and (not c:IsLocation(LOCATION_GRAVE) or not c:IsHasEffect(EFFECT_NECRO_VALLEY))
end
function c11000144.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c11000144.spfilter,tp,0x13,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
function c11000144.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c11000144.spfilter,tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		Duel.ShuffleDeck(tp)
	end
end
function c11000144.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c11000144.cfilter,tp,LOCATION_MZONE,0,1,nil,11000130)
		and Duel.IsExistingMatchingCard(c11000144.cfilter,tp,LOCATION_MZONE,0,1,nil,11000131)
		and Duel.IsExistingMatchingCard(c11000144.cfilter,tp,LOCATION_MZONE,0,1,nil,11000132)
end
function c11000144.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function c11000144.desfilter(c)
	return c:IsAbleToGrave()
end
function c11000144.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11000144.desfilter,tp,0,LOCATION_HAND,1,nil) end
	local g=Duel.GetMatchingGroup(c11000144.filter,tp,0,LOCATION_HAND,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function c11000144.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tg=Duel.GetMatchingGroup(c11000144.desfilter,tp,0,LOCATION_HAND,nil)
	if tg:GetCount()>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
