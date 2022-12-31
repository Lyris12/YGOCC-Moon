--Paladawn Recovery
function c91672807.initial_effect(c)
   c:SetSPSummonOnce(91672807)
    --link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,c91672807.matfilter,2,2)
    --spsummon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(91672807,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(c91672807.thcon)
    e1:SetTarget(c91672807.thtg)
    e1:SetOperation(c91672807.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCondition(c91672807.thcon1)
    c:RegisterEffect(e2)
end
function c91672807.matfilter(c)
    return c:IsLinkSetCard(0xbb8)
end
function c91672807.cfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_NORMAL)
end
function c91672807.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c91672807.cfilter,1,nil,tp)
end
function c91672807.cfilter1(c,tp)
    return c:IsType(TYPE_NORMAL) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
        and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function c91672807.thcon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c91672807.cfilter1,1,nil,tp)
end
function c91672807.filter(c)
    return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xbb8) and c:IsAbleToHand()
end
function c91672807.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c91672807.filter,tp,LOCATION_EXTRA+LOCATION_PZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA+LOCATION_PZONE)
end
function c91672807.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c91672807.filter,tp,LOCATION_EXTRA+LOCATION_PZONE,0,1,2,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end