--Magmeer Misterioso
--Script by XGlitchy30
function c53313931.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--shuffle & draw (+ search)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53313931,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,53313931)
	e1:SetCost(c53313931.sccost)
	e1:SetTarget(c53313931.sctg)
	e1:SetOperation(c53313931.scop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53313931,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c53313931.spcost)
	e2:SetTarget(c53313931.sptg)
	e2:SetOperation(c53313931.spop)
	c:RegisterEffect(e2)
end
--filters
function c53313931.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xcf6) and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function c53313931.sfilter(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(tp)
end
function c53313931.scfilter(c)
	return c:IsSetCard(0xcf6) and c:IsAbleToHand()
end
function c53313931.cfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
function c53313931.spfilter(c,e,tp)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and c:GetLevel()<=7 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--shuffle & draw (+ search)
function c53313931.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c53313931.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(c53313931.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c53313931.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53313931.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
		local tg=Duel.GetOperatedGroup()
		if tg:IsExists(c53313931.sfilter,1,nil,tp) then Duel.ShuffleDeck(tp) end
		local ct=tg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct==tg:GetCount() then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
			if tg:IsExists(Card.IsCode,1,nil,53313901) then
				if Duel.IsExistingMatchingCard(c53313931.scfilter,tp,LOCATION_DECK,0,1,nil) then
					if Duel.SelectYesNo(tp,aux.Stringid(53313931,1)) then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
						local sg=Duel.SelectMatchingCard(tp,c53313931.scfilter,tp,LOCATION_DECK,0,1,1,nil)
						if sg:GetCount()>0 then
							Duel.SendtoHand(sg,nil,REASON_EFFECT)
							Duel.ConfirmCards(1-tp,sg)
						end
					end
				end
			end
		end
	end
end
--spsummon
function c53313931.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313931.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c53313931.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c53313931.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(c53313931.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c53313931.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c53313931.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
	end
end
