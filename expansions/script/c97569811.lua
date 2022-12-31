--Silent Star Artemus
function c97569811.initial_effect(c)
    --draw
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(97569811,0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetTarget(c97569811.drtg)
    e1:SetOperation(c97569811.drop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    --search
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_CHAINING)
    e0:SetRange(LOCATION_MZONE)
    e0:SetOperation(aux.chainreg)
    c:RegisterEffect(e0)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(97569811,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_NO_TURN_RESET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(c97569811.thcon)
    e3:SetTarget(c97569811.thtg)
    e3:SetOperation(c97569811.thop)
    c:RegisterEffect(e3)
end
function c97569811.filter(c)
    return c:IsSetCard(0xd0a1) or c:IsSetCard(0xd0a2) and c:IsDiscardable(REASON_EFFECT)
end
function c97569811.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
        and Duel.IsExistingMatchingCard(c97569811.filter,tp,LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c97569811.drop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.DiscardHand(tp,c97569811.filter,1,1,REASON_EFFECT+REASON_DISCARD,nil)~=0 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
function c97569811.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsSetCard(0xd0a2) and c:IsType(TYPE_EQUIP) or c:GetFlagEffect(1)<=0 then return false end
    return c:GetColumnGroup():IsContains(re:GetHandler())
end
function c97569811.thfilter(c,rc)
    return c:IsSetCard(0xd0a1) and c:IsType(TYPE_MONSTER) and not c:IsCode(rc:GetCode()) and c:IsAbleToHand()
end
function c97569811.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local rc=re:GetHandler()
    if chk==0 then return rc and Duel.IsExistingMatchingCard(c97569811.thfilter,tp,LOCATION_DECK,0,1,nil,rc) end
    e:SetLabelObject(rc)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c97569811.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c97569811.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabelObject())
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end