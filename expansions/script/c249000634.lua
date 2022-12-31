--Takina the Temporal Mage
function c249000634.initial_effect(c)
	c:SetUniqueOnField(1,0,249000634)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--rewind
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,2490006341)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c249000634.cost)
	e1:SetTarget(c249000634.target)
	e1:SetOperation(c249000634.operation)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12298909,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,2490006342)
	e2:SetCondition(c249000634.discon)
	e2:SetCost(c249000634.discost)
	e2:SetTarget(c249000634.distg)
	e2:SetOperation(c249000634.disop)
	c:RegisterEffect(e2)
	--pzone destroy
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(c249000634.skcon)
	e3:SetTarget(c249000634.sktg)
	e3:SetOperation(c249000634.skop)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(2)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,2490006343)
	e4:SetCondition(c249000634.spcon)
	e4:SetCost(c249000634.discost)
	e4:SetTarget(c249000634.sptg)
	e4:SetOperation(c249000634.spop)
	c:RegisterEffect(e4)
	if not c249000634.global_check then
		c249000634.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetCountLimit(1)
		ge1:SetOperation(c249000634.startop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c249000634.costfilter(c)
	return c:IsSetCard(0x1B7) and c:IsAbleToRemove() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE+LOCATION_HAND))
end
function c249000634.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000634.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c249000634.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249000634.filter(c)
	return not (c:IsLocation(c:GetFlagEffectLabel(2490006341)) and c:IsControler(c:GetFlagEffectLabel(2490006342))) and not c:IsType(TYPE_TOKEN)
end
function c249000634.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000634.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,e:GetHandler()) end
end
function c249000634.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,c249000634.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,2,e:GetHandler())
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffectLabel(2490006341)==LOCATION_HAND then
			Duel.SendtoHand(tc,tc:GetFlagEffectLabel(2490006342),REASON_EFFECT)
		elseif tc:GetFlagEffectLabel(2490006341)==LOCATION_GRAVE then
			Duel.SendtoGrave(tc,REASON_EFFECT,tc:GetFlagEffectLabel(2490006342))
		elseif tc:GetFlagEffectLabel(2490006341)==LOCATION_REMOVED then
			Duel.Remove(tc,tc:GetPreviousPosition(),REASON_EFFECT,tc:GetFlagEffectLabel(2490006342))
		elseif tc:GetFlagEffectLabel(2490006341)==LOCATION_DECK then
			Duel.SendtoDeck(tc,tc:GetFlagEffectLabel(2490006342),2,REASON_EFFECT)
		elseif tc:GetFlagEffectLabel(2490006341)==LOCATION_EXTRA then
			Duel.SendtoDeck(tc,tc:GetFlagEffectLabel(2490006342),0,REASON_EFFECT)
		else
			Duel.MoveToField(tc,tc:GetFlagEffectLabel(2490006342),tc:GetFlagEffectLabel(2490006342),tc:GetFlagEffectLabel(2490006341),tc:GetFlagEffectLabel(2490006343),true)
		end
		tc=g:GetNext()
	end
end
function c249000634.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(Card.IsOnField,1,nil) and Duel.IsChainNegatable(ev)
end
function c249000634.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c249000634.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c249000634.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function c249000634.skcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c249000634.sktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function c249000634.skop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	if Duel.GetTurnPlayer()~=tp then
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c249000634.bpcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	end
	Duel.RegisterEffect(e1,tp)
end
function c249000634.bpcon(e)
     return Duel.GetTurnCount()~=e:GetLabel()
end
function c249000634.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
		and c:IsPreviousPosition(POS_FACEUP)
end
function c249000634.spfilter(c,e,tp)
	return c:IsCode(249001055) and c:IsCanBeSpecialSummoned(e,0,tp,true,true) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c249000634.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		and Duel.IsExistingMatchingCard(c249000634.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000634.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000634.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function c249000634.startop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0xFF,0xFF,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(2490006341,RESET_PHASE+PHASE_END,0,1,tc:GetLocation())
		tc:RegisterFlagEffect(2490006342,RESET_PHASE+PHASE_END,0,1,tc:GetControler())
		tc:RegisterFlagEffect(2490006343,RESET_PHASE+PHASE_END,0,1,tc:GetPosition())
		tc=g:GetNext()
	end
end