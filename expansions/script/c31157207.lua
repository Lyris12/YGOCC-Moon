--Mezka Izumi
function c31157207.initial_effect(c)
    --link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xc70),2,2)
    --to deck
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1)
    e1:SetTarget(c31157207.tdtg)
    e1:SetOperation(c31157207.tdop)
    c:RegisterEffect(e1)
    --tohand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31157207,0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(aux.bdocon)
    e2:SetTarget(c31157207.thtg)
    e2:SetOperation(c31157207.thop)
    c:RegisterEffect(e2)
    --mill
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31157207,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,31157207)
    e3:SetCondition(c31157207.condition)
    e3:SetTarget(c31157207.target)
    e3:SetOperation(c31157207.operation)
    c:RegisterEffect(e3)
end
function c31157207.tdfilter(c,e)
    return c:IsSetCard(0xc70) and c:IsAbleToDeck() and (not e or c:IsCanBeEffectTarget(e))
end
function c31157207.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    local g=Duel.GetMatchingGroup(c31157207.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
    if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
    local tg=Group.CreateGroup()
    repeat
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg=g:Select(tp,1,1,nil)
        tg:Merge(sg)
        g:Remove(Card.IsCode,nil,sg:GetFirst():GetCode())
    until tg:GetCount()==3
    Duel.SetTargetCard(tg)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,tg:GetCount(),0,0)
end
function c31157207.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if tg:GetCount()==0 then return end
    if Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)==0 then return end
    local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
    if ct>0 then Duel.SortDecktop(tp,tp,ct) end
end
function c31157207.thfilter(c)
    return c:IsSetCard(0xc70) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToHand()
end
function c31157207.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c31157207.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c31157207.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,c31157207.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c31157207.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end
function c31157207.condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c31157207.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
end
function c31157207.filter(c)
    return c:IsAbleToHand() and c:IsSetCard(0xc70)
end
function c31157207.operation(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsPlayerCanDiscardDeck(tp,3) then return end
    Duel.ConfirmDecktop(tp,3)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then
        Duel.DisableShuffleCheck()
        if g:IsExists(c31157207.filter,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=g:FilterSelect(tp,c31157207.filter,1,1,nil)
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
            Duel.ShuffleHand(tp)
            g:Sub(sg)
        end
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
    end
end