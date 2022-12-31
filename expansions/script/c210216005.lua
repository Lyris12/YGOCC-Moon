function c210216005.initial_effect(c)
	c:EnableReviveLimit()
	--cannot disable effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_DISABLE)
	c:RegisterEffect(e1)
	--spsummon limit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(c210216005.splimit)
	e5:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(e5)
    --ActivateAttach
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetHintTiming(TIMING_DAMAGE_STEP)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(c210216005.cost)
    e3:SetTarget(c210216005.target)
    e3:SetOperation(c210216005.activate)
    c:RegisterEffect(e3)
	--ActivateSearch
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCountLimit(1)
	e7:SetLabel(0)
	e7:SetCost(c210216005.cost1)
	e7:SetTarget(c210216005.target1)
	e7:SetOperation(c210216005.operation1)
	c:RegisterEffect(e7)
end
function c210216005.splimit(e,se,sp,st)
	return (se:GetHandler():IsSetCard(0x216) and se:GetHandler():IsType(TYPE_TRAP)) or e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c210216005.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    e:SetLabel(1)
    return true
end
function c210216005.filter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x216)
end
function c210216005.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c210216005.filter(chkc,tp) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(c210216005.filter,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c210216005.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),tp)
end
function c210216005.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local mg=c:GetOverlayGroup()
		if mg:GetCount()>0 then Duel.Overlay(tc,mg) end
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
function c210216005.cfilter(c)
	return c:IsSetCard(0x216) and c:IsAbleToRemove() and c:IsType(TYPE_TRAP)
end
function c210216005.thfilter(c,code7)
	return c:IsSetCard(0x216) and c:IsAbleToHand() and not c:IsCode(code7)
end
function c210216005.costcheck(g,tp)
	local code7=g:GetFirst():GetCode()
	local tg=Duel.GetMatchingGroup(c210216005.thfilter,tp,LOCATION_DECK,0,nil,code7)
	return tg:CheckSubGroup(aux.dncheck,1,1)
end
function c210216005.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	e:SetLabel(100)
	return true
end
function c210216005.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c210216005.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	and Duel.IsExistingTarget(c210216005.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
end
	local rg=Duel.SelectTarget(tp,c210216005.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TARGET,rg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210216005.operation1(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local code=rg:GetFirst():GetCode()
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
	local g=Duel.SelectMatchingCard(tp,c210216005.thfilter,tp,LOCATION_DECK,0,1,1,nil,code,e,tp)
	if g:GetCount()>0 then
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
end
end
