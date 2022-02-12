--Rocksaber Harbringer
function c96643269.initial_effect(c)
    c:SetSPSummonOnce(96643269)
--    local NoF=Effect.CreateEffect(c)
--    NoF:SetType(EFFECT_TYPE_SINGLE)
--    NoF:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
--    NoF:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
--    NoF:SetValue(function(e,c) if not c then return false end return not c:IsSetCard(0xdfa) end)
--    c:RegisterEffect(NoF)
--    local NoS=NoF:Clone()
--    NoS:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
--    c:RegisterEffect(NoS)
--    local NoX=NoF:Clone()
--    NoX:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
--    c:RegisterEffect(NoX)
--    local NoL=NoF:Clone()
----    NoL:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
--    c:RegisterEffect(NoL)
    --link procedure
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,c96643269.mfilter,1)
    --release limit
--    local e0=Effect.CreateEffect(c)
--    e0:SetType(EFFECT_TYPE_SINGLE)
--    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
--    e0:SetRange(LOCATION_MZONE)
--    e0:SetCode(EFFECT_UNRELEASABLE_NONSUM)
--    e0:SetValue(1)
--    c:RegisterEffect(e0)
--    local e1=e0:Clone()
--    e1:SetCode(EFFECT_UNRELEASABLE_SUM)
--    e1:SetValue(c96643269.sumval)
--    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(581014,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetHintTiming(0,TIMING_END_PHASE)
    e2:SetCost(c96643269.thcost)
    e2:SetTarget(c96643269.target1)
    e2:SetOperation(c96643269.operation1)
    c:RegisterEffect(e2)
--    local e3=Effect.CreateEffect(c)
--    e3:SetDescription(aux.Stringid(96643269,1))
--    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
--    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
--    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
--    e3:SetCode(EVENT_TO_GRAVE)
--    e3:SetCountLimit(1,96643269)
--    e3:SetTarget(c96643269.sptg)
--    e3:SetOperation(c96643269.spop)
--    c:RegisterEffect(e3)
end
function c96643269.mfilter(c) 
    return c:IsSetCard(0xdfa) and not c:IsCode(96643269)
end
function c96643269.sumval(e,c)
    return not c:IsSetCard(0xdfa)
end
function c96643269.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xdfa) and c:IsAbleToGraveAsCost() and c:IsType(TYPE_PENDULUM)
end
function c96643269.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c96643269.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c96643269.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function c96643269.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c96643269.filter1(chkc) end
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c96643269.filter1,tp,LOCATION_GRAVE,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,c96643269.filter1,tp,LOCATION_GRAVE,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c96643269.operation1(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
    Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
    local g=Duel.GetOperatedGroup()
    if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
    local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
    if ct==3 then
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
function c96643269.filter1(c)
    return c:IsAbleToDeck() and c:IsSetCard(0xdfa)
end
function c96643269.filter(c,e,tp)
    return c:IsSetCard(0xdfa) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c96643269.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(c96643269.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c96643269.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c96643269.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end