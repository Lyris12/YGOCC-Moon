--Xyz-Gemini Reload
function c249001005.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,249001005+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetOperation(c249001005.activate)
	c:RegisterEffect(e1)
	if not c249001005.counter then
		c249001005.counter=true
		c249001005[0]=0
		c249001005[1]=0
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetOperation(c249001005.resetcount)
		Duel.RegisterEffect(e2,0)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetOperation(c249001005.addcount)
		Duel.RegisterEffect(e3,0)
	end
	--negate attack
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(96427353,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(c249001005.condition)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c249001005.target)
	e4:SetOperation(c249001005.operation)
	c:RegisterEffect(e4)
end
function c249001005.resetcount(e,tp,eg,ep,ev,re,r,rp)
	c249001005[0]=0
	c249001005[1]=0
end
function c249001005.cfilter(c)
	return c:IsSetCard(0x6073) and c:IsType(TYPE_MONSTER)
end
function c249001005.addcount(e,tp,eg,ep,ev,re,r,rp)
	if eg:GetFirst():IsSummonType(SUMMON_TYPE_XYZ) and eg:GetFirst():GetOverlayGroup():IsExists(c249001005.cfilter,1,nil) then
		local p=eg:GetFirst():GetSummonPlayer()
		c249001005[p]=c249001005[p]+1
	end
end
function c249001005.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c249001005.droperation)
	Duel.RegisterEffect(e1,tp)
end
function c249001005.droperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,249001005)
	if c249001005[tp] > 3 then Duel.Draw(tp,3,REASON_EFFECT) else Duel.Draw(tp,c249001005[tp],REASON_EFFECT) end
end
function c249001005.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function c249001005.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001005.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	if dc:IsSetCard(0x73) then Duel.NegateAttack() end
end