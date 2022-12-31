--Kitseki Rovadier
--Script by XGlitchy30
function c88523885.initial_effect(c)
	--atk boost
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88523885,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c88523885.atkcon)
	e1:SetTarget(c88523885.atktg)
	e1:SetOperation(c88523885.atkop)
	c:RegisterEffect(e1)
end
function c88523885.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and not e:GetHandler():IsStatus(STATUS_CHAINING)
		and e:GetHandler():GetFlagEffect(88523885)==0
end
function c88523885.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsFaceup() and bc:GetBaseAttack()>c:GetBaseAttack() end
end
function c88523885.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsFaceup() and bc:GetBaseAttack()>c:GetBaseAttack() then
		if Duel.IsPlayerCanDiscardDeck(1-tp,3) then
			if Duel.SelectYesNo(1-tp,aux.Stringid(88523885,1)) then
				Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
				c:RegisterFlagEffect(88523885,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE,0,1)
			else
				local atk1=math.max(bc:GetAttack()/2,0)
				if c:IsRelateToBattle() and c:IsFaceup() and c:IsControler(tp) then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetValue(atk1)
					e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE)
					c:RegisterEffect(e1)
					c:RegisterFlagEffect(88523885,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE,0,1)
				end
			end
		else
			local atk2=math.max(bc:GetAttack()/2,0)
			if c:IsRelateToBattle() and c:IsFaceup() and c:IsControler(tp) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(atk2)
				e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE)
				c:RegisterEffect(e1)
				c:RegisterFlagEffect(88523885,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE,0,1)
			end
		end
	end
end