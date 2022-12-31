--Supporto Inferioringranaggio - Nave da Guerra
--Script by XGlitchy30
function c63553450.initial_effect(c)
	c:EnableCounterPermit(0x1554)
	--spsummon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,63553450)
	e1:SetCondition(c63553450.spcon)
	c:RegisterEffect(e1)
	--change pos
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63553450,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c63553450.poscost)
	e2:SetTarget(c63553450.postg)
	e2:SetOperation(c63553450.posop)
	c:RegisterEffect(e2)
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
	e3:SetCondition(c63553450.ctcon)
	e3:SetOperation(c63553450.ctop)
	c:RegisterEffect(e3)
end
--filters
function c63553450.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4554)
end
function c63553450.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
function c63553450.indfilter(e,c)
	return c==e:GetLabelObject()
end
--spsummon procedure
function c63553450.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(c63553450.filter,c:GetControler(),LOCATION_MZONE,0,2,nil)
end
--change pos
function c63553450.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1554,1,REASON_EFFECT) end
	if Duel.IsCanRemoveCounter(tp,1,1,0x1554,1,REASON_COST) then
		Duel.RemoveCounter(tp,1,1,0x1554,1,REASON_COST)
	end
end
function c63553450.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1554,1,REASON_EFFECT)
		and Duel.IsExistingMatchingCard(c63553450.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
end
function c63553450.posop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,c63553450.posfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if g and g:IsAttackPos() then
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetLabelObject(g)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetTarget(c63553450.indfilter)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
--place counter
function c63553450.ctcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=eg:GetFirst()
	return rc==e:GetHandler()
end
function c63553450.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1554,1)
end