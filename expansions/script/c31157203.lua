--Mezka Launch
function c31157203.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,31157203+EFFECT_COUNT_CODE_OATH)
    e1:SetCost(c31157203.cost)
    e1:SetTarget(c31157203.target)
    e1:SetOperation(c31157203.activate)
    c:RegisterEffect(e1)
    --shuffle draw
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31157203,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_REMOVE)
    e2:SetCondition(c31157203.drcon)
    e2:SetTarget(c31157203.drtg)
    e2:SetOperation(c31157203.drop)
    c:RegisterEffect(e2)
end
function c31157203.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xc70) and c:IsAbleToRemoveAsCost()
end
function c31157203.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c31157203.cfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,c31157203.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c31157203.spfilter1(c,e,tp)
    return c:IsSetCard(0xc70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingMatchingCard(c31157203.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function c31157203.spfilter2(c,e,tp,code)
    return c:IsSetCard(0xc70) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31157203.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c31157203.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function c31157203.activate(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsPlayerAffectedByEffect(tp,59822133)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g1=Duel.SelectMatchingCard(tp,c31157203.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if g1:GetCount()<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g2=Duel.SelectMatchingCard(tp,c31157203.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,g1:GetFirst():GetCode())
        g1:Merge(g2)
        Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
    end
end
function c31157203.drcon(e,tp,eg,ep,ev,re,r,rp)
    if not re then return false end
    local rc=re:GetHandler()
    return e:GetHandler():IsReason(REASON_EFFECT) and rc:IsSetCard(0xc70) and rc:IsType(TYPE_MONSTER)
end
function c31157203.drfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc70) and c:IsAbleToDeck()
end
function c31157203.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c31157203.drfilter,tp,LOCATION_REMOVED,0,1,nil) end
    local g=Duel.GetMatchingGroup(c31157203.drfilter,tp,LOCATION_REMOVED,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
    if g:GetCount()>3 then Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1) end
end
function c31157203.drop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(c31157203.drfilter,tp,LOCATION_REMOVED,0,nil)
    if g:GetCount()>0 and Duel.SendtoDeck(g,nil,2,REASON_EFFECT)>=3 then
        if g:Filter(Card.IsLocation,nil,LOCATION_DECK):FilterCount(Card.IsControler,nil,tp)>0 then Duel.ShuffleDeck(tp) end
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end