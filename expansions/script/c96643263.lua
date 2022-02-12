--Rocksaber Ganvanka
function c96643263.initial_effect(c)
    --pendulum summon
    aux.EnablePendulumAttribute(c)
    --special summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(96643263,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,432631)
    e1:SetCondition(c96643263.spcon)
    e1:SetCost(c96643263.spcost)
    e1:SetTarget(c96643263.sptg)
    e1:SetOperation(c96643263.spop)
    c:RegisterEffect(e1)
    --tohand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(96643263,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,432632)
    e2:SetTarget(c96643263.target)
    e2:SetOperation(c96643263.operation)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
    --destroyz
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(96643263,2))
    e5:SetCategory(CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetCountLimit(1,432632)
    e5:SetCondition(c96643263.descon)
    e5:SetTarget(c96643263.destg)
    e5:SetOperation(c96643263.desop)
    c:RegisterEffect(e5)
end
function c96643263.spfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xdfa) and c:IsType(TYPE_LINK)
end
function c96643263.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(c96643263.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c96643263.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xdfa) and c:IsAbleToGraveAsCost()
end
function c96643263.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c96643263.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c96643263.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function c96643263.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(c96643263.spfilter,tp,LOCATION_MZONE,0,nil)
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
function c96643263.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and zone~=0 then
        local g=Duel.GetMatchingGroup(c96643263.spfilter,tp,LOCATION_MZONE,0,nil)
        if g:GetCount()<=0 then return end
        local zone=0
        for tc in aux.Next(g) do
            zone=bit.bor(zone,tc:GetLinkedZone(tp))
        end
        zone=bit.band(zone,0x1f)
        Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP,zone)
    end
end
function c96643263.filter(c)
    return c:IsSetCard(0xdfa) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c96643263.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c96643263.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c96643263.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c96643263.filter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function c96643263.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
function c96643263.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:GetLocation()==LOCATION_ONFIELD end
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c96643263.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    local tc=g:GetFirst()
    if g:GetCount()>0 then
        Duel.HintSelection(g)
        Duel.Destroy(g,REASON_EFFECT)
    end
end