--Evolution-Knight of Radiance
function c249000716.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetOperation(c249000716.caop2)
	c:RegisterEffect(e1)
	--attack all
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(c249000716.atkfilter)
	c:RegisterEffect(e2)
	--to defense
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c249000716.poscon)
	e3:SetOperation(c249000716.posop)
	c:RegisterEffect(e3)
	--chain attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLED)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c249000716.cacon)
	e4:SetOperation(c249000716.caop)
	c:RegisterEffect(e4)
	--scale
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CHANGE_LSCALE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCondition(c249000716.slcon)
	e5:SetValue(6)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e6)
end
function c249000716.atkfilter(e,c)
	return bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL
end
function c249000716.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
function c249000716.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
function c249000716.cacon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if a:IsStatus(STATUS_OPPO_BATTLE) and d:IsControler(tp) then a,d=d,a end
	if (a:IsSetCard(0x1E9) or a:IsType(TYPE_SYNCHRO) or a:IsType(TYPE_XYZ)) and a:IsChainAttackable()
		and not a:IsStatus(STATUS_BATTLE_DESTROYED) and d:IsStatus(STATUS_BATTLE_DESTROYED) then
		e:SetLabelObject(a)
		return true
	else return false end
end
function c249000716.caop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToBattle() then
		Duel.ChainAttack()
	end
end
function c249000716.slcon(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x1E9)
end
