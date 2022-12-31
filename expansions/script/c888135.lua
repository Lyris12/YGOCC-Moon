--Invocyte Plains
local id=888135
local m=888135
local cid=_G["c"..id]
local cm=_G["c"..m]
function cm.initial_effect(c)
    c:EnableCounterPermit(0xff8)
    c:SetCounterLimit(0xff8,5)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(cid.target)
    e1:SetOperation(cid.activate)
    c:RegisterEffect(e1)
    --counter
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetOperation(cm.counter)
    c:RegisterEffect(e2)
    --to hand
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(cm.thcon)
    e3:SetTarget(cm.thtg)
    e3:SetOperation(cm.thop)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetCondition(cid.battlecon)
    e4:SetTarget(cid.tg1)
    e4:SetOperation(cid.atkop)
    c:RegisterEffect(e4)    
end
function cm.cfilter(c)
    return c:IsSetCard(0xff8) and c:IsType(TYPE_MONSTER)
end
function cm.counter(e,tp,eg,ep,ev,re,r,rp)
    local ct=eg:FilterCount(cm.cfilter,nil)
    if ct>0 then
        e:GetHandler():AddCounter(0xff8,ct,true)
    end
end
function cm.thfilter(c)
    return c:IsSetCard(0xff8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(0xff8)>=2
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    e:GetHandler():RemoveCounter(tp,0xff8,2,REASON_EFFECT)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function cid.searchfilter(c)
    return c:IsSetCard(0xff8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.searchfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,cid.searchfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
    end
end
function cid.battlecon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return d~=nil and d:IsFaceup() and ((a:GetControler()==tp and a:IsSetCard(0xff8) and a:IsRelateToBattle() and a:GetAttack()<d:GetAttack())
        or (d:GetControler()==tp and d:IsSetCard(0xff8) and d:IsRelateToBattle() and d:GetAttack()<a:GetAttack()))
end
function cid.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        local tc=Duel.GetAttacker()
    local bc=Duel.GetAttackTarget()
    if not bc then return false end
    if bc:IsControler(1-tp) then bc=tc end
    e:SetLabelObject(bc)
    return bc:IsFaceup() and bc:IsSetCard(0xff8)
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if not a:IsRelateToBattle() or a:IsFacedown() or not d:IsRelateToBattle() or d:IsFacedown() then return end
    if a:IsControler(1-tp) then a,d=d,a end
   local dif=d:GetAttack()-a:GetAttack()
   if dif<0 then
    dif=-dif
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    e1:SetValue(1000)
    a:RegisterEffect(e1)
end