--Contract With the Queen of Evil Vine
function c16000323.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c16000323.cost)
	c:RegisterEffect(e1)
		  --spsummon limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c16000323.sumlimit)
	c:RegisterEffect(e2)
		--extra summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c16000323.target)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_EXTRA_SET_COUNT)
	c:RegisterEffect(e4)
	  --act limit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetOperation(c16000323.chainop)
	c:RegisterEffect(e5)
	 --actlimit
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(0,1)
	e6:SetCondition(c16000323.actcon)
	e6:SetValue(c16000323.aclimit)
	c:RegisterEffect(e6)
end
function c16000323.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function c16000323.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x85a)
end
function c16000323.target(e,c)
	return c:IsSetCard(0x485a)
end
function c16000323.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if  rc:IsSetCard(0x485a)  then
		Duel.SetChainLimit(c16000323.chainlm)
	end
end
function c16000323.chainlm(e,rp,tp)
	return tp==rp
end
function c16000323.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x485a) and c:IsControler(tp)
end
function c16000323.actcon(e)
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a and c16000323.cfilter(a,tp)) or (d and c16000323.cfilter(d,tp))
end
function c16000323.aclimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end