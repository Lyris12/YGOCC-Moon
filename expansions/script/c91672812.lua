--Paladawn Unification
function c91672812.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(c91672812.activate)
    c:RegisterEffect(e1)
    --redirect
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetValue(LOCATION_REMOVED)
    e2:SetCondition(c91672812.remcon)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xbb8))
    c:RegisterEffect(e2)
    --atk&def
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetValue(c91672812.atkval)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e4)
end
function c91672812.thfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xbb8) and c:IsAbleToHand()
end
function c91672812.activate(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(c91672812.thfilter,tp,LOCATION_DECK,0,nil)
    if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(91672812,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end
function c91672812.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xbb8) and c:IsType(TYPE_PENDULUM)
end
function c91672812.atkval(e,c)
    local g=Duel.GetMatchingGroup(c91672812.atkfilter,c:GetControler(),LOCATION_EXTRA,0,nil)
    return g:GetClassCount(Card.GetCode)*200
end
function c91672812.remcon(e)
    return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil,0xbb8)
end