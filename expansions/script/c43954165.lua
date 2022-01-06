--Felgrandrise Artemis
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.atkcon)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_SINGLE)
	e1x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1x:SetRange(LOCATION_MZONE)
	e1x:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1x:SetCondition(cid.atkcon2)
	e1x:SetValue(cid.atkval)
	c:RegisterEffect(e1x)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(cid.negcon)
	e2:SetCost(cid.eqcost)
	e2:SetTarget(cid.negtg)
	e2:SetOperation(cid.negop)
	c:RegisterEffect(e2)
	--equip
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_EQUIP+CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(cid.eqtg)
	e3:SetOperation(cid.eqop)
	c:RegisterEffect(e3)
	local e3x=Effect.CreateEffect(c)
	e3x:SetDescription(aux.Stringid(id,2))
	e3x:SetCategory(CATEGORY_EQUIP+CATEGORY_LEAVE_GRAVE)
	e3x:SetType(EFFECT_TYPE_QUICK_O)
	e3x:SetRange(LOCATION_HAND)
	e3x:SetCode(EVENT_FREE_CHAIN)
	e3x:SetCountLimit(1,id)
	e3x:SetCost(cid.eqcost)
	e3x:SetTarget(cid.eqtg)
	e3x:SetOperation(cid.eqop)
	c:RegisterEffect(e3x)
end
--DIRECT ATTACK
function cid.atkcon(e)
	local ec=e:GetHandler():GetEquipGroup()
	return ec:IsExists(function (c) return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0 end,1,nil)
end
function cid.atkcon2(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local ph=Duel.GetCurrentPhase()
	return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
end
function cid.atkval(e,c)
	return math.ceil(e:GetHandler():GetAttack()/2)
end
--NEGATE
function cid.cfilter(c)
	return (c:IsSetCard(0xfe9) or c:IsCode(table.unpack(c43954163.FELGRAND))) and c:IsFaceup()
end
--------
function cid.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function cid.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cid.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
--EQUIP
function cid.efilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xfe9) or c:IsCode(table.unpack(c43954163.FELGRAND)))
end
function cid.eqfilter(c,tp)
	return c:IsLink(3,4) and c:CheckUniqueOnField(tp) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
--------
function cid.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function cid.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(cid.efilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cid.eqfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function cid.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,cid.efilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc or tc:IsFacedown() or not tc:IsLocation(LOCATION_MZONE) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.eqfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if ec then
		Duel.Equip(tp,ec,tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(cid.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
	end
end
function cid.eqlimit(e,c)
	return c==e:GetLabelObject()
end