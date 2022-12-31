--Magium Balen
local m=888812
local cm=_G["c"..m]
function cm.initial_effect(c)
    --special summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(cm.condition)
    e1:SetOperation(cm.operation)
    e1:SetCountLimit(1,888112)
    c:RegisterEffect(e1)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(m,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetCountLimit(1,888222)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(cm.condition2)
    e3:SetTarget(cm.sptg)
    e3:SetOperation(cm.spop)
    c:RegisterEffect(e3)    
end

function cm.condition2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    return re:IsActiveType(TYPE_MONSTER)
end

function cm.filter(c)
    return c:IsSetCard(0xffc) and c:IsAbleToHand() and not c:IsCode(m) and not c:IsFacedown()
end

function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
        and Duel.IsExistingTarget(cm.filter,tp,LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
    local rm=g1:GetFirst()
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,rm,1,tp,LOCATION_GRAVE)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    local ds=g2:GetFirst()
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,ds,1,0,0)
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp)
    local ex1,g1=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
    local rm=g1:GetFirst()
    if not rm:IsRelateToEffect(e) then return end
    if Duel.SendtoHand(rm,nil,REASON_EFFECT)==0 then return end
    local ex2,g2=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
    local ds=g2:GetFirst()
    if not ds:IsRelateToEffect(e) then return end
    Duel.Destroy(ds,REASON_EFFECT)
end

function cm.condition(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(cm.thfilter2,tp,LOCATION_GRAVE,0,1,c)
end

function cm.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,cm.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SendtoDeck(g,nil,1,REASON_COST)
end

function cm.thfilter2(c)
    return c:IsCode(88810101) and c:IsAbleToDeck()
end