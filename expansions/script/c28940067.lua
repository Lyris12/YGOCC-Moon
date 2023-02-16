--Elemerge Contractor, Katahre
Duel.LoadScript("Elemerge.lua")
local ref,id=GetID()
function ref.initial_effect(c)
	--Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(ref.sscost)
	e1:SetTarget(ref.sstg)
	e1:SetOperation(ref.ssop)
	c:RegisterEffect(e1)
	--Recurr
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id,2)
	e2:SetCondition(ref.thcon)
	e2:SetTarget(ref.thtg)
	e2:SetOperation(ref.thop)
	c:RegisterEffect(e2)
end

--Summon
function ref.ssfilter(c,e,tp)
	return Elemerge.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.sscfilter(c,rc,tp)
	return c:IsType(TYPE_FUSION) and Elemerge.Is(c) and (not c:IsPublic())
		and Duel.IsExistingMatchingCard(ref.ssc2filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,rc,c,rc)
end
function ref.ssc2filter(c,fc,rc)
	local g=Group.FromCards(c,rc)
	return ((c:IsLocation(LOCATION_HAND) and c:IsDiscardable()) or c:IsAbleToRemove())
		and (g:IsExists(Elemerge.Is,2,nil) or (g:IsExists(Card.IsRace,1,nil,fc:GetRace())
		and g:IsExists(Card.IsAttribute,1,nil,fc:GetAttribute())))
end
function ref.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (not c:IsPublic())
		and Duel.IsExistingMatchingCard(ref.sscfilter,tp,LOCATION_EXTRA,0,1,nil,c,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local fc=Duel.SelectMatchingCard(tp,ref.sscfilter,tp,LOCATION_EXTRA,0,1,1,nil,c,tp):GetFirst()
	Duel.ConfirmCards(1-tp,Group.FromCards(c,fc))
	e:SetLabelObject(fc)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsDiscardable(REASON_EFFECT)
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and c:IsRelateToEffect(e) and c:IsDiscardable(REASON_EFFECT) then
		local g=Group.CreateGroup()
		g=Duel.SelectMatchingCard(tp,ref.ssc2filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e:GetLabelObject(),c)
		g:AddCard(c)
		if #g==2 then
			Duel.Remove(g:Filter(Card.IsLocation,nil,LOCATION_GRAVE),POS_FACEUP,REASON_EFFECT)
			Duel.SendtoGrave(g:Filter(Card.IsLocation,nil,LOCATION_HAND),REASON_EFFECT+REASON_DISCARD)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #sg>0 then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
		end
	end
end

--Recurr
function ref.thcon(e,tp)
	return Duel.IsExistingMatchingCard(Elemerge.Is,tp,LOCATION_MZONE,0,1,nil)
end
function ref.grfilter(c) return Elemerge.Is(c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave() end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(ref.grfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function ref.thop(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,ref.grfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then Duel.BreakEffect() Duel.SendtoGrave(g,REASON_EFFECT) end
	end
end
