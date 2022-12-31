--Dracosis Myst
function c39404.initial_effect(c)
	c:SetSPSummonOnce(39404)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c39404.condition)
	e1:SetCost(c39404.cost)
	e1:SetTarget(c39404.target)
	e1:SetOperation(c39404.operation)
	c:RegisterEffect(e1)
end
function c39404.condition(e,tp,eg,ep,ev,r,re,rp)
	return bit.band(Duel.GetCurrentPhase(),PHASE_MAIN1+PHASE_MAIN2)~=0
end
function c39404.sfilter1(c,e,tp)
	return c:IsSetCard(0x300) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(39404)
		and Duel.IsExistingMatchingCard(c39404.sfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function c39404.sfilter2(c,e,tp,cc)
	local race,att=cc:GetRace(),cc:GetAttribute()
	return c:IsSetCard(0x300) and (c:GetRace()&race==0) and (c:GetAttribute()&att==0) and not c:IsCode(39404)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c39404.filter(c)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER)
end
function c39404.cost(e,tp,eg,ep,ev,r,re,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c39404.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c39404.filter,tp,LOCATION_HAND,0,1,1,nil)
	g:AddCard(e:GetHandler())
	if g:FilterCount(function(c) return not c:IsPublic() end,nil)>0 then
		Duel.ConfirmCards(1-tp,g:Filter(function(c) return not c:IsPublic() end,nil))
	end
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function c39404.target(e,tp,eg,ep,ev,r,re,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c39404.sfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function c39404.operation(e,tp,eg,ep,ev,r,re,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local g=Duel.SelectMatchingCard(tp,c39404.sfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	g:AddCard(Duel.SelectMatchingCard(tp,c39404.sfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,g:GetFirst()):GetFirst())
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local atk=(g:GetSum(Card.GetAttack))/2
		local def=(g:GetSum(Card.GetDefense))/2
		if atk>def then Duel.SetLP(Duel.GetTurnPlayer(),Duel.GetLP(Duel.GetTurnPlayer())-atk) Duel.SetLP(1-Duel.GetTurnPlayer(),Duel.GetLP(1-Duel.GetTurnPlayer())-atk) end
		if atk<def then Duel.Recover(Duel.GetTurnPlayer(),def,REASON_EFFECT) Duel.Recover(1-Duel.GetTurnPlayer(),def,REASON_EFFECT) end
		if atk==def then
			local op=Duel.SelectOption(Duel.GetTurnPlayer(),aux.Stringid(39404,0),aux.Stringid(39404,1))
			if op==0 then Duel.SetLP(Duel.GetTurnPlayer(),Duel.GetLP(Duel.GetTurnPlayer())-atk) Duel.SetLP(1-Duel.GetTurnPlayer(),Duel.GetLP(1-Duel.GetTurnPlayer())-atk) end
			if op==1 then Duel.Recover(Duel.GetTurnPlayer(),def,REASON_EFFECT) Duel.Recover(1-Duel.GetTurnPlayer(),def,REASON_EFFECT) end
		end
	end
end
