--Paladawn
function c91672801.initial_effect(c)
    --pendulum summon
    aux.EnablePendulumAttribute(c)
    --Token
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(91672801,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCondition(c91672801.spcon)
    e1:SetTarget(c91672801.sptg)
    e1:SetOperation(c91672801.spop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
end
function c91672801.spcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    return eg:GetCount()==1 and tc:GetSummonPlayer()==tp and tc:IsFaceup() and tc:IsSetCard(0xbb8) and not tc:IsType(TYPE_TOKEN) and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_TOKEN)
end
function c91672801.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,91672817,0xbb8,0x4011,0,0,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function c91672801.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,91672817,0xbb8,0x4011,0,0,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
    local token=Duel.CreateToken(tp,91672817)
    Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)    
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(c91672801.synlimit)
    e1:SetReset(RESET_EVENT+0x1fe0000)
    token:RegisterEffect(e1)
    Duel.SpecialSummonComplete()
    Duel.BreakEffect()
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function c91672801.synlimit(e,c)
    if not c then return false end
    return not c:IsSetCard(0xbb8)
end