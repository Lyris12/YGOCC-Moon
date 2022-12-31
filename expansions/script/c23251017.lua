--Pharaohnic Ossuary
local id,cod=23251017,c23251017
function cod.initial_effect(c)
	c:EnableCounterPermit(0xd3e)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--ATK up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd3e))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	--Counter
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(cod.ctcon)
	e3:SetOperation(cod.ctop)
	c:RegisterEffect(e3)
	--To hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCost(cod.thcost)
	e4:SetTarget(cod.thtg)
	e4:SetOperation(cod.thop)
	c:RegisterEffect(e4)
end
function cod.cfilter(c,tp)
	return c:IsSetCard(0xd3e) and c:IsType(TYPE_MONSTER) and c:GetPreviousControler()==tp
end
function cod.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(cod.cfilter,nil,tp)
	if ct>0 and e:GetHandler():IsCanAddCounter(0xd3e,ct) then
		e:SetLabel(ct)
		return true
	else
		return false
	end
end
function cod.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0xd3e,e:GetLabel())
end
function cod.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0xd3e,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0xd3e,3,REASON_COST)
end
function cod.thfilter(c)
	return c:IsSetCard(0xd3e) and c:IsAbleToHand()
end
function cod.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(cod.thfilter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cod.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cod.thfilter,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()<2 then return end
	local sg=g:Select(tp,3,3,nil)
	local rg=sg:RandomSelect(tp,1)
	if rg:GetCount()<=0 then return end
	Duel.SendtoHand(rg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,rg)
end