--Cyberse Wizard Recoded
function c249000975.initial_effect(c)
	--summon with no tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89252153,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetCondition(c249000975.ntcon)
	e1:SetTarget(c249000975.nttg)
	c:RegisterEffect(e1)
	--normal summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80604091,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCondition(c249000975.condition2)
	e2:SetTarget(c249000975.target2)
	e2:SetOperation(c249000975.operation2)
	c:RegisterEffect(e2)
	--ATK
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c249000975.condition3)
	e3:SetCost(c249000975.cost3)
	e3:SetTarget(c249000975.target3)
	e3:SetOperation(c249000975.operation3)
	c:RegisterEffect(e3)
end
function c249000975.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c249000975.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_CYBERSE)
end
function c249000975.filter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsSummonable(true,nil) or c:IsMSetable(true,nil)
end
function c249000975.cfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x1FE) or c:IsCode(70238111))
end
function c249000975.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(c249000975.cfilter,tp,LOCATION_GRAVE,0,1,c)
end
function c249000975.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not e:GetHandler():IsStatus(STATUS_CHAINING) then
			local ct=Duel.GetMatchingGroupCount(c249000975.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
			e:SetLabel(ct)
			return ct>0
		else return e:GetLabel()>0 end
	end
	e:SetLabel(e:GetLabel()-1)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c249000975.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000975.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil)
		local s2=tc:IsMSetable(true,nil)
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			Duel.Summon(tp,tc,true,nil)
		else
			Duel.MSet(tp,tc,true,nil)
		end
	end
end
function c249000975.condition3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function c249000975.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c249000975.cfilter3(c)
	return c:IsFaceup() and (c:IsSetCard(0x1FE) or c:IsCode(70238111))
end
function c249000975.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(c249000975.cfilter3,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c249000975.cfilter3,tp,LOCATION_MZONE,0,1,1,nil)
end
function c249000975.operation3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e1:SetValue(300)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e2:SetValue(c249000975.efilter)
		tc:RegisterEffect(e2)
	end
end
function c249000975.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end