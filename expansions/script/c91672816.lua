--Paladawn Trials
function c91672816.initial_effect(c)
    c:EnableCounterPermit(0xbb1)
    c:SetCounterLimit(0xbb1,12)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --add counter
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetOperation(c91672816.ctop)
    c:RegisterEffect(e2)
    --atkdown
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetValue(c91672816.atkval)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e4)
    --set p
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(91672816,1))
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCost(c91672816.setcost)
    e5:SetCondition(c91672816.setcon)
    e5:SetTarget(c91672816.settg)
    e5:SetOperation(c91672816.setop)
    c:RegisterEffect(e5)
    --special summon
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(91672816,2))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_GRAVE)
    e6:SetCost(c91672816.spcost)
    e6:SetTarget(c91672816.sptg)
    e6:SetOperation(c91672816.spop)
    c:RegisterEffect(e6)
end
function c91672816.atkval(e,c)
    return e:GetHandler():GetCounter(0xbb1)*-200
end
function c91672816.ctfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xbb8) and c:IsType(TYPE_MONSTER)
end
function c91672816.ctop(e,tp,eg,ep,ev,re,r,rp)
    if eg:IsExists(c91672816.ctfilter,1,nil) then
        e:GetHandler():AddCounter(0xbb1,1)
    end
end
function c91672816.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0xbb1,3,REASON_COST) end
    e:GetHandler():RemoveCounter(tp,0xbb1,3,REASON_COST)
end
function c91672816.cfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_PZONE) and c:GetPreviousControler()==tp
end
function c91672816.setcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c91672816.cfilter,1,nil,tp)
end
function c91672816.setfilter(c)
    return c:IsSetCard(0xbb8) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c91672816.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
        and Duel.IsExistingMatchingCard(c91672816.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c91672816.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,c91672816.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
function c91672816.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function c91672816.spfilter(c,e,tp)
    return c:IsSetCard(0xbb8) and c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_HAND) or c:IsFaceup())
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c91672816.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(c91672816.spfilter,tp,LOCATION_HAND+LOCATION_PZONE+LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_PZONE+LOCATION_EXTRA)
end
function c91672816.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c91672816.spfilter,tp,LOCATION_HAND+LOCATION_PZONE+LOCATION_EXTRA,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end