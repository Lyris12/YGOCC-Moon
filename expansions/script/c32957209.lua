--Mezka Izusa
function c32957209.initial_effect(c)
    --link summon
    aux.AddLinkProcedure(c,c32957209.matfilter,1,1)
    c:EnableReviveLimit()
    --search
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(32957209,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,32957209)
    e1:SetCondition(c32957209.thcon)
    e1:SetCost(c32957209.thcost)
    e1:SetTarget(c32957209.thtg)
    e1:SetOperation(c32957209.thop)
    c:RegisterEffect(e1)
    --stack deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(32957209,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(c32957209.target)
    e2:SetOperation(c32957209.operation)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(c32957209.condition)
    c:RegisterEffect(e3)
end
function c32957209.matfilter(c)
    return c:IsLinkSetCard(0xc70) and not c:IsLinkCode(32957209)
end
function c32957209.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c32957209.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,c)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c32957209.thfilter(c)
    return c:IsSetCard(0xc70) and c:IsAbleToHand()
end
function c32957209.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c32957209.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c32957209.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c32957209.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function c32957209.condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c32957209.filter(c)
    return c:IsSetCard(0xc70)
end
function c32957209.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(c32957209.filter,tp,LOCATION_DECK,0,nil)
        return g:GetClassCount(Card.GetCode)>=3
    end
end
function c32957209.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(c32957209.filter,tp,LOCATION_DECK,0,nil)
    if g:GetClassCount(Card.GetCode)>=3 then
        local rg=Group.CreateGroup()
        for i=1,3 do
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(32957209,1))
            local sg=g:Select(tp,1,1,nil)
            local tc=sg:GetFirst()
            rg:AddCard(tc)
            g:Remove(Card.IsCode,nil,tc:GetCode())
        end
        Duel.ConfirmCards(1-tp,rg)
        Duel.ShuffleDeck(tp)
        local tg=rg:GetFirst()
        while tg do
            Duel.MoveSequence(tg,0)
            tg=rg:GetNext()
        end
        Duel.SortDecktop(tp,tp,3)
    end
end