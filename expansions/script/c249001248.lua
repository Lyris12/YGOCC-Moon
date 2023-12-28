--Space Time Rogue's Temporal Manipulation
function c249001248.initial_effect(c)
	aux.AddCodeList(c,249001241)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,249001248)
	e1:SetCondition(c249001248.condition)
	e1:SetTarget(c249001248.target)
	e1:SetOperation(c249001248.activate)
	c:RegisterEffect(e1)
	--extra attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1115)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_ATTACK)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,249001248)
	e2:SetCondition(c249001248.condition2)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c249001248.target2)
	e2:SetOperation(c249001248.operation)
	c:RegisterEffect(e2)
	if not c249001248.global_check then
		c249001248.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetCountLimit(1)
		ge1:SetOperation(c249001248.startop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c249001248.cfilter(c)
	return c:IsFaceup() and c:IsCode(249001241)
end
function c249001248.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001248.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c249001248.filter(c)
	return not (c:IsLocation(c:GetFlagEffectLabel(2490012481)) and c:IsControler(c:GetFlagEffectLabel(2490012482))) and not c:IsType(TYPE_TOKEN)
end
function c249001248.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001248.filter,tp,LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE, 1,e:GetHandler()) end
end
function c249001248.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,c249001248.filter,tp,LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,2,e:GetHandler())
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffectLabel(2490012481)==LOCATION_HAND then
			Duel.SendtoHand(tc,tc:GetFlagEffectLabel(2490012482),REASON_EFFECT)
		elseif tc:GetFlagEffectLabel(2490012481)==LOCATION_GRAVE then
			Duel.SendtoGrave(tc,REASON_EFFECT,tc:GetFlagEffectLabel(2490012482))
		elseif tc:GetFlagEffectLabel(2490012481)==LOCATION_REMOVED then
			Duel.Remove(tc,tc:GetPreviousPosition(),REASON_EFFECT,tc:GetFlagEffectLabel(2490012482))
		elseif tc:GetFlagEffectLabel(2490012481)==LOCATION_DECK then
			Duel.SendtoDeck(tc,tc:GetFlagEffectLabel(2490012482),2,REASON_EFFECT)
		elseif tc:GetFlagEffectLabel(2490012481)==LOCATION_EXTRA then
			Duel.SendtoDeck(tc,tc:GetFlagEffectLabel(2490012482),0,REASON_EFFECT)
		else
			Duel.MoveToField(tc,tc:GetFlagEffectLabel(2490012482),tc:GetFlagEffectLabel(2490012482),tc:GetFlagEffectLabel(2490012481),tc:GetFlagEffectLabel(2490012483),true)
		end
		tc=g:GetNext()
	end
end
function c249001248.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and aux.bpcon()
end
function c249001248.filter2(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK) and c:IsCode(249001241)
end
function c249001248.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c249001248.filter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c249001248.filter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c249001248.filter2,tp,LOCATION_MZONE,0,1,1,nil)
end
function c249001248.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
function c249001248.startop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0xFF,0xFF,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(2490012481,RESET_PHASE+PHASE_END,0,1,tc:GetLocation())
		tc:RegisterFlagEffect(2490012482,RESET_PHASE+PHASE_END,0,1,tc:GetControler())
		tc:RegisterFlagEffect(2490012483,RESET_PHASE+PHASE_END,0,1,tc:GetPosition())
		tc=g:GetNext()
	end
end

