--Astralost Beholder
local ref,id=GetID()
Duel.LoadScript("Astralost.lua")
function ref.initial_effect(c)
	aux.AddCodeList(c,id+1)
	--Ritual
	c:EnableReviveLimit()
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(ref.thcost)
	e1:SetTarget(ref.thtg)
	e1:SetOperation(ref.thop)
	c:RegisterEffect(e1)
	--Protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetOperation(ref.actop)
	c:RegisterEffect(e2)
	--Special Summon
	local e3=Astralost.CreateHealTrigger(c,{id,1})
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(ref.sstg)
	e3:SetOperation(ref.ssop)
	c:RegisterEffect(e3)
end

--Search
function ref.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function ref.thfilter(c)
	return Astralost.Is(c) and c:IsAbleToHand() and not c:IsCode(id)
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleDeck(tp)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
		if g:GetFirst():IsCode(id+1) then Astralost.EachRecover(500) end
	end
end

--Protection
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and Astralost.Is(re:GetHandler()) then
		Duel.SetChainLimit(function(e,rp,tp) return tp==rp or not e:GetHandler():IsOnField() end)
	end
end

--Special Summon
function ref.ssfilter(c,e,tp) return c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function ref.ssgchk(g,c)
	return g:GetClassCount(Card.GetLocation)==#g and g:GetClassCount(Card.GetRace)==#g
		and not g:IsExists(Card.IsRace,1,nil,c:GetRace())
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.GetMatchingGroup(ref.ssfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp):CheckSubGroup(ref.ssgchk,2,2,e:GetHandler())
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.GetMatchingGroup(ref.ssfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp):SelectSubGroup(tp,ref.ssgchk,false,2,2,e:GetHandler())
		if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	end
end
