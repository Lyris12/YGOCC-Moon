--Mantra GOD
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(scard.condition)
	e1:SetCost(scard.cost)
	e1:SetTarget(scard.target)
	e1:SetOperation(scard.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(scard.handcon)
	c:RegisterEffect(e2)
end
function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()>=3
end
function scard.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
			return Duel.CheckLPCost(tp,math.ceil(Duel.GetLP(tp)/2))
		else
			return Duel.CheckLPCost(tp,3000)
		end
	end
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then 
		Duel.PayLPCost(tp,math.ceil(Duel.GetLP(tp)/2))
	else
		Duel.PayLPCost(tp,3000)
	end
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT):GetHandlerPlayer()==1-tp end
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		if te:GetHandlerPlayer()==1-tp then
			local tc=te:GetHandler()
			ng:AddCard(tc)
			if tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,ng:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
function scard.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		if te:GetHandlerPlayer()==1-tp then
			Duel.NegateActivation(i)
			local tc=te:GetHandler()
			if tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	Duel.Destroy(dg,REASON_EFFECT)
end
function scard.handcon(e)
	return Duel.GetLP(tp)>6000
end
