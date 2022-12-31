--Goldvale's Dance Barrier
local m=88023
local cm=_G["c"..m]
function cm.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(cm.cost)
    e1:SetOperation(cm.disop)
    c:RegisterEffect(e1)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(45960523,1))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetCountLimit(1,m)
    e3:SetRange(LOCATION_REMOVED)
    e3:SetCost(cm.rmcost2)
    e3:SetOperation(cm.tdop)
    c:RegisterEffect(e3)
end
function cm.cfilter(c)
    return c:IsAbleToRemoveAsCost() and c:IsSetCard(0xff9)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,cm.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
    if g:GetCount()>0 then
        Duel.Remove(g,POS_FACEUP,REASON_COST)
    end
end
function cm.disop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_DRAW+PHASE_STANDBY+PHASE_MAIN1+PHASE_BATTLE+PHASE_MAIN2+PHASE_END)
    e1:SetTargetRange(0,1)
    e1:SetTarget(cm.sumlimit)
    Duel.RegisterEffect(e1,tp)
end
function cm.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_EXTRA)
end
function cm.rmcost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(),tp,2,REASON_COST)
end
function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    Duel.BreakEffect()
    Duel.Draw(tp,1,REASON_EFFECT)
end