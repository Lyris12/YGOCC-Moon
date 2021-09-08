--Mondoassillo Braccia || Worldsbane Arms
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),4,2)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--extra attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetCondition(s.extracon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
--atkup
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d~=nil and d:IsFaceup() and ((a:GetControler()==tp and a:IsSetCard(0x9fa) and a:IsRelateToBattle())
		or (d:GetControler()==tp and d:IsSetCard(0x9fa) and d:IsRelateToBattle()))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a and a:GetControler()==tp and a:IsSetCard(0x9fa) and a:IsRelateToBattle() then
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,a,1,1,a:GetAttack()+1000)
		Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,a,1,1,a:GetDefense()+1000)
	end
	if d and d:GetControler()==tp and d:IsSetCard(0x9fa) and d:IsRelateToBattle() then
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,d,1,1,d:GetAttack()+1000)
		Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,d,1,1,d:GetDefense()+1000)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	if a:GetControler()==tp and d:GetControler()==tp then
		local g=Group.FromCards(a,d)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		tc:RegisterEffect(e1)
		tc:RegisterEffect(e2)
	else
		if a:GetControler()==tp then
			a:RegisterEffect(e1)
			a:RegisterEffect(e2)
		else
			d:RegisterEffect(e1)
			d:RegisterEffect(e2)
		end
	end
end
--extra attack
function s.extracon(e)
	return e:GetHandler():GetOverlayCount()==0
end