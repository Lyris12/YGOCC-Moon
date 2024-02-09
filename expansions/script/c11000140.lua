--Ascencion
function c11000140.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1c0)
	e1:SetTarget(c11000140.target)
	e1:SetOperation(c11000140.activate)
	c:RegisterEffect(e1)
end
function c11000140.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1F6) and not c:IsCode(11000130)
end
function c11000140.cfilter(c,e,sp)
	return c:IsCode(11000130) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c11000140.vfilter(c)
	return c:IsCode(11000147) and c:IsSSetable()
end
function c11000140.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c11000140.filter(chkc,e) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.CheckReleaseGroup(tp,c11000140.filter,1,nil,e)
		and Duel.IsExistingMatchingCard(c11000140.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	local g=Duel.SelectReleaseGroup(tp,c11000140.filter,1,1,nil,e)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c11000140.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		if Duel.Release(tc,REASON_EFFECT)==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c11000140.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if sg:GetCount()==0 then return end
		Duel.BreakEffect()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			local g=Duel.SelectMatchingCard(tp,c11000140.vfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
		Duel.ConfirmCards(1-tp,g)
		end
	end
end