--ダイドー(μ兵装)

--scripted by Warspite
function c10338863.initial_effect(c)
	--chain attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,10338863)
	e1:SetCost(aux.musecost(1,1,aux.Stringid(10338863,2),nil))
	e1:SetOperation(c10338863.operation)
	c:RegisterEffect(e1)
	--ATK up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10338863,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,10338864)
	e2:SetCondition(c10338863.atkcon)
	e2:SetTarget(c10338863.atktg)
	e2:SetOperation(c10338863.atkop)
	c:RegisterEffect(e2)
end
function c10338863.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--chain attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c10338863.caop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetOperation(c10338863.caop2)
	e2:SetLabelObject(e1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end
function c10338863.caop1(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if e:GetHandler()==a and d and d:IsDefensePos() then e:SetLabel(1)
	else e:SetLabel(0) end
end
function c10338863.caop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==1 and c:IsRelateToBattle() and c:IsChainAttackable() then
		Duel.ChainAttack()
	end
end
function c10338863.atkcon(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ac=Duel.GetAttacker()
	return ac:IsFaceup() and ac:IsControler(tp) and ac:IsSetCard(0x16a) and not ac:IsCode(10338863)
end
function c10338863.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x16a)
end
function c10338863.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c10338863.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function c10338863.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c10338863.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end