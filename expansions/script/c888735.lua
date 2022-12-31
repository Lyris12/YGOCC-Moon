--World Born By Stars
local m=888735
local cm=_G["c"..m]
function cm.initial_effect(c)
        --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
       --atk&def
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xff1))
    e2:SetValue(300)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(cm.tg)
    e4:SetOperation(cm.regop)
    c:RegisterEffect(e4)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCondition(cm.handcon)
    e5:SetOperation(cm.atkop)
    c:RegisterEffect(e5)
end

function cm.cfilter(c,e,tp)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsSetCard(0xff1)
end

function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    return eg:IsExists(cm.cfilter,1,nil,e,tp)
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(32904923,1))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1,m)
    e1:SetRange(LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND+LOCATION_OVERLAY+LOCATION_REMOVED)
    e1:SetTarget(cm.btg)
    e1:SetOperation(cm.bop)
    e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end

function cm.thfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xff1) and c:IsAbleToHand()
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(cm.thfilter,tp,LOCATION_DECK,0,nil)
    if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(5697558,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end
function cm.btg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function cm.bop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end

function cm.filter1(c,tp)
    return c:GetOwner()==1-tp
end
function cm.filter2(c,tp)
    return c:GetOwner()==tp
end
   
function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
    local totalatk=0
    local d1=eg:FilterCount(cm.filter1,nil,tp)
    local d2=eg:FilterCount(cm.filter2,nil,tp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    local tc=g:GetFirst()
    while tc do
        local a1=tc:GetAttack()
        local ATK=Effect.CreateEffect(e:GetHandler())
        ATK:SetType(EFFECT_TYPE_SINGLE)
        ATK:SetCode(EFFECT_UPDATE_ATTACK)
        ATK:SetValue(0-(100*(d1+d2)))
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

function cm.handcon(e)
    return Duel.IsExistingMatchingCard(cm.cfilter2,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function cm.cfilter2(c)
    return c:IsSetCard(0xff1)
end