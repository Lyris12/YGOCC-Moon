--Chronologist Collapse
--Keddy was here~
local cod,id=GetID()
function cod.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetTarget(cod.target)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(cod.atkcon)
	e2:SetTarget(cod.atktg)
	e2:SetOperation(cod.atkop)
	c:RegisterEffect(e2)
	--Move Turn Count
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(cod.mtcon)
	e3:SetOperation(cod.mtop)
	c:RegisterEffect(e3)
end

--Halve
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetCurrentPhase()~=PHASE_DAMAGE
	local b2=Duel.CheckEvent(EVENT_BATTLE_START) and cod.atkcon(e,tp,eg,ep,ev,re,r,rp) and cod.atktg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	if b2 then
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
		e:SetOperation(cod.atkop)
		cod.atktg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function cod.afilter(c)
	return (c:IsHasEffect(39507190) or (c:IsFaceup() and c:IsSetCard(0x593) and c:IsLinkState()))
end
function cod.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	if cod.afilter(tc) and not bc:IsLinkState() then
		e:SetLabelObject(bc)
		return true
	else return false end
end
function cod.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE,bc,1,0,0)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function cod.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) and bc:IsFaceup() then
		local atk,def=bc:GetAttack(),bc:GetDefense()
		atk=math.ceil(atk/2)
		def=math.ceil(def/2)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_BATTLE)
		e1:SetValue(atk)
		bc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(def)
		bc:RegisterEffect(e2)
	end
end

--Move Turn Count
function cod.cfilter(c)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x593)
end
function cod.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cod.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function cod.mtop(e,tp,eg,ep,ev,re,r,rp)
	Duel.MoveTurnCount()
end