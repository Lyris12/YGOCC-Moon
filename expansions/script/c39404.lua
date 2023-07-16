--Dracosis Mystraid
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(aux.MainPhaseCond())
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	c:RegisterEffect(e1)
end
function s.sfilter1(c,e,tp)
	return c:IsSetCard(0x300) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
		and Duel.IsExistingMatchingCard(s.sfilter2,tp,LOCATION_DECK,0,1,c,e,tp,c)
end
function s.sfilter2(c,e,tp,cc)
	local race,att=cc:GetRace(),cc:GetAttribute()
	return c:IsSetCard(0x300) and not c:IsRace(race) and not c:IsAttribute(att) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter(c)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,r,re,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	g:AddCard(c)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g:Filter(Card.IsLocation,nil,LOCATION_HAND))
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,r,re,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,r,re,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	Duel.HintMessage(tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.sfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g1>0 then
		local tc1=g1:GetFirst()
		Duel.HintMessage(tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.sfilter2,tp,LOCATION_DECK,0,1,1,tc1,e,tp,tc1)
		if #g2>0 then
			g1:Merge(g2)
			if Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)>0 then
				local atk, def = (g1:GetSum(Card.GetAttack))/2, (g1:GetSum(Card.GetDefense))/2
				local op=aux.Option(tp,id,0,atk>=def,def>=atk)
				if not op then return end
				local p=Duel.GetTurnPlayer()
				if op==0 then
					Duel.BreakEffect()
					Duel.SetLP(p,math.ceil(Duel.GetLP(p)-atk))
					Duel.SetLP(1-p,math.ceil(Duel.GetLP(1-p)-atk))
				elseif op==1 then
					Duel.BreakEffect()
					Duel.Recover(p,math.ceil(def),REASON_EFFECT,true)
					Duel.Recover(1-p,math.ceil(def),REASON_EFFECT,true)
					Duel.RDComplete()
				end
			end
		end
	end
end