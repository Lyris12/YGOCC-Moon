--Centrale Inferioringranaggio
--Script by XGlitchy30
function c63553461.initial_effect(c)
	c:EnableCounterPermit(0x1554)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,63553461+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c63553461.target)
	e1:SetOperation(c63553461.activate)
	c:RegisterEffect(e1)
	--spsummon limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c63553461.spsumlimit)
	c:RegisterEffect(e3)
	--set
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c63553461.setcon)
	e4:SetOperation(c63553461.setop)
	c:RegisterEffect(e4)
	--negate
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(63553459,3))
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c63553461.negcon)
	e5:SetCost(c63553461.negcost)
	e5:SetTarget(c63553461.negtg)
	e5:SetOperation(c63553461.negop)
	c:RegisterEffect(e5)
end
--filters
function c63553461.filter(c)
	return c:IsFaceup() and c:GetCounter(0x1554)>0
end
function c63553461.setfilter(c,ct)
	return ((not c:IsType(TYPE_XYZ) and c:GetLevel()>ct) or (c:IsType(TYPE_XYZ) and c:GetRank()>ct))
end
function c63553461.posfilter(c)
	return c:IsCanChangePosition()
end
--Activate
function c63553461.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c63553461.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c63553461.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c63553461.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
end
function c63553461.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		local ct=tc:GetCounter(0x1554)
		if ct<=0 then return end
		c:AddCounter(0x1554,ct)
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
end
--counter limit
function c63553461.ctlimit(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0)>e:GetLabelObject():GetLabel()
end
--spsummon limit
function c63553461.spsumlimit(e,c,sump,sumtype,sumpos,targetp)
	return ((not c:IsType(TYPE_XYZ) and c:GetLevel()==e:GetHandler():GetCounter(0x1554)) or (c:IsType(TYPE_XYZ) and c:GetRank()==e:GetHandler():GetCounter(0x1554)))
end
--set
function c63553461.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c63553461.setfilter,1,nil,e:GetHandler():GetCounter(0x1554))
end
function c63553461.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ChangePosition(c,POS_FACEDOWN)
	Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
end
--negate
function c63553461.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_CHAINING) and Duel.IsChainNegatable(ev)
end
function c63553461.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCounter(0x1554)>=3 end
	c:RemoveCounter(tp,0x1554,3,REASON_COST)
end
function c63553461.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c63553461.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function c63553461.negop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c63553461.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then return end
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local g=Duel.SelectMatchingCard(tp,c63553461.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end