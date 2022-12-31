--Silent Star Darius
function c97569816.initial_effect(c)
    --extra summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetOperation(c97569816.sumop)
    c:RegisterEffect(e1)
    --search
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_CHAINING)
    e0:SetRange(LOCATION_MZONE)
    e0:SetOperation(aux.chainreg)
    c:RegisterEffect(e0)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(97569816,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_NO_TURN_RESET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(c97569816.spcon)
    e3:SetTarget(c97569816.sptg)
    e3:SetOperation(c97569816.spop)
    c:RegisterEffect(e3)
end
function c97569816.sumop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,97569816)~=0 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
    e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd0a1))
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    Duel.RegisterFlagEffect(tp,99569816,RESET_PHASE+PHASE_END,0,1)
end
function c97569816.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or c:IsSetCard(0xd0a2) or c:IsType(TYPE_EQUIP) or c:GetFlagEffect(1)<=0 then return false end
    return c:GetColumnGroup():IsContains(re:GetHandler())
end
function c97569816.spfilter(c,e,tp)
    return c:IsLevelBelow(4) and c:IsSetCard(0xd0a1) and not c:IsCode(97569816) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function c97569816.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c97569816.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c97569816.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tg=Duel.SelectMatchingCard(tp,c97569816.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
    if tg then
        Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end