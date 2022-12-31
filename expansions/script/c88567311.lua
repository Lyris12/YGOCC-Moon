--Divine Blade's Castle
function c88567311.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --atk up
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1bc2))
    e2:SetValue(300)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
    --draw
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(88567311,0))
    e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCountLimit(1)
    e4:SetTarget(c88567311.drtg)
    e4:SetOperation(c88567311.drop)
    c:RegisterEffect(e4)
    --act limit
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_CHAINING)
    e5:SetRange(LOCATION_FZONE)
    e5:SetOperation(c88567311.chainop)
    c:RegisterEffect(e5)
end
function c88567311.drfilter(c)
    return c:IsSetCard(0x1bc2) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c88567311.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp)
        and Duel.IsExistingMatchingCard(c88567311.drfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.SetTargetPlayer(tp)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function c88567311.drop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(p,c88567311.drfilter,p,LOCATION_HAND,0,1,63,nil)
    if g:GetCount()>0 then
        Duel.ConfirmCards(1-p,g)
        local ct=Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
        Duel.ShuffleDeck(p)
        Duel.BreakEffect()
        Duel.Draw(p,ct,REASON_EFFECT)
    end
end
function c88567311.chainop(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandler():IsSetCard(0x1bc2) and re:IsActiveType(TYPE_MONSTER) then
        Duel.SetChainLimit(c88567311.chainlm)
    end
end
function c88567311.chainlm(e,rp,tp)
    return tp==rp
end