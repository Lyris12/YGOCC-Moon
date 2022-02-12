--Rocksaber Nightwalker
function c96643267.initial_effect(c)
    --link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xdfa),2,2)
    --to hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(96643267,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,432671)
    e1:SetCost(c96643267.thcost)
    e1:SetTarget(c96643267.thtg)
    e1:SetOperation(c96643267.thop)
    c:RegisterEffect(e1)
     --negate
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(96643267,1))
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,432672)
    e2:SetCondition(c96643267.negcon)
    e2:SetCost(c96643267.negcost)
    e2:SetTarget(c96643267.negtg)
    e2:SetOperation(c96643267.negop)
    c:RegisterEffect(e2)
end
function c96643267.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xdfa) and c:IsAbleToGraveAsCost()
end
function c96643267.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c96643267.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c96643267.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function c96643267.thfilter(c)
    return c:IsSetCard(0xdfa) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c96643267.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c96643267.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c96643267.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c96643267.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function c96643267.tfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0xdfa) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function c96643267.negcon(e,tp,eg,ep,ev,re,r,rp)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    return g and g:IsExists(c96643267.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function c96643267.cfilter1(c)
    return c:IsSetCard(0xdfa) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c96643267.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c96643267.cfilter1,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,c96643267.cfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c96643267.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function c96643267.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
        Duel.SendtoGrave(eg,REASON_EFFECT)
    end
end