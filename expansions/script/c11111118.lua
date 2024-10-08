--Crisis Clawspirit - Remains of Cerberus
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
    --Unaffected
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(cid.immval)
    c:RegisterEffect(e3)
    --Double battle damage
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetCondition(cid.damcon)
	e4:SetValue(aux.ChangeBattleDamage(1, DOUBLE_DAMAGE))
    c:RegisterEffect(e4)
    --Chain attack
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_BATTLE_DESTROYING)
    e5:SetCountLimit(2)
    e5:SetCondition(cid.atkcon)
    e5:SetCost(cid.atkcost)
	e5:SetOperation(cid.atkop)
	local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e6:SetRange(LOCATION_SZONE)
    e6:SetTargetRange(LOCATION_MZONE, 0)
    e6:SetTarget(cid.eftg)
    e6:SetLabelObject(e5)
    c:RegisterEffect(e6)
    --Destroy this card at the end of the battle phase
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e5:SetCountLimit(1)
	e5:SetTarget(cid.destg1)
	e5:SetOperation(cid.desop1)
    c:RegisterEffect(e5)
    --Destroy the equipped monster
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(cid.descon)
    e6:SetTarget(cid.destg2)
    e6:SetOperation(cid.desop2)
    c:RegisterEffect(e6)
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
function cid.immval(e, re)
    local ph=Duel.GetCurrentPhase()
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
--Double battle damage
function cid.damcon(e, c)
    local c=e:GetHandler()
	return c:GetEquipTarget():GetSummonLocation()==LOCATION_EXTRA and c:GetEquipTarget():GetBattleTarget()~=nil
end
--Chain attack
function cid.eftg(e, c)
    if e:GetHandler():GetEquipTarget():IsCode(11111108) then
        return e:GetHandler():GetEquipTarget()==c
    end
end
function cid.atkcon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return Duel.GetTurnPlayer()==tp and bc:IsType(TYPE_MONSTER) and c:IsStatus(STATUS_OPPO_BATTLE)
end
function cid.atkcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp, Card.IsAbleToRemoveAsCost, tp, LOCATION_HAND, 0, 1, 1, nil)
	Duel.Remove(g, POS_FACEUP, REASON_COST)
end
function cid.atkop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	Duel.ChainAttack()
end
--Destroy this card at the end of the battle phase
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
--Destroy the equipped monster and lose LP
function cid.descon(e, tp, eg, ep, ev, re, r, rp)
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
    if tc:IsLocation(LOCATION_MZONE) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
        Duel.SetLP(tp, Duel.GetLP(tp)-3000)
    end
end