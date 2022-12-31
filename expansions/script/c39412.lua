--Dracosis Evolutionary Plane
function c39412.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--boost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x300))
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(61654098,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,39412+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(c39412.spcon)
	e4:SetTarget(c39412.sptg)
	e4:SetOperation(c39412.spop)
	c:RegisterEffect(e4)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35419032,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c39412.cost2)
	e3:SetTarget(c39412.target2)
	e3:SetOperation(c39412.operation)
	e4:SetCountLimit(1,39413+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e3)
end
function c39412.spcfilter(c,tp,rp,e)
	return c:GetPreviousControler()==tp and c:IsPreviousSetCard(0x300) and c:IsType(TYPE_MONSTER)
		and (c:IsReason(REASON_BATTLE) or (rp~=tp and c:IsReason(REASON_EFFECT)))
		and Duel.IsExistingMatchingCard(c39412.filter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetRace())
end
function c39412.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39412.spcfilter,1,nil,tp,rp,e)
end
function c39412.filter(c,e,tp,race)
	return c:IsSetCard(0x300) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetRace()&race==0
end
function c39412.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and chkc:IsControler(tp) and c39412.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0,LOCATION_DECK)
end
function c39412.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local sg=eg:Filter(c39412.spcfilter,nil,tp,rp,e)
	if sg:GetCount()==1 then tc=sg:GetFirst() elseif sg:GetCount()>1 then tc=sg:Select(tp,1,1,nil):GetFirst() end
	if not tc then return end
	local tg=Duel.SelectMatchingCard(tp,c39412.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetRace())
	if tg:GetCount()>0 then
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c39412.cfilter(c)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
function c39412.afilter(c)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c39412.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c39412.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c39412.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	if not g:GetFirst():IsPublic() then
		Duel.ConfirmCards(1-tp,g)
	end
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function c39412.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c39412.afilter),tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c39412.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39412.afilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
