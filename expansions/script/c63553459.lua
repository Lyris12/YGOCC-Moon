--Unità Inferioringranaggio
--Script by XGlitchy30
function c63553459.initial_effect(c)
	c:EnableCounterPermit(0x1554)
	c:SetUniqueOnField(1,0,63553459)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c63553459.condition)
	e1:SetTarget(c63553459.target)
	e1:SetOperation(c63553459.activate)
	c:RegisterEffect(e1)
	--place counters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63553459,1))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c63553459.ctcon)
	e3:SetCost(c63553459.ctcost)
	e3:SetTarget(c63553459.cttg)
	e3:SetOperation(c63553459.ctop)
	c:RegisterEffect(e3)
	--remove counters
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(63553459,2))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PREDRAW)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c63553459.rcttg)
	e4:SetOperation(c63553459.rctop)
	c:RegisterEffect(e4)
	e4x=e4:Clone()
	e4x:SetCode(EVENT_PHASE+PHASE_END)
	c:RegisterEffect(e4x)
	--self remove
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_REMOVE_COUNTER+0x1554)
	e5:SetCondition(c63553459.rmcon)
	e5:SetOperation(c63553459.rmop)
	c:RegisterEffect(e5)
	--negate
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(63553459,3))
	e6:SetCategory(CATEGORY_NEGATE+CATEGORY_POSITION)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c63553459.negcon)
	e6:SetCost(c63553459.negcost)
	e6:SetTarget(c63553459.negtg)
	e6:SetOperation(c63553459.negop)
	c:RegisterEffect(e6)
	--search
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(28912357,1))
	e7:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetCondition(c63553459.sccon)
	e7:SetTarget(c63553459.sctg)
	e7:SetOperation(c63553459.scop)
	c:RegisterEffect(e7)
	local e7x=e7:Clone()
	e7x:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e7x)
	local e7y=e7:Clone()
	e7y:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e7y)
	local e7z=e7:Clone()
	e7z:SetCode(EVENT_TO_HAND)
	c:RegisterEffect(e7z)
end
--filters
function c63553459.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()>0 and c:IsDiscardable()
end
function c63553459.posfilter(c)
	return c:IsCanChangePosition()
end
function c63553459.scfilter(c)
	return c:IsSetCard(0x4554) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
--Activate
function c63553459.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
end
function c63553459.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return Duel.IsCanAddCounter(tp,0x1554,g,c) end
end
function c63553459.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	c:AddCounter(0x1554,g)
	e:SetLabel(c:GetCounter(0x1554))
	--counter limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_COUNTER_LIMIT+0x1554)
	e2:SetValue(e:GetLabel())
	e2:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e2)
end
--counter limit
function c63553459.ctlimit(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1554)>e:GetLabelObject():GetLabel()
end
--place counters
function c63553459.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		and not e:GetHandler():IsCode(63553462)
end
function c63553459.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c63553459.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c63553459.costfilter,1,1,REASON_COST+REASON_DISCARD)
	local op=Duel.GetOperatedGroup():GetFirst()
	e:SetLabel(op:GetLevel())
end
function c63553459.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
end
function c63553459.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x1554,e:GetLabel(),true)
end
--remove counters
function c63553459.rcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCounter(0x1554)>0 end
end
function c63553459.rctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCounter(0x1554)<=0 then return end
	if c:GetCounter(0x1554)>=2 then
		c:RemoveCounter(tp,0x1554,2,REASON_EFFECT)
		if c:GetCounter(0x1554)<=0 then
			Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
		end
	else
		c:RemoveCounter(tp,0x1554,1,REASON_EFFECT)
		if c:GetCounter(0x1554)<=0 then
			Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
		end
	end
end
--self removal
function c63553459.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1554)<=0
end
function c63553459.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
--negate
function c63553459.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_CHAINING) and Duel.IsChainNegatable(ev)
end
function c63553459.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCounter(0x1554)>=3 end
	c:RemoveCounter(tp,0x1554,3,REASON_COST)
end
function c63553459.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c63553459.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function c63553459.negop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c63553459.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then return end
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local g=Duel.SelectMatchingCard(tp,c63553459.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end
--search
function c63553459.sccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c63553459.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c63553459.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c63553459.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c63553459.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleDeck(tp)
	end
end