--Dracosis Evolutionary Plane
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--boost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x300))
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--special summon
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_TO_GRAVE,s.spcfilter,id,LOCATION_FZONE)
	local e4=Effect.CreateEffect(c)
	e4:Desc(1)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetRange(LOCATION_FZONE)
	e4:HOPT(true)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--tohand
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:HOPT(true)
	e3:SetCost(s.cost2)
	e3:SetTarget(s.target2)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
--FE4
function s.spcfilter(c,_,tp)
	return c:GetPreviousControler()==tp and c:IsPreviousSetCard(0x300) and c:IsSetCard(0x300)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsReason(REASON_DESTROY)
end
function s.spcfilter2(c,e,tp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetRace())
end
function s.filter(c,e,tp,race)
	return c:IsSetCard(0x300) and c:GetRace()&race==0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E4
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local sg=eg:Filter(s.spcfilter2,nil,e,tp)
	local tc
	if #sg<=0 then
		return
	elseif #sg==1 then
		tc=sg:GetFirst()
	else
		Duel.HintMessage(tp,HINTMSG_OPERATECARD)
		tc=sg:Select(tp,1,1,nil):GetFirst()
	end
	if not tc then return end
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetRace())
	if #tg>0 then
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end

--FE5
function s.cfilter(c)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
function s.afilter(c)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
--E5
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.afilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end
