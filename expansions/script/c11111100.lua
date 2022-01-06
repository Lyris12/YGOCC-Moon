--Holy Blast
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
    e1:SetCost(cid.cost)
    e1:SetTarget(cid.target)
    e1:SetOperation(cid.activate)
    c:RegisterEffect(e1)
end
function cid.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.CheckLPCost(tp, 2000) end
    Duel.PayLPCost(tp, 2000)
end
function cid.filter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cid.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chkc then return chkc:GetControler(1-tp) and chkc:IsOnField() and cid.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(cid.filter, tp, 0, LOCATION_ONFIELD, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp, cid.filter, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    Duel.SetChainLimit(cid.chainlimit)
end
function cid.chainlimit(re, rp, tp)
    return tp==ep
end
function cid.activate(e, tp, eg, ep, ev, re, r, rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc, REASON_EFFECT)
    end
end
