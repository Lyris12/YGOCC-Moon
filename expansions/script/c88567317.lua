--Starlia, Dark Jewel of Divine Blade
function c88567317.initial_effect(c)
    --xyz summon
    aux.AddXyzProcedure(c,c88567317.mfilter,5,2,c88567317.ovfilter,aux.Stringid(88567317,0),99,c88567317.xyzop)
    c:EnableReviveLimit()
    --ret&draw
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(88567317,1))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(c88567317.cost)
    e1:SetTarget(c88567317.target)
    e1:SetOperation(c88567317.operation)
    c:RegisterEffect(e1)
    --indes
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e4:SetTarget(c88567317.indtg)
    e4:SetValue(c88567317.indct)
    c:RegisterEffect(e4)
end
function c88567317.indtg(e,c)
    return c:IsSetCard(0x1bc2)
end
function c88567317.indct(e,re,r,rp)
    if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
        return 1
    else return 0 end
end
function c88567317.mfilter(c)
    return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c88567317.ovfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1bc2) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ) and c:GetRank()==4
end
function c88567317.xyzop(e,tp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,88567317)==0 end
    Duel.RegisterFlagEffect(tp,88567317,RESET_PHASE+PHASE_END,0,1)
end
function c88567317.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c88567317.filter(c)
    return c:IsSetCard(0x1bc2) and c:IsAbleToDeck()
end
function c88567317.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c88567317.filter(chkc) end
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c88567317.filter,tp,LOCATION_GRAVE,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,c88567317.filter,tp,LOCATION_GRAVE,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c88567317.operation(e,tp,eg,ep,ev,re,r,rp)
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