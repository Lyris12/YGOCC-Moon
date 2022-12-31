--Magium Soul Siphon
local m=888804
local cm=_G["c"..m]
function cm.initial_effect(c)
    c:EnableCounterPermit(0x1001)
    c:SetCounterLimit(0x1001,3)
    c:SetUniqueOnField(1,0,m)
    --add counter
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_TO_GRAVE)
    e0:SetRange(LOCATION_SZONE)
    e0:SetCondition(cm.accon)
    e0:SetOperation(cm.acop)
    c:RegisterEffect(e0)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCode(EVENT_CUSTOM+m)
    e3:SetCost(cm.tgcost)
    e3:SetTarget(cm.tgtg)
    e3:SetOperation(cm.tgop)
    c:RegisterEffect(e3)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_DESTROY_REPLACE)
    e5:SetRange(LOCATION_SZONE)
    e5:SetTarget(cm.reptg)
    e5:SetValue(cm.repval)
    e5:SetOperation(cm.desrepop)
    c:RegisterEffect(e5)    
end

function cm.thfilter2(c,tp)
    return c:IsType(TYPE_MONSTER)
end

function cm.accon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(cm.thfilter2,1,nil,tp)
end

function cm.acop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    c:AddCounter(0x1001,1)
    if c:GetCounter(0x1001)==4 then
        Duel.RaiseSingleEvent(c,EVENT_CUSTOM+m,re,0,0,p,0)
    end
end

function cm.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler() and e:GetHandler():GetCounter(0x1001)==6 end 
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    e:GetHandler():RemoveCounter(tp,0x1001,6,REASON_COST)
end

function cm.filter(c)
    return c:IsCode(88810101) and c:IsAbleToGrave()
end

function cm.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function cm.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

function cm.repfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0xffc)
        and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end

function cm.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(cm.repfilter,1,nil,tp) end
    return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function cm.repval(e,c)
    return cm.repfilter(c,e:GetHandlerPlayer())
end

function cm.desrepop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RemoveCounter(ep,0x1001,1,REASON_EFFECT)
end
