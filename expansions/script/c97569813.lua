--Silent Star Corwin
function c97569813.initial_effect(c)
    --spsummon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(97569813,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetRange(LOCATION_HAND)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCondition(c97569813.spcon)
    e1:SetTarget(c97569813.sptg)
    e1:SetOperation(c97569813.spop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    --tohand
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_CHAINING)
    e0:SetRange(LOCATION_MZONE)
    e0:SetOperation(aux.chainreg)
    c:RegisterEffect(e0)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(97569813,0))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_NO_TURN_RESET)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(c97569813.thcon)
    e3:SetTarget(c97569813.thtg)
    e3:SetOperation(c97569813.thop)
    c:RegisterEffect(e3)
end
function c97569813.cfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0xd0a1)
end
function c97569813.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c97569813.cfilter,1,nil,tp)
end
function c97569813.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c97569813.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function c97569813.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or c:IsSetCard(0xd0a2) or c:IsType(TYPE_EQUIP) or c:GetFlagEffect(1)<=0 then return false end
    return c:GetColumnGroup():IsContains(re:GetHandler())
end
function c97569813.thfilter(c,rc)
    return c:IsSetCard(0xd0a1) and not c:IsCode(rc:GetCode()) and c:IsAbleToHand()
end
function c97569813.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local rc=re:GetHandler()
    if chk==0 then return rc and Duel.IsExistingMatchingCard(c97569813.thfilter,tp,LOCATION_GRAVE,0,1,nil,rc) end
    e:SetLabelObject(rc)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c97569813.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c97569813.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,e:GetLabelObject())
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end