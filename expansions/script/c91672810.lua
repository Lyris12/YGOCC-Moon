--Launselot, Paladawn Combatant
function c91672810.initial_effect(c)
    c:SetSPSummonOnce(91672810)
    --link summon
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xbb8),2)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(91672810,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(2)
    e1:SetCondition(c91672810.atkcon)
    e1:SetOperation(c91672810.atkop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
    local e4=e1:Clone()
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(c91672810.atkcon1)
    c:RegisterEffect(e4)
    --indes
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_INDESTRUCTABLE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TOKEN))
    e5:SetValue(c91672810.indesval)
    c:RegisterEffect(e5)
end
function c91672810.indesval(e,re,r,rp)
    return bit.band(r,REASON_RULE+REASON_BATTLE)==0
end
function c91672810.cfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_NORMAL)
end
function c91672810.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c91672810.cfilter,1,nil,tp)
end
function c91672810.cfilter1(c,tp)
    return c:IsType(TYPE_NORMAL) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
        and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function c91672810.atkcon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c91672810.cfilter1,1,nil,tp)
end
function c91672810.atkop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(c91672810.atktg)
    e1:SetValue(1000)
    e1:SetRange(LOCATION_MZONE)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function c91672810.atktg(e,c)
    return c:IsType(TYPE_TOKEN)
end
