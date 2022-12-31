--Mezka Arming
function c31157201.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(31157201,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(c31157201.target)
    e1:SetOperation(c31157201.activate)
    c:RegisterEffect(e1)
    --SpecialSummon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31157201,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_REMOVE)
    e2:SetCondition(c31157201.spcon)
    e2:SetTarget(c31157201.sptg)
    e2:SetOperation(c31157201.spop)
    c:RegisterEffect(e2)
end
function c31157201.filter(c)
    return c:IsSetCard(0xc70) and c:IsType(TYPE_MONSTER)
end
function c31157201.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(c31157201.filter,tp,LOCATION_DECK,0,nil)
        return g:GetClassCount(Card.GetCode)>=3
    end
end
function c31157201.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(c31157201.filter,tp,LOCATION_DECK,0,nil)
    if g:GetClassCount(Card.GetCode)>=3 then
        local rg=Group.CreateGroup()
        for i=1,3 do
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31157201,1))
            local sg=g:Select(tp,1,1,nil)
            local tc=sg:GetFirst()
            rg:AddCard(tc)
            g:Remove(Card.IsCode,nil,tc:GetCode())
        end
        Duel.ConfirmCards(1-tp,rg)
        Duel.ShuffleDeck(tp)
        local tg=rg:GetFirst()
        while tg do
            Duel.MoveSequence(tg,0)
            tg=rg:GetNext()
        end
        Duel.SortDecktop(tp,tp,3)
    end
end
function c31157201.spcon(e,tp,eg,ep,ev,re,r,rp)
    if not re then return false end
    local rc=re:GetHandler()
    return e:GetHandler():IsReason(REASON_EFFECT) and rc:IsSetCard(0xc70) and rc:IsType(TYPE_MONSTER)
end
function c31157201.spfilter(c,e,tp)
    return c:IsSetCard(0xc70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31157201.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c31157201.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c31157201.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c31157201.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end