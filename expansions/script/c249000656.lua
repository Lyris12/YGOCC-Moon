--Guardian-Caller Prodigy
function c249000656.initial_effect(c)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c249000656.tgcon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(506)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,249000656)
	e2:SetTarget(c249000656.starget)
	e2:SetOperation(c249000656.soperation)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c249000656.cost)
	e3:SetTarget(c249000656.target)
	e3:SetOperation(c249000656.operation)
	c:RegisterEffect(e3)
end
function c249000656.tgcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>1
end
function c249000656.searchfilter(c)
	return c:IsSetCard(0x2052) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c249000656.starget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return  Duel.IsExistingMatchingCard(c249000656.searchfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c249000656.soperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c249000656.searchfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_HAND) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c249000656.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function c249000656.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
function c249000656.costfilter(c)
	return c:IsSetCard(0x2052) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
function c249000656.costfilter2(c,e)
	return c:IsSetCard(0x2052) and not c:IsPublic() and c:IsType(TYPE_MONSTER)
end
function c249000656.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000656.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000656.costfilter2,tp,LOCATION_HAND,0,1,c)) end
	local option
	if Duel.IsExistingMatchingCard(c249000656.costfilter2,tp,LOCATION_HAND,0,1,c)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000656.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000656.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000656.costfilter2,tp,LOCATION_HAND,0,1,c) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000656.costfilter2,tp,LOCATION_HAND,0,1,1,c)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000656.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000656.tgfilter1(c,e,tp)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
function c249000656.tgfilter3(c,e,tp,att)
	return c:IsSetCard(0x1052) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c249000656.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000656.tgfilter1,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000656.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,c249000656.tgfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		local ac=Duel.AnnounceCardFilter(tp,0x1052,OPCODE_ISSETCARD,TYPE_FUSION,OPCODE_ISTYPE,OPCODE_AND)
		local sc=Duel.CreateToken(tp,ac)
		Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		sc=Duel.SelectMatchingCard(tp,c249000656.tgfilter2,tp,LOCATION_EXTRA,0,1,1,tc,e,tp,tc:GetOriginalAttribute()):GetFirst()
		if sc then
			if Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2,true)
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
				e3:SetCountLimit(1)
				e3:SetCondition(c249000656.retcon)
				e3:SetOperation(c249000656.retop)
				e3:SetLabel(1)
				sc:RegisterEffect(e3)
			end
			Duel.SpecialSummonComplete()
		end
	end
end
function c249000656.retcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function c249000656.retop(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetLabel()
	if t==1 then e:SetLabel(0)
	else Duel.SendtoDeck(e:GetHandler(),nil,0,REASON_EFFECT) end
end