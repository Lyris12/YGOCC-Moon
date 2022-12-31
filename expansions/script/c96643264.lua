--Rocksaber Treula
function c96643264.initial_effect(c)
    --pendulum summon
    aux.EnablePendulumAttribute(c)
    --special summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(96643264,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,432641)
    e1:SetCondition(c96643264.spcon)
    e1:SetCost(c96643264.spcost)
    e1:SetTarget(c96643264.sptg)
    e1:SetOperation(c96643264.spop)
    c:RegisterEffect(e1)
    --spsummon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(96643264,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,432642)
    e2:SetTarget(c96643264.target)
    e2:SetOperation(c96643264.operation)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
    --special from grave
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(96643264,2))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetCountLimit(1,433642)
    e5:SetCondition(c96643264.spcon1)
    e5:SetTarget(c96643264.sptg1)
    e5:SetOperation(c96643264.spop1)
    c:RegisterEffect(e5)
end
function c96643264.spfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xdfa) and c:IsType(TYPE_LINK)
end
function c96643264.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(c96643264.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c96643264.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xdfa) and c:IsAbleToGraveAsCost()
end
function c96643264.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c96643264.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c96643264.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function c96643264.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(c96643264.spfilter,tp,LOCATION_MZONE,0,nil)
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
function c96643264.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and zone~=0 then
        local g=Duel.GetMatchingGroup(c96643264.spfilter,tp,LOCATION_MZONE,0,nil)
        if g:GetCount()<=0 then return end
        local zone=0
        for tc in aux.Next(g) do
            zone=bit.bor(zone,tc:GetLinkedZone(tp))
        end
        zone=bit.band(zone,0x1f)
        Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP,zone)
    end
end
function c96643264.spfilter1(c,e,tp)
    return c:IsSetCard(0xdfa) and not c:IsCode(96643264) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c96643264.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp)end
    if chk==0 then
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if ft<-1 then return false end
        local loc=LOCATION_ONFIELD
        if ft==0 then loc=LOCATION_MZONE end
        e:SetLabel(loc)
        return Duel.IsExistingTarget(aux.TRUE,tp,loc,0,1,nil)
            and Duel.IsExistingMatchingCard(c96643264.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c96643264.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
    if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,c96643264.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if sg:GetCount()>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
function c96643264.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
function c96643264.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(c96643264.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c96643264.spop1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c96643264.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end