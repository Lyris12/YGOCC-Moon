--Crisis Claw - Corruption
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    --Search a "Crisis Claw" monster
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetTarget(cid.thtg)
    e1:SetOperation(cid.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    --Destroy and draw
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id+100)
    e3:SetCondition(aux.exccon)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(cid.destg)
    e3:SetOperation(cid.desop)
    c:RegisterEffect(e3)
end
--Search a "Crisis Claw" monster
function cid.thfilter(c)
    return c:IsSetCard(0x571) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
end
function cid.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function cid.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp, cid.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g, tp, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end
--Destroy and draw
function cid.desfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x571) and c:IsType(TYPE_EQUIP)
end
function cid.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and cid.desfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(cid.desfilter, tp, LOCATION_SZONE, 0, 1, nil)
        and Duel.IsPlayerCanDraw(tp, 1) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp, cid.desfilter, tp, LOCATION_SZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function cid.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT)~=0 then
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end