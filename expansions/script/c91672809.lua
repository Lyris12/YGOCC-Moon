--Alphonse, Paladawn Defense
function c91672809.initial_effect(c)
    c:SetSPSummonOnce(91672809)
    --link summon
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xbb8),2)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(91672809,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(2)
    e1:SetCondition(c91672809.con)
    e1:SetOperation(c91672809.op)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
    local e4=e1:Clone()
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(c91672809.con1)
    c:RegisterEffect(e4)
    --indes
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_INDESTRUCTABLE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TOKEN))
    e5:SetValue(c91672809.indesval)
    c:RegisterEffect(e5)
end
function c91672809.indesval(e,re,r,rp)
    return bit.band(r,REASON_RULE+REASON_EFFECT)==0
end
function c91672809.cfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_NORMAL)
end
function c91672809.con(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c91672809.cfilter,1,nil,tp)
end
function c91672809.cfilter1(c,tp)
    return c:IsType(TYPE_NORMAL) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
        and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function c91672809.con1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c91672809.cfilter1,1,nil,tp)
end
function c91672809.op(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(c91672809.discon)
    e1:SetOperation(c91672809.disop)
    e1:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
end
function c91672809.cfilter2(c,seq2)
    local seq1=aux.MZoneSequence(c:GetSequence())
    return c:IsFaceup() and c:IsSetCard(0xbb8) and seq1==4-seq2
end
function c91672809.discon(e,tp,eg,ep,ev,re,r,rp)
    local loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
    seq=aux.MZoneSequence(seq)
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE
        and Duel.IsExistingMatchingCard(c91672809.cfilter2,tp,LOCATION_MZONE,0,1,nil,seq)
end
function c91672809.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,91672809)
    Duel.NegateEffect(ev)
end