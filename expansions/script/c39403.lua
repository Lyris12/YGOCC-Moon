--Dracosis Aquate
function c39403.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c39403.cost)
	e1:SetTarget(c39403.target)
	e1:SetOperation(c39403.operation)
	e1:SetCountLimit(1,39403+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
function c39403.cfilter(c)
	return c:IsSetCard(0x300) and not c:IsPublic()
end
function c39403.sfilter(c,e,tp)
	local race=e:GetLabel()
	return c:IsSetCard(0x300) and (c:GetRace()&race==0)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c39403.cost(e,tp,eg,ep,ev,r,re,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c39403.cfilter,tp,LOCATION_HAND,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c39403.cfilter,tp,LOCATION_HAND,0,2,2,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function c39403.target(e,tp,eg,ep,ev,r,re,rp,chk)
	e:SetLabel(e:GetHandler():GetRace())
	if chk==0 then return Duel.IsExistingMatchingCard(c39403.sfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c39403.operation(e,tp,eg,ep,ev,r,re,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c39403.sfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		if c:IsLocation(LOCATION_DECK) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g1=g:Select(tp,1,1,nil)
			Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
