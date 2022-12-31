--Infiltrazione Inferioringranaggio
--Script by XGlitchy30
function c63553458.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,63553458+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c63553458.target)
	e1:SetOperation(c63553458.activate)
	c:RegisterEffect(e1)
end
--filters
function c63553458.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4554) and c:GetCounter(0x1554)>=2
end
--Activate
function c63553458.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c63553458.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c63553458.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c63553458.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c63553458.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:GetCounter(0x1554)<2 then return end
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,0)
	--option combinations
	if tc:GetCounter(0x1554)>=2 and tc:GetCounter(0x1554)>=3 and tc:GetCounter(0x1554)>=4 and tc:GetCounter(0x1554)>=5 then op=Duel.SelectOption(tp,aux.Stringid(63553458,0),aux.Stringid(63553458,1),aux.Stringid(63553458,2),aux.Stringid(63553458,3))
	elseif tc:GetCounter(0x1554)>=2 and tc:GetCounter(0x1554)>=3 and tc:GetCounter(0x1554)>=4 then op=Duel.SelectOption(tp,aux.Stringid(63553458,0),aux.Stringid(63553458,1),aux.Stringid(63553458,2))
	elseif tc:GetCounter(0x1554)>=2 and tc:GetCounter(0x1554)>=3 then op=Duel.SelectOption(tp,aux.Stringid(63553458,0),aux.Stringid(63553458,1))
	elseif tc:GetCounter(0x1554)>=2 then op=Duel.SelectOption(tp,aux.Stringid(63553458,0))
	else return end
	-------------
	if op==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(c63553458.damcon)
		e2:SetOperation(c63553458.damop)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	elseif op==1 then
		local pos=Effect.CreateEffect(c)
		pos:SetCategory(CATEGORY_POSITION+CATEGORY_DEFCHANGE)
		pos:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		pos:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
		pos:SetCode(EVENT_BATTLE_START)
		pos:SetCondition(c63553458.poscon)
		pos:SetTarget(c63553458.postg)
		pos:SetOperation(c63553458.posop)
		pos:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(pos)
	elseif op==2 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetCondition(c63553458.rmcon)
		e1:SetOperation(c63553458.rmop)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	else
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetCondition(c63553458.actcon)
		e1:SetValue(c63553458.actlimit)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
--double pierce
function c63553458.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:GetBattleTarget()~=nil and tc:GetBattleTarget():IsDefensePos()
end
function c63553458.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev*2)
end
--change positions and reduce DEF to zero
function c63553458.poscon(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return e:GetHandler()==Duel.GetAttacker() and d
end
function c63553458.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,Duel.GetAttackTarget(),1,0,0)
end
function c63553458.posop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		Duel.ChangePosition(d,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		d:RegisterEffect(e1)
	end
end
--banish
function c63553458.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and tc:IsRelateToBattle() and e:GetOwnerPlayer()==tp and tc:IsDefensePos() and tc:IsAbleToRemove()
end
function c63553458.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	Duel.Hint(HINT_CARD,0,63553458)
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
--clear strike
function c63553458.actcon(e)
	local tc=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return tc and tc:IsControler(tp) and tc:GetCounter(0)~=0
end
function c63553458.actlimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end