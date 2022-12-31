--Calling of the Silent Star
function c97569828.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,97569828+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(c97569828.condition)
    e1:SetCost(c97569828.cost)
    e1:SetTarget(c97569828.target)
    e1:SetOperation(c97569828.activate)
    c:RegisterEffect(e1)
    Duel.AddCustomActivityCounter(97569828,ACTIVITY_SPSUMMON,c97569828.counterfilter)
end
function c97569828.counterfilter(c)
    return c:IsSetCard(0xd0a1)
end
function c97569828.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function c97569828.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetCustomActivityCount(97569828,tp,ACTIVITY_SPSUMMON)==0 end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetLabelObject(e)
    e1:SetTarget(c97569828.splimit)
    Duel.RegisterEffect(e1,tp)
end
function c97569828.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(0xd0a1)
end
function c97569828.filter1(c)
    return c:IsSetCard(0xd0a2) and c:IsAbleToHand()
end
function c97569828.filter2(c)
    return c:IsSetCard(0xd0a1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c97569828.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c97569828.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(c97569828.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c97569828.activate(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(c97569828.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
    local g2=Duel.GetMatchingGroup(c97569828.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if g1:GetCount()>0 and g2:GetCount()>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg1=g1:Select(tp,1,1,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg2=g2:Select(tp,1,1,nil)
        sg1:Merge(sg2)
        Duel.SendtoHand(sg1,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg1)
    end
end