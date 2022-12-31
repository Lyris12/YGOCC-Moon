--Takina the Enlightened Temporal Sage
function c249001055.initial_effect(c)
	c:EnableReviveLimit()
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--rewind
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,2490010551)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c249001055.cost)
	e1:SetTarget(c249001055.target)
	e1:SetOperation(c249001055.operation)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12298909,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,2490010552)
	e2:SetCondition(c249001055.discon)
	e2:SetTarget(c249001055.distg)
	e2:SetOperation(c249001055.disop)
	c:RegisterEffect(e2)
	--pzone destroy
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(c249001055.skcon)
	e3:SetTarget(c249001055.sktg)
	e3:SetOperation(c249001055.skop)
	c:RegisterEffect(e3)
	--unaffected
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(c249001055.efilter)
	c:RegisterEffect(e4)
	--code
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CHANGE_CODE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(249000634)
	c:RegisterEffect(e5)
	if not c249001055.global_check then
		c249001055.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetCountLimit(1)
		ge1:SetOperation(c249001055.startop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c249001055.costfilter(c)
	return c:IsSetCard(0x1B7) and c:IsAbleToRemove() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE+LOCATION_HAND))
end
function c249001055.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001055.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c249001055.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249001055.filter(c)
	return not (c:IsLocation(c:GetFlagEffectLabel(c2490010551)) and c:IsControler(c:GetFlagEffectLabel(c2490010552))) and not c:IsType(TYPE_TOKEN)
end
function c249001055.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001055.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,e:GetHandler()) end
end
function c249001055.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,c249001055.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,3,e:GetHandler())
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffectLabel(c2490010551)==LOCATION_HAND then
			Duel.SendtoHand(tc,tc:GetFlagEffectLabel(c2490010552),REASON_EFFECT)
		elseif tc:GetFlagEffectLabel(c2490010551)==LOCATION_GRAVE then
			Duel.SendtoGrave(tc,REASON_EFFECT,tc:GetFlagEffectLabel(c2490010552))
		elseif tc:GetFlagEffectLabel(c2490010551)==LOCATION_REMOVED then
			Duel.Remove(tc,tc:GetPreviousPosition(),REASON_EFFECT,tc:GetFlagEffectLabel(c2490010552))
		elseif tc:GetFlagEffectLabel(c2490010551)==LOCATION_DECK then
			Duel.SendtoDeck(tc,tc:GetFlagEffectLabel(c2490010552),2,REASON_EFFECT)
		elseif tc:GetFlagEffectLabel(c2490010551)==LOCATION_EXTRA then
			Duel.SendtoDeck(tc,tc:GetFlagEffectLabel(c2490010552),0,REASON_EFFECT)
		else
			Duel.MoveToField(tc,tc:GetFlagEffectLabel(c2490010552),tc:GetFlagEffectLabel(c2490010552),tc:GetFlagEffectLabel(c2490010551),tc:GetFlagEffectLabel(c2490010553),true)
		end
		tc=g:GetNext()
	end
end
function c249001055.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(Card.IsOnField,1,nil) and Duel.IsChainNegatable(ev)
end
function c249001055.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c249001055.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function c249001055.skcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c249001055.sktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function c249001055.skop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	if Duel.GetTurnPlayer()~=tp then
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c249001055.bpcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	end
	Duel.RegisterEffect(e1,tp)
end
function c249001055.bpcon(e)
     return Duel.GetTurnCount()~=e:GetLabel()
end
function c249001055.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
function c249001055.startop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0xFF,0xFF,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(c2490010551,RESET_PHASE+PHASE_END,0,1,tc:GetLocation())
		tc:RegisterFlagEffect(c2490010552,RESET_PHASE+PHASE_END,0,1,tc:GetControler())
		tc:RegisterFlagEffect(c2490010553,RESET_PHASE+PHASE_END,0,1,tc:GetPosition())
		tc=g:GetNext()
	end
end