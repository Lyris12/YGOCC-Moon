--Gem the Wolf
function c249000933.initial_effect(c)
	c:SetUniqueOnField(1,0,249000933)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c249000933.spcon1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c249000933.spcon2)
	e2:SetOperation(c249000933.spop2)
	c:RegisterEffect(e2)
	--Cost Change
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_LPCOST_CHANGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(c249000933.costchange)
	c:RegisterEffect(e3)
	--search
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(2,2490009331)
	e4:SetTarget(c249000933.target)
	e4:SetOperation(c249000933.operation)
	c:RegisterEffect(e4)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53347303,0))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(2,2490009332)
	e3:SetCondition(c249000933.discon)
	e3:SetTarget(c249000933.distg)
	e3:SetOperation(c249000933.disop)
	c:RegisterEffect(e3)
end
function c249000933.spfilter1(c)
	return c:IsSetCard(0x47)
end
function c249000933.spcon1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c249000933.spfilter1,tp,LOCATION_GRAVE,0,2,nil)
end
function c249000933.spfilter2(c)
	return c:IsSetCard(0x47) and c:IsDiscardable()
end
function c249000933.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c249000933.spfilter2,tp,LOCATION_HAND,0,2,nil)
end
function c249000933.spop2(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,c249000933.spfilter2,tp,LOCATION_HAND,0,2,2,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(g1,REASON_COST+REASON_DISCARD)
end
function c249000933.costchange(e,re,rp,val)
	if re and re:GetHandler():IsSetCard(0x47) and not re:GetHandler():IsCode(9236985) then
		return 0
	else
		return val
	end
end
function c249000933.filter(c)
	return c:IsSetCard(0x47) and c:IsAbleToHand()
end
function c249000933.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000933.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c249000933.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c249000933.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c249000933.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not (re:GetHandler():IsSetCard(0x47) or re:GetHandler():IsSetCard(0x34)) then return false end
	return Duel.IsChainDisablable(ev)
end
function c249000933.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function c249000933.disop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.NegateActivation(ev)
end