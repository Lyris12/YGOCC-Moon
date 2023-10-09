--Headmasters of Sunpolish Academy
local ref,id=GetID()
Duel.LoadScript("Sunhew.lua")
function ref.initial_effect(c)
	aux.AddLinkProcedure(c,nil,2,2,ref.matgfilter)
	--Set
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e1:SetTarget(ref.settg)
	e1:SetOperation(ref.setop)
	c:RegisterEffect(e1)
	--Search
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetTarget(ref.thtg)
	e3:SetOperation(ref.thop)
	c:RegisterEffect(e3)
end
function ref.matgfilter(g) return g:IsExists(Sunhew.Is,1,nil) end

--Set
function ref.setfilter(c,e,tp)
	if not Sunhew.Is(c) then return false end
	if c:IsType(TYPE_MONSTER) then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	else
		return (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and c:IsSSetable(true)
	end
end
function ref.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.setfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function ref.setop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,ref.setfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		if tc:IsType(TYPE_MONSTER) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SSet(tp,tc)
		end
	end
end

--Search
function ref.thfilter(c,tp)
	return Sunhew.Is(c) and c:IsType(TYPE_DRIVE) and c:IsAbleToHand() and c:IsCanEngage(tp)
end
function ref.opfilter(c)
	return (c:IsLocation(LOCATION_HAND) and c:IsDiscardable(REASON_EFFECT)) or c:IsAbleToRemove()
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.opfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function ref.thop(e,tp)
	local cc=Duel.SelectMatchingCard(tp,ref.opfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	local opt=2
	if not (cc:IsLocation(LOCATION_ONFIELD) or cc:IsAbleToRemove()) then opt=0 end
	if not cc:IsLocation(LOCATION_HAND) then opt=1 end
	if opt==2 then opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) end
	local op=0
	if opt==0 then op=Duel.SendtoGrave(cc,REASON_EFFECT+REASON_DISCARD)
	else op=Duel.Remove(cc,POS_FACEUP,REASON_EFFECT) end
	if op>0 and Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil,tp)
	and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #g>0 then Duel.SearchAndEngage(g:GetFirst(),e,tp,true) end
	end
end

--Float
function ref.sscon(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE)
end
function ref.ssfilter(c,e,tp)
	return Sunhew.Is(c) and c:IsRace(RACE_ROCK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingTarget(ref.ssfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(ref.ssfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
