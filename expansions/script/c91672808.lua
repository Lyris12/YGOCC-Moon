--Paladawn Removal
function c91672808.initial_effect(c)
    c:SetSPSummonOnce(91672808)
    --link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,c91672808.matfilter,2,2)
    --spsummon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(91672808,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(c91672808.descon)
    e1:SetTarget(c91672808.destg)
    e1:SetOperation(c91672808.desop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCondition(c91672808.descon1)
    c:RegisterEffect(e2)
end
function c91672808.matfilter(c)
    return c:IsLinkSetCard(0xbb8)
end
function c91672808.cfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_NORMAL)
end
function c91672808.descon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c91672808.cfilter,1,nil,tp)
end
function c91672808.cfilter1(c,tp)
    return c:IsType(TYPE_NORMAL) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
        and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function c91672808.descon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c91672808.cfilter1,1,nil,tp)
end
function c91672808.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c91672808.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end