--イラストリアス(μ兵装)

--scripted by Warspite
function c94394044.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94394044,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,94394044)
	e1:SetCost(aux.musecost(3,3,aux.Stringid(94394044,3),c))
	e1:SetTarget(c94394044.sptg)
	e1:SetOperation(c94394044.spop)
	c:RegisterEffect(e1)
	--to grave
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94394044,2))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,94394045)
	e2:SetCondition(c94394044.tgcon)
	e2:SetCost(aux.musecost(1,1,aux.Stringid(94394044,3),nil))
	e2:SetTarget(c94394044.tgtg)
	e2:SetOperation(c94394044.tgop)
	c:RegisterEffect(e2)
end
function c94394044.spfilter(c,e,tp)
	return c:IsSetCard(0x16a) and c:IsType(TYPE_MONSTER) and not c:IsCode(94394044) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c94394044.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c94394044.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c94394044.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) 
		and Duel.SelectYesNo(tp,aux.Stringid(94394044,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c94394044.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c94394044.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function c94394044.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and (not c:IsSummonType(SUMMON_TYPE_NORMAL)) and c:IsAbleToGrave()
end
function c94394044.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c94394044.tgfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function c94394044.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c94394044.tgfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
