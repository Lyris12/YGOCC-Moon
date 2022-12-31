--Euphemia, Mentor of the Silent Star
function c97569825.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xd0a1),2,2)
    --banish & search
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(97569825,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,97569825)
    e1:SetTarget(c97569825.thtg)
    e1:SetOperation(c97569825.thop)
    c:RegisterEffect(e1)
    --ret&draw
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(97569825,1))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(c97569825.drtg)
    e3:SetOperation(c97569825.drop)
    e3:SetCountLimit(1,97569925)
    c:RegisterEffect(e3)
end
function c97569825.rmfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xd0a1) and c:IsAbleToRemove()
end
function c97569825.thfilter(c)
    return c:IsSetCard(0xd0a1) and c:IsType(TYPE_MONSTER) and not c:IsCode(97569825) and c:IsAbleToHand()
end
function c97569825.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c97569825.rmfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c97569825.rmfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(c97569825.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,c97569825.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c97569825.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0
        and tc:IsLocation(LOCATION_REMOVED) then
        local ct=1
        if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then ct=2 end
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e1:SetLabelObject(tc)
        e1:SetCountLimit(1)
        e1:SetCondition(c97569825.retcon)
        e1:SetOperation(c97569825.retop)
        if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
            e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
            e1:SetValue(Duel.GetTurnCount())
        else
            e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
            e1:SetValue(0)
        end
        Duel.RegisterEffect(e1,tp)
        tc:RegisterFlagEffect(97569825,RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,ct)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,c97569825.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if g:GetCount()>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end
function c97569825.retcon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
    return e:GetLabelObject():GetFlagEffect(97569825)~=0
end
function c97569825.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    Duel.ReturnToField(tc)
end
function c97569825.drfilter(c)
    return (c:IsSetCard(0xd0a1) or c:IsSetCard(0xd0a2)) and c:IsAbleToDeck()
end
function c97569825.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97569825.drfilter(chkc) end
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c97569825.drfilter,tp,LOCATION_GRAVE,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,c97569825.drfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c97569825.drop(e,tp,eg,ep,ev,re,r,rp)
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
