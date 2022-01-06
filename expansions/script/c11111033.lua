--Golden Skies Armatus - Dastardly Strings
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion Materials
    aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x528),aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),true)
    --Increase ATK whan attacking
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.atkcon)
	e1:SetValue(cid.atkval)
    c:RegisterEffect(e1)
    --Send a "Golden Skies Treasure" to GY when Fusion Summoned
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetCondition(cid.tgcon)
    e2:SetTarget(cid.tgtg)
    e2:SetOperation(cid.tgop)
    c:RegisterEffect(e2)
    --Take control of an opponent's card when destroyed by a card effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_CONTROL)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCountLimit(1, id+100)
    e3:SetCondition(cid.condition)
    e3:SetTarget(cid.target)
    e3:SetOperation(cid.operation)
    c:RegisterEffect(e3)
end

--Increase ATK whan attacking

function cid.atkcon(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		and e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()~=nil
end
function cid.atkval(e,c)
	return math.ceil(Duel.GetAttackTarget():GetAttack())
end

--Send a "Golden Skies Treasure" to GY when Fusion Summoned

function cid.tgcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function cid.tgfilter(c)
	return c:IsCode(11111040) and c:IsAbleToGrave()
end
function cid.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.tgfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end
function cid.tgop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, cid.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if g:GetCount()>0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end

--Take control of an opponent's card when destroyed by a card effect

function cid.condition(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function cid.filter(c, tp)
    return (c:IsControler(1-tp) and c:IsControlerCanBeChanged()) or not c:IsType(TYPE_MONSTER)
end
function cid.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingMatchingCard(cid.filter, tp, 0, LOCATION_ONFIELD, 1, nil, tp) end
    Duel.SetOperationInfo(0, CATEGORY_CONTROL, 0, 1, 0, 0)
end
function cid.operation(e, tp, eg, ep, ev, re, r, rp)
    local tc=Duel.SelectMatchingCard(tp, cid.filter, tp, 0, LOCATION_ONFIELD, 1, 1, nil, tp):GetFirst()
    if tc and tc:IsLocation(LOCATION_ONFIELD) then
        if tc:IsType(TYPE_MONSTER) then
            Duel.GetControl(tc, tp)
        else
            local loc=LOCATION_SZONE
            if tc:IsType(TYPE_FIELD) then
                loc=LOCATION_FZONE
            end
            Duel.MoveToField(tc, tp, tp, loc, tc:GetPosition(), true)
        end
    end
end