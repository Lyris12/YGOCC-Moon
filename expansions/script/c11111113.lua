--Crisis Clawspirit - Lion's Dictatorship
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
	c:SetUniqueOnField(1, 0, cid.uniquefilter, LOCATION_SZONE)
	--Activate and equip
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(cid.eqlimit)
	c:RegisterEffect(e2)
	--Banish any monster destroyed by battle or effect
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_EQUIP)
	e1x:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1x:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1x)
	local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_TO_GRAVE_REDIRECT)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(0, LOCATION_MZONE)
	e3:SetValue(LOCATION_REMOVED)
	e3:SetTarget(cid.rmtg)
    c:RegisterEffect(e3)
	--Negate searches
	local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_NEGATE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(cid.negcon)
    e4:SetTarget(cid.negtg)
    e4:SetOperation(cid.negop)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e5:SetRange(LOCATION_SZONE)
    e5:SetTargetRange(LOCATION_MZONE, 0)
    e5:SetTarget(cid.eftg)
    e5:SetLabelObject(e4)
    c:RegisterEffect(e5)
    --Destroy this card during your standby phase
    local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e6:SetCountLimit(1)
	e6:SetCondition(cid.descon1)
	e6:SetTarget(cid.destg1)
	e6:SetOperation(cid.desop1)
    c:RegisterEffect(e6)
    --Destroy the equipped monster
    local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetProperty(EFFECT_FLAG_DELAY)
    e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_DESTROYED)
	e7:SetCondition(cid.descon2)
    e7:SetTarget(cid.destg2)
    e7:SetOperation(cid.desop2)
    c:RegisterEffect(e7)
end
function cid.uniquefilter(c)
	return c:IsSetCard(0x571) and c:IsType(TYPE_EQUIP)
end
--Activate and equip
function cid.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x571)
end
function cid.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and cid.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
	Duel.SelectTarget(tp, cid.filter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, e:GetHandler(), 1, 0, 0)
end
function cid.activate(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp, e:GetHandler(), tc)
	end
end
--Equip limit
function cid.eqlimit(e, c)
	return c:IsSetCard(0x571)
end
--Banish any monster destroyed by battle or effect
function cid.rmtg(e, c)
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:GetReasonEffect():GetHandler()==e:GetHandler():GetEquipTarget()
end
--Negate searches
function cid.eftg(e, c)
    if e:GetHandler():GetEquipTarget():IsAttribute(ATTRIBUTE_EARTH) then
        return e:GetHandler():GetEquipTarget()==c
    end
end
function cid.negcon(e, tp, eg, ep, ev, re, r, rp)
	local ex1=(Duel.GetOperationInfo(ev,CATEGORY_SEARCH) or re:IsHasCategory(CATEGORY_SEARCH))
	local ex2=(Duel.GetOperationInfo(ev,CATEGORY_DRAW) or re:IsHasCategory(CATEGORY_DRAW))
	return (ex1 or ex2) and rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function cid.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function cid.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
--Destroy this card during your standby phase
function cid.descon1(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer()==tp
end
function cid.destg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, e:GetHandler(), 1, 0, 0)
end
function cid.desop1(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Destroy(c, REASON_EFFECT)
	end
end
--Destroy the equipped monster
function cid.descon2(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function cid.destg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
    local tc=e:GetHandler():GetPreviousEquipTarget()
    Duel.SetTargetCard(tc)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, tc, 1, 0, 0)
end
function cid.desop2(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end