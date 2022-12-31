--Paladawn Assembly
function c91672814.initial_effect(c)
    --activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,0x20)
    e1:SetCountLimit(1,91672814+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(c91672814.target)
    e1:SetOperation(c91672814.activate)
    c:RegisterEffect(e1)
end
function c91672814.filter(c,e,tp)
    return c:IsSetCard(0xbb8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function c91672814.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c91672814.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c91672814.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(c91672814.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c91672814.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
        local fid=c:GetFieldID()
        tc:RegisterFlagEffect(91672814,RESET_EVENT+0x1fe0000,0,1,fid)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e3:SetCode(EVENT_PHASE+PHASE_END)
        e3:SetCountLimit(1)
        e3:SetLabel(fid)
        e3:SetLabelObject(tc)
        e3:SetCondition(c91672814.descon)
        e3:SetOperation(c91672814.desop)
        Duel.RegisterEffect(e3,tp)
        Duel.SpecialSummonComplete()
    end
end
function c91672814.splimit(e,c)
    return not c:IsSetCard(0xbb8)
end
function c91672814.descon(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc:GetFlagEffect(91672814)~=0 then
        return true
    else
        e:Reset()
        return false
    end
end
function c91672814.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
