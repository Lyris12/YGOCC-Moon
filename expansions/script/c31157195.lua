--Mezka Kotomi
function c31157195.initial_effect(c)
    --deck check
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(31157195,0))
    e1:SetCategory(CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetTarget(c31157195.target)
    e1:SetOperation(c31157195.operation)
    c:RegisterEffect(e1)
    --special
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31157195,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,31157195)
    e2:SetCost(c31157195.spcost)
    e2:SetTarget(c31157195.sptg)
    e2:SetOperation(c31157195.spop)
    c:RegisterEffect(e2)
    --tohand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31157195,2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,31157195)
    e3:SetCondition(c31157195.thcon)
    e3:SetTarget(c31157195.thtg)
    e3:SetOperation(c31157195.thop)
    c:RegisterEffect(e3)
end
function c31157195.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
end
function c31157195.operation(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsPlayerCanDiscardDeck(tp,2) then return end
    Duel.ConfirmDecktop(tp,2)
    local g=Duel.GetDecktopGroup(tp,2)
    local tc=g:GetFirst()
    while tc do
        if tc:IsSetCard(0xc70) then
            Duel.DisableShuffleCheck()
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        else
            Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
        end
        tc=g:GetNext()
    end
end
function c31157195.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function c31157195.spfilter(c,e,tp)
    return c:IsSetCard(0xc70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31157195.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(c31157195.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function c31157195.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c31157195.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
function c31157195.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_REMOVED)
end
function c31157195.thfilter(c)
    return c:IsSetCard(0xc70) and c:IsAbleToHand()
end
function c31157195.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31157195.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c31157195.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,c31157195.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c31157195.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end