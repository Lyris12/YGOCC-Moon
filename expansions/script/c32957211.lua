--Mezka Mitsuki
function c32957211.initial_effect(c)
    --deck check
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(32957211,0))
    e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(c32957211.condition)
    e1:SetTarget(c32957211.target)
    e1:SetOperation(c32957211.operation)
    c:RegisterEffect(e1)
    --special
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(32957211,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,32957211)
    e2:SetCost(c32957211.spcost)
    e2:SetTarget(c32957211.sptg)
    e2:SetOperation(c32957211.spop)
    c:RegisterEffect(e2)
     --stack
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(32957211,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,32957211)
    e3:SetCondition(c32957211.setcon)
    e3:SetTarget(c32957211.settg)
    e3:SetOperation(c32957211.setop)
    c:RegisterEffect(e3)
end
function c32957211.cfilter(c)
    return c:IsFacedown() or not c:IsSetCard(0xc70)
end
function c32957211.condition(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(c32957211.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c32957211.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function c32957211.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
    Duel.ConfirmDecktop(tp,1)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if tc:IsSetCard(0xc70) then
        Duel.DisableShuffleCheck()
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
        Duel.BreakEffect()
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    else
        Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
        Duel.SendtoGrave(c,REASON_EFFECT)
    end
end
function c32957211.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function c32957211.spfilter(c,e,tp)
    return c:IsSetCard(0xc70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c32957211.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(c32957211.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function c32957211.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c32957211.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
function c32957211.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_REMOVED)
end
function c32957211.setfilter(c)
    return c:IsSetCard(0xc70) and c:IsType(TYPE_TRAP+TYPE_SPELL) and c:IsSSetable()
end
function c32957211.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c32957211.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c32957211.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,c32957211.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.SSet(tp,tc)
        Duel.ConfirmCards(1-tp,tc)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
