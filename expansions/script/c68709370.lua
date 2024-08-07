--Uni
--coded by Concordia
function c68709370.initial_effect(c)
    --special summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,68709370)
    e1:SetCondition(c68709370.spcon)
    c:RegisterEffect(e1)
    --draw
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(68709370,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,68719370)
    e2:SetCondition(c68709370.condition)
    e2:SetCost(c68709370.drawcost)
    e2:SetTarget(c68709370.target)
    e2:SetOperation(c68709370.operation)
    c:RegisterEffect(e2)
end
function c68709370.filter(c)
    return c:IsFaceup() and c:IsSetCard(0xf08) and not c:IsCode(68709370)
end
function c68709370.spcon(e,c)
    if c==nil then return true end
    return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c68709370.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function c68709370.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xf08) and not c:IsCode(68709370)
end
function c68709370.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(c68709370.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function c68709370.discardfilter(c)
    return c:IsSetCard(0xf08) and c:IsDiscardable()
end
function c68709370.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c68709370.discardfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    Duel.DiscardHand(tp,c68709370.discardfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c68709370.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
        and Duel.IsExistingMatchingCard(c68709370.discardfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c68709370.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(tp,1,REASON_EFFECT)
end