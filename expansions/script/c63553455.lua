--Inferioringranaggio Qualificatore
--Script by XGlitchy30
function c63553455.initial_effect(c)
	c:EnableCounterPermit(0x1554)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c63553455.spcon)
	e1:SetOperation(c63553455.spop)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c63553455.limitcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_FIELD)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2x:SetTargetRange(LOCATION_MZONE,0)
	e2x:SetCondition(c63553455.limitcon)
	e2x:SetTarget(c63553455.atktg)
	e2x:SetValue(2)
	c:RegisterEffect(e2x)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63553455,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c63553455.sctg)
	e3:SetOperation(c63553455.scop)
	c:RegisterEffect(e3)
	--pierce
	local prc=Effect.CreateEffect(c)
	prc:SetType(EFFECT_TYPE_SINGLE)
	prc:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(prc)
	--place counter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c63553455.ctcon)
	e4:SetOperation(c63553455.ctop)
	c:RegisterEffect(e4)
end
--filters
function c63553455.scfilter(c)
	return c:IsSetCard(0x4554) and c:IsAbleToHand()
end
function c63553455.ctfilter(c)
	return c:GetCounter(0x1554)>0
end
--spsummon proc
function c63553455.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.IsCanRemoveCounter(c:GetControler(),1,1,0x1554,3,REASON_COST)
end
function c63553455.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.RemoveCounter(tp,1,1,0x1554,3,REASON_RULE)
end
--limit
function c63553455.limitcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function c63553455.atktg(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x1554)
end
--search
function c63553455.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c63553455.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local sum=0
	for tc in aux.Next(g) do
		local ctct=tc:GetCounter(0x1554)
		sum=sum+ctct
	end
	if sum>3 then
		sum=3
	end
	if chk==0 then return sum>0 and Duel.IsExistingMatchingCard(c63553455.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c63553455.scop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c63553455.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local sum=0
	for tc in aux.Next(g) do
		local ctct=tc:GetCounter(0x1554)
		sum=sum+ctct
	end
	if sum<=0 then return end
	if sum>3 then
		sum=3
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c63553455.scfilter,tp,LOCATION_DECK,0,1,sum,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--place counter
function c63553455.ctcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=eg:GetFirst()
	return rc==e:GetHandler()
end
function c63553455.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1554,1)
end