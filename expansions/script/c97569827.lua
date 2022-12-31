--Memories Trapped Within The Silent Star
local m=97569827
function c97569827.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Move
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(1703,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_FZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(c97569827.seqtg)
    e2:SetOperation(c97569827.seqop)
    c:RegisterEffect(e2)
    --special summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(95714077,0))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,97569827)
    e3:SetCondition(c97569827.thcon)
    e3:SetTarget(c97569827.thtg)
    e3:SetOperation(c97569827.thop)
    c:RegisterEffect(e3)
    --Add
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(1703,2))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetRange(LOCATION_FZONE)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1,97569927)
    e4:SetCondition(c97569827.acon)
    e4:SetTarget(c97569827.atg)
    e4:SetOperation(c97569827.aop)
    c:RegisterEffect(e4)
end
function c97569827.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function c97569827.seqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
    local nseq=0
    if s==1 then nseq=0
    elseif s==2 then nseq=1
    elseif s==4 then nseq=2
    elseif s==8 then nseq=3
    else nseq=4 end
    Duel.MoveSequence(tc,nseq)
end
function c97569827.thcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xd0a1)
end
function c97569827.filter(c)
    return c:IsSetCard(0xd0a2) and c:IsAbleToHand()
end
function c97569827.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsFaceup() and c:IsRelateToEffect(e) and not c:IsStatus(STATUS_CHAINING)
        and Duel.IsExistingMatchingCard(c97569827.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c97569827.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c97569827.filter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function c97569827.cfilter(c,tp)
    return c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0xd0a2)
        and bit.band(c:GetPreviousTypeOnField(),TYPE_EQUIP)~=0
end
function c97569827.acon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c97569827.cfilter,1,nil,tp)
end
function c97569827.afilter(c,e,tp)
    return c:IsSetCard(0xd0a1) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function c97569827.atg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c97569827.afilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c97569827.aop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c97569827.afilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end