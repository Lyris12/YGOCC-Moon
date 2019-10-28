--Shadow of the Magium
local m=888825
local cm=_G["c"..m]
function cm.initial_effect(c)
    c:EnableCounterPermit(0x1001)
    c:SetCounterLimit(0x1001,5)
    --add counter
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_CHAINING)
    e0:SetRange(LOCATION_FZONE)
    e0:SetOperation(aux.chainreg)
    c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e1:SetCode(EVENT_CHAIN_SOLVED)
    e1:SetRange(LOCATION_FZONE)
    e1:SetOperation(cm.acop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(m,0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCode(EVENT_CUSTOM+m)
    e3:SetCost(cm.tgcost)
    e3:SetTarget(cm.tgtg)
    e3:SetOperation(cm.tgop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetDescription(aux.Stringid(m,1))
    e4:SetOperation(cm.ssop)
    c:RegisterEffect(e4)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_DESTROY_REPLACE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTarget(cm.desreptg)
    e5:SetOperation(cm.desrepop)
    c:RegisterEffect(e5)    
end

function cm.acop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetFlagEffect(1)>0 then
        c:AddCounter(0x1001,1)
        if c:GetCounter(0x1001)==5 then
            Duel.RaiseSingleEvent(c,EVENT_CUSTOM+m,re,0,0,p,0)
        end
    end
end

function cm.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler() and e:GetHandler():GetCounter(0x1001)==5 end 
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    e:GetHandler():RemoveCounter(tp,0x1001,5,REASON_COST)
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

function cm.ssop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function cm.filter2(c,e,tp)
    return c:IsSetCard(0xffc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function cm.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsReason(REASON_RULE)
        and e:GetHandler():GetCounter(0x1001)>0 end
    return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function cm.desrepop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RemoveCounter(ep,0x1001,1,REASON_EFFECT)
end
