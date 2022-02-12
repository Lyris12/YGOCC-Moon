--Rocksaber Plateau
function c96643270.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,96643270+EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
    --atk up
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xdfa))
    e2:SetValue(300)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
    --draw
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(96643270,1))
    e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCountLimit(1)
    e4:SetTarget(c96643270.drtg)
    e4:SetOperation(c96643270.drop)
    c:RegisterEffect(e4)
    --Add to hand
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(96643270,2))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetCountLimit(2)
    e5:SetCondition(c96643270.spcon)
    e5:SetTarget(c96643270.sptg)
    e5:SetOperation(c96643270.spop)
    c:RegisterEffect(e5)
end
function c96643270.drfilter(c)
    return c:IsSetCard(0xdfa) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c96643270.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp)
        and Duel.IsExistingMatchingCard(c96643270.drfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.SetTargetPlayer(tp)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function c96643270.drop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(p,c96643270.drfilter,p,LOCATION_HAND,0,1,63,nil)
    if g:GetCount()>0 then
        Duel.ConfirmCards(1-p,g)
        local ct=Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
        Duel.ShuffleDeck(p)
        Duel.BreakEffect()
        Duel.Draw(p,ct,REASON_EFFECT)
    end
end
function c96643270.egfilter(c)
    return c:IsSetCard(0xdfa) and c:IsReason(REASON_DESTROY)
end
function c96643270.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c96643270.egfilter,1,nil)
end
function c96643270.filter(c,e,tp)
    return c:IsSetCard(0xdfa) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c96643270.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(c96643270.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c96643270.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c96643270.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end