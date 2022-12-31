--Spiral Drill Memories
function c96212379.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(96212379,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(c96212379.target)
    e1:SetOperation(c96212379.activate)
    c:RegisterEffect(e1)
    --tohand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(96212379,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(aux.exccon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(c96212379.thtg)
    e2:SetOperation(c96212379.thop)
    c:RegisterEffect(e2)
end
function c96212379.filter(c,e,tp)
    return c:IsSetCard(0x205) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c96212379.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c96212379.filter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(c96212379.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,c96212379.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c96212379.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE+PHASE_END)
        e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetRange(LOCATION_MZONE)
        e2:SetCountLimit(1)
        e2:SetOperation(c96212379.tdop)
        e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2)
    end
end
function c96212379.tdop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
end
function c96212379.thfilter(c)
    return c:IsSetCard(0x205) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c96212379.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c96212379.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c96212379.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=Duel.SelectTarget(tp,c96212379.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
function c96212379.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end
