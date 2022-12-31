--Inferioringranaggio - MaX
--Script by XGlitchy30
function c63553453.initial_effect(c)
	c:EnableCounterPermit(0x1554)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c63553453.spcon)
	e1:SetOperation(c63553453.spop)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--spsummon counters
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetLabelObject(e1)
	e2:SetOperation(c63553453.spctop)
	c:RegisterEffect(e2)
	--negate
	local neg1=Effect.CreateEffect(c)
	neg1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	neg1:SetRange(LOCATION_MZONE)
	neg1:SetCode(EVENT_ATTACK_ANNOUNCE)
	neg1:SetCondition(c63553453.negcon1)
	neg1:SetCost(c63553453.negcost)
	neg1:SetOperation(c63553453.negop1)
	c:RegisterEffect(neg1)
	local neg2=Effect.CreateEffect(c)
	neg2:SetCategory(CATEGORY_DISABLE)
	neg2:SetType(EFFECT_TYPE_QUICK_O)
	neg2:SetCode(EVENT_CHAINING)
	neg2:SetRange(LOCATION_MZONE)
	neg2:SetCondition(c63553453.negcon2)
	neg2:SetCost(c63553453.negcost)
	neg2:SetTarget(c63553453.negtg2)
	neg2:SetOperation(c63553453.negop2)
	c:RegisterEffect(neg2)
	--pierce
	local prc=Effect.CreateEffect(c)
	prc:SetType(EFFECT_TYPE_SINGLE)
	prc:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(prc)
	--place counter
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c63553453.ctcon)
	e3:SetOperation(c63553453.ctop)
	c:RegisterEffect(e3)
end
--filters
function c63553453.spcfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsDiscardable()
end
function c63553453.tgcheck(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
--spsummon proc
function c63553453.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c63553453.spcfilter,tp,LOCATION_HAND,0,1,c)
end
function c63553453.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,c63553453.spcfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	local op=Duel.GetOperatedGroup():GetFirst()
	e:SetLabel(op:GetLevel())
end
--spsummon counters
function c63553453.spctop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetSummonType()~=SUMMON_TYPE_SPECIAL+1 then return end
	e:GetHandler():AddCounter(0x1554,e:GetLabelObject():GetLabel())
end
--negate
function c63553453.negcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function c63553453.negcon2(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsActiveType(TYPE_MONSTER) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c63553453.tgcheck,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function c63553453.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1554,3,REASON_EFFECT) end
	if Duel.IsCanRemoveCounter(tp,1,1,0x1554,3,REASON_COST) then
		Duel.RemoveCounter(tp,1,1,0x1554,3,REASON_COST)
	end
end
function c63553453.negop1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then 
		if Duel.NegateAttack() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			e:GetHandler():RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			e:GetHandler():RegisterEffect(e2)
		end
	end
end
function c63553453.negtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function c63553453.negop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e:GetHandler():RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e:GetHandler():RegisterEffect(e2)
	end
end
--place counter
function c63553453.ctcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=eg:GetFirst()
	return rc==e:GetHandler()
end
function c63553453.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1554,1)
end