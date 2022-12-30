--Chaotic Magician
function c249001218.initial_effect(c)
	c:SetUniqueOnField(1,0,249001218)
	--special sunmmon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66499018,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c249001218.spcon)
	e1:SetTarget(c249001218.sptg)
	e1:SetOperation(c249001218.spop)
	c:RegisterEffect(e1)
	--Attribute Light
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e2)
	--discard deck
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c249001218.cost)
	e3:SetTarget(c249001218.target)
	e3:SetOperation(c249001218.operation)
	c:RegisterEffect(e3)
end
function c249001218.spcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetDrawCount(tp)>0
end
function c249001218.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		aux.DrawReplaceCount=0
		aux.DrawReplaceMax=dt
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c249001218.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	aux.DrawReplaceCount=aux.DrawReplaceCount+1
	if aux.DrawReplaceCount<=aux.DrawReplaceMax and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
function c249001218.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsSetCard(0x1B7) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function c249001218.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001218.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249001218.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249001218.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,4) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function c249001218.thfilter(c,t,both)
	if not c:IsAbleToHand() or not c:IsType(TYPE_RITUAL) then return false end
	if both then return c:IsType(TYPE_MONSTER) or c:IsType(TYPE_SPELL) end
	return c:IsType(t)
end
function c249001218.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function c249001218.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.DiscardDeck(tp,4,REASON_EFFECT)
	if ct==0 then return end
	local og=Duel.GetOperatedGroup()
	if og:IsExists(Card.IsType,1,nil,TYPE_MONSTER) and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(249001218,0)) then
		Duel.BreakEffect()
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			local tc=nil
			local tg=g:GetMinGroup(Card.GetAttack)
			if tg:GetCount()>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local sg=tg:Select(tp,1,1,nil)
				Duel.HintSelection(sg)
				tc=sg:GetFirst()
			else
				tc=tg:GetFirst()
			end
			if Duel.Destroy(tc,REASON_EFFECT)>0 then
				Duel.Damage(1-tp,math.ceil(tc:GetPreviousAttackOnField() / 2),REASON_EFFECT)
			end
		end
	end
	if og:IsExists(Card.IsType,1,nil,TYPE_SPELL) and (Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249001218.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,TYPE_MONSTER,false)
		or Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249001218.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,TYPE_SPELL,false)) and Duel.SelectYesNo(tp,aux.Stringid(249001218,1)) then
		Duel.BreakEffect()
		if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE,nil) and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249001218.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,TYPE_MONSTER,false)
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249001218.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,TYPE_SPELL,false) and Duel.SelectYesNo(tp,aux.Stringid(249001218,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001218.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,TYPE_MONSTER,false)
			if g1:GetCount()>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001218.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,TYPE_SPELL,false)
				g1:Merge(g2)
				Duel.SendtoHand(g1,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g1)
			end
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001218.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,TYPE_MONSTER+TYPE_SPELL,true)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if og:IsExists(Card.IsType,1,nil,TYPE_TRAP) and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249001218.setfilter),tp,LOCATION_GRAVE,0,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(249001218,3)) then
		Duel.BreakEffect()
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001218.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc and Duel.SSet(tp,tc)~=0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			tc:RegisterEffect(e1,true)
		end
	end
end