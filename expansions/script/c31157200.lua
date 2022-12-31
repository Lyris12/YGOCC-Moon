--Mezka Yumi
function c31157200.initial_effect(c)
    --link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xc70),2)
    --banish
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(31157200,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,31157200)
    e1:SetCondition(c31157200.tgcon)
    e1:SetTarget(c31157200.tgtg)
    e1:SetOperation(c31157200.tgop)
    c:RegisterEffect(e1)
    --discard deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31157200,2))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCategory(CATEGORY_DECKDES)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_REMOVE)
    e2:SetCountLimit(1,31157200+100)
    e2:SetCondition(c31157200.ddcon)
    e2:SetTarget(c31157200.ddtg)
    e2:SetOperation(c31157200.ddop)
    c:RegisterEffect(e2)
    --to hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31157200,0))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e3:SetCondition(c31157200.thcon)
    e3:SetTarget(c31157200.thtg)
    e3:SetOperation(c31157200.thop)
    c:RegisterEffect(e3)
end
function c31157200.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c31157200.filter(c)
    return c:IsSetCard(0xc70) and c:IsAbleToRemove()
end
function c31157200.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c31157200.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function c31157200.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,c31157200.filter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetRange(LOCATION_REMOVED)
        e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e1:SetCountLimit(1)
        e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
        e1:SetCondition(c31157200.thcon1)
        e1:SetOperation(c31157200.thop1)
        e1:SetLabel(0)
        tc:RegisterEffect(e1)
    end
end
function c31157200.thcon1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function c31157200.thop1(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    e:GetHandler():SetTurnCounter(ct+1)
    if ct==1 then
        Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,e:GetHandler())
    else e:SetLabel(1) end
end
function c31157200.cfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_DECK) and c:GetPreviousControler()==tp
end
function c31157200.ddcon(e,tp,eg,ep,ev,re,r,rp)
    return bit.band(r,REASON_EFFECT)~=0 and eg:IsExists(c31157200.cfilter,1,nil,tp)
end
function c31157200.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
end
function c31157200.ddop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsPlayerCanDiscardDeck(tp,3) then return end
    Duel.ConfirmDecktop(tp,3)
    local g=Duel.GetDecktopGroup(tp,3)
    local tc=g:GetFirst()
    while tc do
        if tc:IsSetCard(0xc70) then
            Duel.DisableShuffleCheck()
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        else
            Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
        end
        tc=g:GetNext()
    end
end
function c31157200.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT) and c:GetPreviousControler()==tp))
        and c:IsPreviousPosition(POS_FACEUP)
end
function c31157200.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c31157200.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
    Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
end