--Galactic Codeman: Fusion Zero
local s,id=GetID()
function s.initial_effect(c)
	--highlander
	c:SetUniqueOnField(1,0,id,LOCATION_MZONE)
	--fusion
	aux.AddFusionProcFunFunRep(c,s.ffilter,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),2,2,true)
	c:EnableReviveLimit()
	--pendulum
	aux.EnablePendulumAttribute(c,false)
	--extra atk
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58453942,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_FUSION))
	c:RegisterEffect(e2)
	--disable effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
	--actlimit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetValue(1)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64207696,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	e1:SetCountLimit(1,id+100+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--pendulum place
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(s.checkop)
	e4:SetLabel(0)
	c:RegisterEffect(e4)
	local e4b=Effect.CreateEffect(c)
	e4b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4b:SetCode(EVENT_DESTROYED)
	e4b:SetProperty(EFFECT_FLAG_DELAY)
	e4b:SetCondition(s.pencon)
	e4b:SetOperation(s.penop)
	e4b:SetLabelObject(e4)
	c:RegisterEffect(e4b)
end
function s.ffilter(c)
	return c:IsFusionSetCard(0x1ded) and not c:IsAttack(c:GetBaseAttack())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xded) and c:GetEffectCount(EFFECT_EXTRA_ATTACK)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--extra atk
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		--cannot activate
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetOperation(s.inop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.inop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x1ded)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	if re:IsActiveType(TYPE_FUSION) and p~=tp and (loc&LOCATION_MZONE)~=0 then
		Duel.NegateEffect(ev)
	end
end
function s.val(e)
	local base=e:GetHandler():GetBaseAttack()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if #g==0 then return 0 end
	local _,atk=g:GetMinGroup(Card.GetAttack)
	return (base~=atk) and math.floor(math.abs(base-atk)/2)
end
function s.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	local g=Group.CreateGroup()
	if Duel.GetAttacker() then g:AddCard(Duel.GetAttacker()) end
	if Duel.GetAttackTarget() then g:AddCard(Duel.GetAttackTarget()) end
	return #g>0 and g:IsExists(aux.AND(Card.IsSetCard,Card.IsFaceup),1,nil,0x1ded)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsSetCard(0x1ded) and rc:IsControler(tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsFaceup() and chkc:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c~=chkc end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	local val=eg:GetFirst():GetBattleTarget():GetAttack()
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,math.floor(val/2))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(math.floor(eg:GetFirst():GetBattleTarget():GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local bool=((e:GetHandler():GetSummonType()&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION) and 1) or 0
	e:SetLabel(bool)
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bool=e:GetLabelObject():GetLabel()==1
	return bool and c:IsPreviousLocation(LOCATION_ONFIELD) and tp==c:GetPreviousControler()
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.SelectYesNo(tp,1160) then
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
