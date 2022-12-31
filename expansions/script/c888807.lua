--Magium Torment
local m=888807
local cm=_G["c"..m]
function cm.initial_effect(c)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(m,0))
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,888107)
    e2:SetCost(cm.sscos)
    e2:SetOperation(cm.atop)
    c:RegisterEffect(e2)
    local e1=e2:Clone()
    e1:SetDescription(aux.Stringid(m,1))
    e1:SetCost(cm.sscos2)
    e1:SetCountLimit(1,888307)
    c:RegisterEffect(e1)
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetDescription(aux.Stringid(m,1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,m)
    e3:SetCost(cm.thcost)
    e3:SetTarget(cm.thtg)
    e3:SetOperation(cm.thop)
    c:RegisterEffect(e3)    
end

function cm.thfilter(c)
    return c:IsCode(88810101) and c:IsAbleToDeckAsCost()
end

function cm.thfilter2(c)
    return c:IsSetCard(0xffc) and c:IsReleasable()
end

function cm.sscos2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter2,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,cm.thfilter2,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Release(g,nil,1,REASON_COST)
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
function cm.damcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:GetOverlayCount()>0 and ep~=tp and c:GetFlagEffect(m)~=0
end

function cm.sscos(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SendtoDeck(g,nil,1,REASON_COST)
end

function cm.atop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetOperation(cm.regop)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVED)
    e2:SetReset(RESET_PHASE+PHASE_END)
    e2:SetCondition(cm.atkcon)
    e2:SetOperation(cm.atkop)
    Duel.RegisterEffect(e2,tp)
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,m,RESET_EVENT+RESET_CHAIN,0,1)
end

function cm.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetFlagEffect(tp,m)
end

function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
    local totalatk=0
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    local tc=g:GetFirst()
    while tc do
        local a1=tc:GetAttack()
        local ATK=Effect.CreateEffect(e:GetHandler())
        ATK:SetType(EFFECT_TYPE_SINGLE)
        ATK:SetCode(EFFECT_UPDATE_ATTACK)
        ATK:SetValue(-100)
        ATK:SetReset(RESET_EVENT+RESETS_STANDARD) 
        tc:RegisterEffect(ATK)
        local a2=tc:GetAttack()
            if a1>a2 then
            totalatk=totalatk+a1-a2
            end
        tc=g:GetNext()
    end
    if totalatk>0 then
        local lp=math.floor(totalatk/2)
        Duel.Recover(tp,lp,REASON_EFFECT)
    end
end


function cm.thfilter(c)
    return c:IsCode(88810101) and c:IsAbleToDeckAsCost()
end

function cm.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SendtoDeck(g,nil,1,REASON_COST)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    end
end















