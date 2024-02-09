--Mezka Melodia
function c31157205.initial_effect(c)
    --destroy replace
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetRange(LOCATION_HAND)
    e1:SetTarget(c31157205.reptg)
    e1:SetValue(c31157205.repval)
    e1:SetOperation(c31157205.repop)
    c:RegisterEffect(e1)
    --deck check
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31157205,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCost(c31157205.spcost)
    e2:SetTarget(c31157205.sptg)
    e2:SetOperation(c31157205.spop)
    c:RegisterEffect(e2)
    --handes
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31157205,1))
    e3:SetCategory(CATEGORY_HANDES)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(c31157205.hdcon)
    e3:SetTarget(c31157205.hdtg)
    e3:SetOperation(c31157205.hdop)
    c:RegisterEffect(e3)
end
function c31157205.repfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0xc70) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function c31157205.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() and eg:IsExists(c31157205.repfilter,1,nil,tp) end
    return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function c31157205.repval(e,c)
    return c31157205.repfilter(c,e:GetHandlerPlayer())
end
function c31157205.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD)
end
function c31157205.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0xc70) end
    local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0xc70)
    Duel.Release(g,REASON_COST)
end
function c31157205.spfilter(c,e,tp)
    return c:IsSetCard(0xc70) and not c:IsCode(31157205) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31157205.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(c31157205.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function c31157205.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c31157205.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
function c31157205.hdcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_REMOVED)
end
function c31157205.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0 end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function c31157205.hdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
    Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end