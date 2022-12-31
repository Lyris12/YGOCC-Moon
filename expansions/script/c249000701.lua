--Arcane-Study Enlightened Sage
function c249000701.initial_effect(c)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31786629,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1,249000701)
	e2:SetCost(c249000701.cost)
	e2:SetTarget(c249000701.target)
	e2:SetOperation(c249000701.operation)
	c:RegisterEffect(e2)
end
function c249000701.costfilter(c)
	return c:IsSetCard(0x1E6) and c:IsAbleToRemoveAsCost()
end
function c249000701.costfilter2(c,e)
	return c:IsSetCard(0x1E6) and not c:IsPublic()
end
function c249000701.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and (Duel.IsExistingMatchingCard(c249000701.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000701.costfilter2,tp,LOCATION_HAND,0,1,c)) end
	local option
	if Duel.IsExistingMatchingCard(c249000701.costfilter2,tp,LOCATION_HAND,0,1,c)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000701.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000701.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000701.costfilter2,tp,LOCATION_HAND,0,1,c) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000701.costfilter2,tp,LOCATION_HAND,0,1,1,c)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000701.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
	Duel.SendtoGrave(c,REASON_COST)
end
function c249000701.tfilter(c,att,race,e,tp)
	return c:IsSetCard(0x1E7) and c:IsAttribute(att) and c:IsRace(race) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function c249000701.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1E6)
		and Duel.IsExistingMatchingCard(c249000701.tfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetOriginalAttribute(),c:GetOriginalRace(),e,tp)
		and Duel.GetLocationCountFromEx(tp,tp,c)>0
end
function c249000701.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c:IsFaceup() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingTarget(c249000701.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,c249000701.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	e:SetLabel(g:GetFirst():GetAttribute())
end
function c249000701.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local att=tc:GetOriginalAttribute()
	local race=tc:GetOriginalRace()
	if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,c249000698.tfilter,tp,LOCATION_EXTRA,0,1,1,nil,att,race,e,tp)
	if sg:GetCount()>0 then
		Duel.BreakEffect()
		Duel.SpecialSummon(sg,0,tp,tp,true,true,POS_FACEUP)
		sg:GetFirst():CompleteProcedure()
	end
end
