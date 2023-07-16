--Dracosis Aquate
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsSetCard(0x300) and not c:IsPublic()
end
function s.sfilter(c,e,tp,race)
	return c:IsSetCard(0x300) and not c:IsRace(race) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cost(e,tp,eg,ep,ev,r,re,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,2,2,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.target(e,tp,eg,ep,ev,r,re,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetRace()) end
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,r,re,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsControler(tp) then return end
	local race=c:GetRace()
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK,0,nil,e,tp,race)
	if #g>0 and Duel.ShuffleIntoDeck(c) then
		g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK,0,nil,e,tp,race)
		if #g<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=g:Select(tp,1,1,nil)
		if #g1>0 then
			Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
