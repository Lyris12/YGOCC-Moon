--タシュケント(μ兵装)

--scripted by Warspite
function c81205699.initial_effect(c)
	--tashkent e1
	aux.TashkentProcedure(c,aux.Stringid(81205699,0),81205699,
							aux.Stringid(81205699,3),81205699,c)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81205699,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,81205700)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c81205699.spcon)
	e2:SetTarget(c81205699.sptg)
	e2:SetOperation(c81205699.spop)
	c:RegisterEffect(e2)
end
function c81205699.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsCode(81205699) and re:GetHandler():IsSetCard(0x16a)
end
function c81205699.thfilter(c)
	return c:IsSetCard(0x16a) and not c:IsCode(81205699) and c:IsAbleToHand()
end
function c81205699.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c81205699.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		and Duel.IsExistingMatchingCard(c81205699.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(81205699,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c81205699.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end