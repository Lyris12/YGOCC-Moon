--Mega Warrior
function c249000005.initial_effect(c)
	--copy effect via battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c249000005.target)
	e1:SetOperation(c249000005.operation)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c249000005.valcon)
	c:RegisterEffect(e2)
	--overlay
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(32999573,0))
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c249000005.rcon)
	e4:SetOperation(c249000005.rop)
	c:RegisterEffect(e4)
end
function c249000005.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetAttackTarget()~=nil and Duel.GetAttacker()~=nil
	end
end
function c249000005.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local tc
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a==c then
		tc=d
	else
		tc=a
	end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOGRAVE-RESET_TOFIELD)
		c:RegisterEffect(e1)
		c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD-RESET_TOGRAVE-RESET_TOFIELD)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOGRAVE-RESET_TOFIELD)
		c:RegisterEffect(e2)
	end
end
function c249000005.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 or bit.band(r,REASON_EFFECT)~=0
end
function c249000005.rcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler()~=re:GetHandler() then return false end
	return ev==1
end
function c249000005.rop(e,tp,eg,ep,ev,re,r,rp)
end