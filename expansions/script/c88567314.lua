--Divine Blade's Last Defense
function c88567314.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,88567314+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(c88567314.condition)
    e1:SetTarget(c88567314.target)
    e1:SetOperation(c88567314.activate)
    c:RegisterEffect(e1)
end
function c88567314.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1bc2)
end
function c88567314.condition(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
        and Duel.IsExistingMatchingCard(c88567314.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c88567314.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function c88567314.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end
