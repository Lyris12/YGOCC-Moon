--Spiral Drill Breakthrough!
function c96212376.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --direct attack
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EFFECT_DIRECT_ATTACK)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,96212371))
    c:RegisterEffect(e2)
    --Search
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,96212376)
    e3:SetCondition(c96212376.thcon)
    e3:SetTarget(c96212376.thtg)
    e3:SetOperation(c96212376.thop)
    c:RegisterEffect(e3)
end
function c96212376.thcfilter(c,tp)
    return c:IsPreviousSetCard(0x205)
        and c:GetPreviousControler()==tp and c:IsPreviousPosition(POS_FACEUP)
        and c:IsPreviousLocation(LOCATION_MZONE)
end
function c96212376.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c96212376.thcfilter,1,nil,tp)
end
function c96212376.thfilter(c)
    return c:IsSetCard(0x205) and not c:IsCode(96212376) and c:IsAbleToHand()
end
function c96212376.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c96212376.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c96212376.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end