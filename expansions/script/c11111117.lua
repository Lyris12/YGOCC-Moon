--Crisis Clawspirit - Stag's Oppression
--Scripted by Yuno
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
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
    --Draw
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
	e3:SetCondition(cid.drcon)
	e3:SetTarget(cid.drtg)
	e3:SetOperation(cid.drop)
	c:RegisterEffect(e3)
    --Return and equip
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_EQUIP)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(cid.thtg)
    e4:SetOperation(cid.thop)
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
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
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
--Draw
function cid.drcon(e, tp, eg, ep, ev, re, r, rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	return e:GetHandler():GetEquipTarget()==eg:GetFirst() and ec:IsControler(tp)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
function cid.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function cid.drop(e, tp, eg, ep, ev, re, r, rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
	Duel.Draw(p, d, REASON_EFFECT)
end
--Return and equip
function cid.eftg(e, c)
    if e:GetHandler():GetEquipTarget():IsAttribute(ATTRIBUTE_DARK) then
        return e:GetHandler():GetEquipTarget()==c
    end
end
function cid.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
	    and Duel.IsExistingTarget(cid.eqfilter, tp, LOCATION_GRAVE, 0, 1, nil, c:GetCode())
end
function cid.eqfilter(c, code)
	return c:IsType(TYPE_EQUIP) and not c:IsCode(code)
end
function cid.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(cid.thfilter, tp, LOCATION_SZONE, 0, 1, nil)
		and Duel.IsExistingTarget(cid.eqfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
	local g1=Duel.SelectTarget(tp, cid.thfilter, tp, LOCATION_SZONE, 0, 1, 1, nil)
	local tc1=g1:GetFirst()
	e:SetLabelObject(tc1)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
	local g2=Duel.SelectTarget(tp, cid.eqfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, tc1:GetCode())
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, g1, 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, g2, 1, 0, 0)
end
function cid.thop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc1=e:GetLabelObject()
	local g=Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc2==tc1 then tc2=g:GetNext() end
	if tc1:IsRelateToEffect(e) and tc1:IsFaceup() and Duel.SendtoHand(tc1, nil, REASON_EFFECT)~=0 then
		Duel.Equip(tp, tc2, c)
	end
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
	return re and re:GetHandler():GetReason(REASON_EFFECT)
end
function cid.destg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
end
function cid.desop2(e, tp, eg, ep, ev, re, r, rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end