--Inferioringranaggio - Portale
--Script by XGlitchy30
function c63553454.initial_effect(c)
	c:EnableCounterPermit(0x1554)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c63553454.spcon)
	c:RegisterEffect(e1)
	--atk boost
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63553454,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c63553454.atkcost)
	e2:SetTarget(c63553454.atktg)
	e2:SetOperation(c63553454.atkop)
	c:RegisterEffect(e2)
	--position
	local pos=Effect.CreateEffect(c)
	pos:SetDescription(aux.Stringid(63553454,2))
	pos:SetCategory(CATEGORY_POSITION)
	pos:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	pos:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	pos:SetCode(EVENT_BATTLE_START)
	pos:SetCondition(c63553454.poscon)
	pos:SetTarget(c63553454.postg)
	pos:SetOperation(c63553454.posop)
	c:RegisterEffect(pos)
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
	e3:SetCondition(c63553454.ctcon)
	e3:SetOperation(c63553454.ctop)
	c:RegisterEffect(e3)
end
--filters
function c63553454.cfilter(c)
	return c:IsFacedown() or c:GetCounter(0x1554)<2
end
function c63553454.ctfilter(c)
	return c:GetCounter(0x1554)>0
end
function c63553454.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1554)
end
--spsummon proc
function c63553454.spcon(e,c)
	if c==nil then return true end
	return (Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0) or (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and not Duel.IsExistingMatchingCard(c63553454.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
--atk boost
function c63553454.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1554,2,REASON_EFFECT) end
	local g=Duel.GetMatchingGroup(c63553454.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local sum=0
	local ct=0
	local val=0
	for tc in aux.Next(g) do
		local ctct=tc:GetCounter(0x1554)
		sum=sum+ctct
	end
	if math.fmod(sum,2)==0 then
		ct=sum
	elseif math.fmod(sum,2)>0 then
		ct=sum-1
	end
	if Duel.IsCanRemoveCounter(tp,1,1,0x1554,2,REASON_COST) then
		Duel.RemoveCounter(tp,1,1,0x1554,2,REASON_COST)
		ct=ct-2
		val=val+2
		for i=1,ct/2 do
			if Duel.SelectYesNo(tp,aux.Stringid(63553453,1)) then
				Duel.RemoveCounter(tp,1,1,0x1554,2,REASON_COST)
				val=val+2
			end
		end
	end
	e:SetLabel(val)
end
function c63553454.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c63553454.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
function c63553454.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c63553454.atkfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	local atk=e:GetLabel()*200
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
--position
function c63553454.poscon(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return e:GetHandler()==Duel.GetAttacker() and d
end
function c63553454.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,Duel.GetAttackTarget(),1,0,0)
end
function c63553454.posop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		Duel.ChangePosition(d,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
--place counter
function c63553454.ctcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=eg:GetFirst()
	return rc==e:GetHandler()
end
function c63553454.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1554,2)
end