--Kitseki Patience
--Script by XGlitchy30
function c88523892.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c88523892.cost)
	e1:SetTarget(c88523892.target1)
	e1:SetOperation(c88523892.activate)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88523892,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(c88523892.condition)
	e2:SetCost(c88523892.cost)
	e2:SetTarget(c88523892.target2)
	e2:SetOperation(c88523892.activate)
	c:RegisterEffect(e2)
	--reset count
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_HAND+LOCATION_SZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetOperation(c88523892.reset)
	c:RegisterEffect(e3)
end
c88523892.count=0
--filters
function c88523892.ofilter(c)
	local m=_G["c"..c:GetCode()]
	if not m then return false end
	local ocount=m.count
	return c:IsCode(88523892) and ocount
end
--Activate
function c88523892.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	--local ct=Duel.GetFlagEffect(e:GetHandler():GetControler(),88523892)+1
	local ct=c88523892.count+1
	if Duel.GetAttacker() then
		if chk==0 then return Duel.CheckLPCost(e:GetHandler():GetControler(),ct*400) end
		Duel.PayLPCost(e:GetHandler():GetControler(),ct*400)
		c88523892.count=c88523892.count+1
		local copycount=c88523892.count
		local oc=Duel.GetMatchingGroup(c88523892.ofilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,e:GetHandler())
		local otc=oc:GetFirst()
		while otc do
			local m=_G["c"..otc:GetCode()]
			if not m then return end
			m.count=copycount
			otc=oc:GetNext()
		end
	else
		if chk==0 then return true end
	end
end
function c88523892.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return true end
	if Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and tp~=Duel.GetTurnPlayer() and tg:IsOnField() and Duel.IsPlayerCanDiscardDeck(1-tp,1) then
		Duel.SetTargetCard(tg)
	else e:SetProperty(0) end
end
function c88523892.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function c88523892.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		and tg:IsOnField() and Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	Duel.SetTargetCard(tg)
end
function c88523892.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and Duel.IsPlayerCanDiscardDeck(1-tp,1) then
		if Duel.NegateAttack() then
			Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
		end
	end
end
--reset
function c88523892.reset(e,tp,eg,ep,ev,re,r,rp)
	if c88523892.count>0 then
		c88523892.count=0
	end
end