--
local m=888740
local cm=_G["c"..m]
function cm.initial_effect(c)
        --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(m,1)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetTarget(cm.target)
    e1:SetOperation(cm.activate)
    c:RegisterEffect(e1)
    --act in hand
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2:SetCondition(cm.handcon)
    c:RegisterEffect(e2) 
end
function cm.filter(c)
    return c:IsSetCard(0xff1) and c:IsAbleToRemove() 
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
        and Duel.IsExistingTarget(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_GRAVE,0,1,1,nil)
    local rm=g1:GetFirst()
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,rm,1,tp,LOCATION_GRAVE)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    local ds=g2:GetFirst()
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,ds,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
    local ex1,g1=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
    local rm=g1:GetFirst()
    if not rm:IsRelateToEffect(e) then return end
    if Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)==0 then return end
    local ex2,g2=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
    local ds=g2:GetFirst()
    if not ds:IsRelateToEffect(e) then return end
    Duel.Destroy(ds,REASON_EFFECT)
end

function cm.handcon(e)
    return Duel.IsExistingMatchingCard(cm.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function cm.cfilter(c)
    return c:IsSetCard(0xff1) and c:IsType(TYPE_FUSION)
end