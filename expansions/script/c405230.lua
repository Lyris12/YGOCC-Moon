--儀式の下準備
function c405230.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,405230+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c405230.target)
	e1:SetOperation(c405230.activate)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(405230,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,405230)
	e2:SetCondition(aux.exccon)
	e2:SetCost(c405230.spcost)
	e2:SetTarget(c405230.sptg)
	e2:SetOperation(c405230.spop)
	c:RegisterEffect(e2)
end
function c405230.filter2(c,tp,code)
	return (c:IsSetCard(0x55) or c:IsSetCard(0x7b)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		 and not c:IsCode(code)
end
function c405230.filter(c,tp)
	return (c:IsSetCard(0x55) or c:IsSetCard(0x7b)) and c:IsType(TYPE_MONSTER)and c:IsAbleToGrave()
	and Duel.IsExistingMatchingCard(c405230.filter2,tp,LOCATION_DECK,0,1,nil,c:GetCode(),tp)
end
function c405230.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c405230.filter,tp,LOCATION_DECK,0,1,nil,tp) and
	Duel.IsExistingMatchingCard(c405230.filter2,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c405230.activate(e,tp,eg,ep,ev,re,r,rp)
		local g1=Duel.GetMatchingGroup(c405230.filter,tp,LOCATION_DECK,0,nil,tp)
		local g2=Duel.GetMatchingGroup(c405230.filter2,tp,LOCATION_DECK,0,nil,tp)
		if g1:GetCount()>0 and g2:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg1=g1:Select(tp,1,1,nil,tp)
		g2:Remove(Card.IsCode,nil,sg1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg2=g2:Select(tp,1,1,nil,tp)
		Duel.SendtoGrave(sg1,nil,REASON_EFFECT)
		Duel.SendtoHand(sg2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg2)
	end
end
function c405230.cfilter(c)
	return c:IsCode(93717133) and c:IsAbleToRemoveAsCost()
end
function c405230.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(c405230.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c405230.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c405230.spfilter(c,e,tp)
	return c:IsSetCard(0x55) or c:IsSetCard(0x7b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c405230.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c405230.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c405230.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c405230.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end