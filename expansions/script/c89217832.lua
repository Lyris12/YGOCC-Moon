--Dustflaw Hound
function c89217832.initial_effect(c)
    --Place in S/T Zone
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(c89217832.sttg)
    e1:SetOperation(c89217832.stop)
    c:RegisterEffect(e1)
    --Ritual Summon
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,id)
    e2:SetCondition(c89217832.spcon)
    e2:SetTarget(c89217832.sptg)
    e2:SetOperation(c89217832.spop)
    c:RegisterEffect(e2)
end
function c89217832.gfilter(c)
    return bit.band(c:GetType(),0x81)==0x81 and c:IsSetCard(0xff15) and not c:IsForbidden()
end
function c89217832.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c89217832.gfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c89217832.gfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(89217832,0))
    Duel.SelectTarget(tp,c89217832.gfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
function c89217832.stop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+0x1fc0000)
        e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
        tc:RegisterEffect(e1)
    end
end
function c89217832.spcon(e,tp,eg,ep,ev,re,r,rp)
    return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c89217832.spfilter(c,e,tp,mg)
    if not c:IsSetCard(0xff15) or bit.band(c:GetOriginalType(),0x81)~=0x81
        or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
    return mg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,mg:GetCount(),c)
end
function c89217832.cfilter(c)
    return c:IsType(TYPE_MONSTER) and c:GetLevel()>0 and c:IsAbleToRemove()
end
function c89217832.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(c89217832.cfilter,tp,LOCATION_GRAVE,0,nil)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(c89217832.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp,g) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,c89217832.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp,g)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_SZONE)
end
function c89217832.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    local mg=Duel.GetMatchingGroup(c89217832.cfilter,tp,LOCATION_GRAVE,0,nil)
    if mg:GetCount()>0 then
        local rg=mg:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel(),1,mg:GetCount(),tc)
        if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
            Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
        end
    end
end