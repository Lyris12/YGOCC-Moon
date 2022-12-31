--Abysslym - Masterline Susano'o
--Script by TaxingCorn117
function c27796639.initial_effect(c)
    --link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,c27796639.matfilter,2)
    --draw
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(27796639,0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCondition(c27796639.condition)
    e1:SetTarget(c27796639.target)
    e1:SetOperation(c27796639.operation)
    c:RegisterEffect(e1)
    --negate
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetCountLimit(1)
    e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(c27796639.discon)
    e2:SetCost(c27796639.discost)
    e2:SetTarget(c27796639.distg)
    e2:SetOperation(c27796639.disop)
    c:RegisterEffect(e2)
end
function c27796639.matfilter(c)
    return c:IsLinkSetCard(0x49c) and not c:IsLinkCode(27796639)
end
function c27796639.condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c27796639.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x49c) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function c27796639.target(e,tp,eg,ep,ev,re,r,rp,chk)
         if chk==0 then return Duel.IsExistingMatchingCard(c27796639.cfilter,tp,LOCATION_REMOVED,0,1,nil)
            and Duel.IsPlayerCanDraw(tp,1) end
         Duel.SetTargetPlayer(tp)
         Duel.SetTargetParam(1)
         Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED)
         Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c27796639.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c27796639.cfilter,tp,LOCATION_REMOVED,0,1,3,nil)
    if g:GetCount()==0 then return end
    if Duel.SendtoGrave(g,REASON_COST+REASON_RETURN)~=0 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
function c27796639.discon(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function c27796639.discfilter(c)
    return c:IsSetCard(0x49c) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c27796639.discost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c27796639.discfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,c27796639.discfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c27796639.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function c27796639.disop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end