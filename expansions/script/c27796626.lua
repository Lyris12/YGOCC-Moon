--Black Lotus
--Script by TaxingCorn117
function c27796626.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,27796626+EFFECT_COUNT_CODE_OATH)
    e1:SetCost(c27796626.cost)
    e1:SetTarget(c27796626.target)
    e1:SetOperation(c27796626.activate)
    c:RegisterEffect(e1)
    Duel.AddCustomActivityCounter(27796626,ACTIVITY_SPSUMMON,c27796626.counterfilter)
    --disable
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(27796626,0))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCountLimit(1)
    e3:SetCondition(c27796626.rmcon)
    e3:SetTarget(c27796626.rmtg)
    e3:SetOperation(c27796626.rmop)
    c:RegisterEffect(e3)
end
--filters
function c27796626.counterfilter(c)
    return c:IsSetCard(0x42d)
end
function c27796626.filter(c)
    return c:IsLevelBelow(4) and c:IsSetCard(0x42d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c27796626.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x42d)
end
function c27796626.rmfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
--Activate
function c27796626.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c27796626.filter,tp,LOCATION_DECK,0,1,nil)
        and Duel.GetCustomActivityCount(27796626,tp,ACTIVITY_SPSUMMON)==0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c27796626.filter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_COST)
        Duel.ConfirmCards(1-tp,g)
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(c27796626.splimit)
    Duel.RegisterEffect(e1,tp)
end
function c27796626.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(0x42d)
end
function c27796626.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
        and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c27796626.activate(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
    if g:GetCount()<2 or not Duel.IsPlayerCanDraw(tp) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local dg=g:Select(tp,2,2,nil)
    Duel.SendtoDeck(dg,nil,2,REASON_EFFECT)
    Duel.ShuffleDeck(tp)
    Duel.BreakEffect()
    Duel.Draw(tp,1,REASON_EFFECT)
end
--banish
function c27796626.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(c27796626.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
function c27796626.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and c27796626.rmfilter(chkc) and chkc~=e:GetHandler() end
    if chk==0 then return Duel.IsExistingTarget(c27796626.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,c27796626.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c27796626.rmop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
    end
end