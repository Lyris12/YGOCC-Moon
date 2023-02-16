--Elemerge Slide Change
Duel.LoadScript("Elemerge.lua")
local ref,id=GetID()
function ref.initial_effect(c)
	--Swap
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(ref.sstg)
	e1:SetOperation(ref.ssop)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(ref.thtg)
	e2:SetOperation(ref.thop)
	c:RegisterEffect(e2)
end

--Swap
function ref.tdfilter(c,e,tp)
	local ft=0
	if c:IsLocation(LOCATION_MZONE) then ft=-1 end
	return c:IsAbleToExtra() and (Duel.GetLocationCount(tp,LOCATION_MZONE,0)>ft)
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttribute())
end
function ref.ssfilter(c,e,tp,att)
	return Elemerge.Is(c) and c:IsType(TYPE_FUSION) and (not c:IsAttribute(att)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.tdfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToExtra,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,ref.tdfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		local res=g:GetFirst():IsLocation(LOCATION_GRAVE)
		local att=g:GetFirst():GetAttribute()
		if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,att)
			if #sg>0 then
				Duel.BreakEffect()
				if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 and res then
					local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
					if #tg>0 then Duel.SendtoGrave(tg,REASON_EFFECT) end
				end
			end
		end
	end
end

--Search
function ref.thfilter(c)
	return Elemerge.Is(c) and c:IsAbleToHand()
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then Duel.ConfirmCards(1-tp,g) end
end
