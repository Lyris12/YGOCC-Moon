--Rocksaber Retrival
function c96643272.initial_effect(c)
    --activate
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(96643272,0))
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetHintTiming(0,TIMING_END_PHASE)
    c:RegisterEffect(e0)
    --activate (return)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(96643272,1))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
    e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetCost(c96643272.drcost)
    e1:SetTarget(c96643272.drtg)
    e1:SetOperation(c96643272.drop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_SZONE)
    c:RegisterEffect(e2)
    --spsummon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(96643272,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetHintTiming(0,TIMING_END_PHASE)
    e3:SetCountLimit(1,96643272)
    e3:SetCost(c96643272.spcost)
    e3:SetTarget(c96643272.sptg)
    e3:SetOperation(c96643272.spop)
    c:RegisterEffect(e3)
end
function c96643272.tdfilter(c)
    return c:IsSetCard(0xdfa) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c96643272.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetFlagEffect(96643272)==0 and Duel.IsExistingMatchingCard(c96643272.tdfilter,tp,LOCATION_GRAVE,0,4,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,c96643272.tdfilter,tp,LOCATION_GRAVE,0,4,4,e:GetHandler())
    Duel.SendtoDeck(g,nil,2,REASON_COST)
    e:GetHandler():RegisterFlagEffect(96643272,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function c96643272.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c96643272.tefilter(c)
    return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xdfa) and not c:IsForbidden()
end
function c96643272.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    if Duel.Draw(p,d,REASON_EFFECT)~=0 then
        if not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil,0xdfa) then
        local g=Duel.GetMatchingGroup(c96643272.tefilter,tp,LOCATION_DECK,0,nil)
        if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(96643272,3)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(96643272,4))
            local sg=g:Select(tp,1,1,nil)
            Duel.SendtoExtraP(sg,tp,REASON_EFFECT)
        end
    end
end
end
function c96643272.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c96643272.filter(c,e,tp)
    return c:IsSetCard(0xdfa) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c96643272.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(c96643272.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c96643272.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c96643272.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end