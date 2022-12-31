 --Created and coded by Rising Phoenix
function c100000908.initial_effect(c)
c:SetUniqueOnField(1,0,100000908)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x50)
			--counter
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c100000908.ctcon)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c100000908.ctop)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c100000908.atkval)
	c:RegisterEffect(e2)
		local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
		--search
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(100000908,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,100000908)
	e4:SetCost(c100000908.costh)
	e4:SetTarget(c100000908.targeth)
	e4:SetOperation(c100000908.operationh)
	c:RegisterEffect(e4)
	--noxyz
		local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e10:SetValue(1)
	c:RegisterEffect(e10)
	--ce
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(100000908,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
		e4:SetCategory(CATEGORY_COUNTER)
	e4:SetCountLimit(1)
	e4:SetTarget(c100000908.cttg)
	e4:SetOperation(c100000908.operationcou1)
	c:RegisterEffect(e4)
		local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCode(EFFECT_IMMUNE_EFFECT)
	e11:SetCondition(c100000908.conua)
	e11:SetValue(c100000908.efilterua)
	c:RegisterEffect(e11)
end
function c100000908.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100000908.filtersc,tp,LOCATION_MZONE,0,1,nil) end
end
function c100000908.efilterua(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function c100000908.filterua(c)
	return c:IsFaceup() and c:IsSetCard(0x763) and c:IsType(TYPE_MONSTER)
end
function c100000908.conua(e)
	return Duel.IsExistingMatchingCard(c100000908.filterua,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function c100000908.filtersc(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x50,1) and c:IsSetCard(0x763)
end
function c100000908.operationcou1(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetMatchingGroup(c100000908.filtersc,tp,LOCATION_ONFIELD,0,nil)
	local tc=g:GetFirst()
	while tc do 
		tc:AddCounter(0x50,1)
		tc=g:GetNext()
	end
	end
function c100000908.costh(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c100000908.filterh(c)
	return c:IsCode(100000909) and c:IsAbleToHand()
end
function c100000908.targeth(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c100000908.filterh,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c100000908.operationh(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c100000908.filterh,tp,LOCATION_DECK,0,0,1,nil)
	if g:GetCount()>0 then end
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
end
function c100000908.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x763)
end
function c100000908.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c100000908.cfilter,1,nil)
end
function c100000908.atkval(e,c)
	return Duel.GetCounter(0,1,1,0x50)*700
end
function c100000908.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:GetFirst()~=e:GetHandler() then
	e:GetHandler():AddCounter(0x50,1)
end
end