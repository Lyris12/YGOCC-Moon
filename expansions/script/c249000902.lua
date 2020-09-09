--Fusion-Transcender Sage
function c249000902.initial_effect(c)
	--summon success
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63977008,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c249000902.sumtg)
	e1:SetOperation(c249000902.sumop)
	c:RegisterEffect(e1)
	--chain material esque effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e2:SetCost(c249000902.cost)
	e2:SetOperation(c249000902.op)
	c:RegisterEffect(e2)
end
function c249000902.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function c249000902.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c249000902.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c249000902.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c249000902.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c249000902.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end
function c249000902.costfilter(c)
	return c:IsCode(249000900) and not c:IsPublic()
end
function c249000902.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000902.costfilter,tp,LOCATION_HAND,0,1,nil) and e:GetHandler():IsAbleToGraveAsCost() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c249000902.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function c249000902.op(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(58199906,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHAIN_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c249000902.chain_target)
	e1:SetOperation(c249000902.chain_operation)
	e1:SetValue(aux.TRUE)
	Duel.RegisterEffect(e1,tp)
end
function c249000902.filter2(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function c249000902.chain_target(e,te,tp)
	return Duel.GetMatchingGroup(c249000902.filter2,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,nil,te)
end
function c249000902.chain_operation(e,te,tp,tc,mat,sumtype)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,POS_FACEUP)
	e:Reset()
end
