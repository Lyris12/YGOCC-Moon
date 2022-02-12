--Rocksaber Venari
function c96643265.initial_effect(c)
    --pendulum summon
    aux.EnablePendulumAttribute(c)
    --special summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(96643265,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,432651)
    e1:SetCondition(c96643265.spcon)
    e1:SetCost(c96643265.spcost)
    e1:SetTarget(c96643265.sptg)
    e1:SetOperation(c96643265.spop)
    c:RegisterEffect(e1)
    --spsummon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(96643265,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,432652)
    e2:SetTarget(c96643265.target)
    e2:SetOperation(c96643265.operation)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
    --to grave
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(96643265,2))
    e5:SetCategory(CATEGORY_TOGRAVE)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetCountLimit(1,432652)
    e5:SetCondition(c96643265.tgcon)
    e5:SetTarget(c96643265.tgtg)
    e5:SetOperation(c96643265.tgop)
    c:RegisterEffect(e5)
end
function c96643265.spfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xdfa) and c:IsType(TYPE_LINK)
end
function c96643265.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(c96643265.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c96643265.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xdfa) and c:IsAbleToGraveAsCost()
end
function c96643265.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c96643265.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c96643265.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function c96643265.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(c96643265.spfilter,tp,LOCATION_MZONE,0,nil)
    if g:GetCount()<=0 then return false end
    local zone=0
    for tc in aux.Next(g) do
        zone=bit.bor(zone,tc:GetLinkedZone(tp))
    end
    zone=bit.band(zone,0x1f)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c96643265.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and zone~=0 then
        local g=Duel.GetMatchingGroup(c96643265.spfilter,tp,LOCATION_MZONE,0,nil)
        if g:GetCount()<=0 then return end
        local zone=0
        for tc in aux.Next(g) do
            zone=bit.bor(zone,tc:GetLinkedZone(tp))
        end
        zone=bit.band(zone,0x1f)
        Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP,zone)
    end
end
function c96643265.filter(c,e,tp)
    return c:IsSetCard(0xdfa) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function c96643265.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c96643265.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c96643265.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c96643265.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1,true)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2,true)
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e3:SetRange(LOCATION_MZONE)
        e3:SetCode(EVENT_PHASE+PHASE_END)
        e3:SetOperation(c96643265.desop)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e3:SetCountLimit(1)
        tc:RegisterEffect(e3,true)
        Duel.SpecialSummonComplete()
    end
end
function c96643265.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
function c96643265.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
function c96643265.tgfilter(c)
    return c:IsSetCard(0xdfa) and c:IsAbleToGrave()
end
function c96643265.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c96643265.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c96643265.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c96643265.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end