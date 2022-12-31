--Asmitala Park
local m=888030
local cm=_G["c"..m]
function cm.initial_effect(c)
        --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xffa))
    e2:SetValue(200)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetCondition(cm.immcon)
    e3:SetTarget(cm.etarget)
    e3:SetValue(cm.efilter)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(38648116,0))
    e4:SetCategory(CATEGORY_TOEXTRA)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(cm.swaptg)
    e4:SetOperation(cm.swapop)
    c:RegisterEffect(e4)
end
function cm.swapfilter1(c,tp)
    return c:IsFaceup() and c:IsSetCard(0xffa) and c:IsType(TYPE_PENDULUM)
        and Duel.IsExistingMatchingCard(cm.swapfilter2,tp,LOCATION_EXTRA,0,1,c,c:GetCode())
end
function cm.swapfilter2(c,code)
    return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xffa) and c:GetCode()~=code
end
function cm.swaptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and cm.swapfilter1(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(cm.swapfilter1,tp,LOCATION_PZONE,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(18210764,1))
    local g=Duel.SelectTarget(tp,cm.swapfilter1,tp,LOCATION_PZONE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cm.swapop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        if Duel.SendtoHand(tc,tp,REASON_EFFECT)~=0 then
            local seq=Duel.GetOperatedGroup():GetFirst():GetPreviousSequence()
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76794549,6))
            local g=Duel.SelectMatchingCard(tp,cm.swapfilter2,tp,LOCATION_EXTRA,0,1,1,tc,tc:GetCode())
            local swap=g:GetFirst()
            if swap then
                Duel.MoveToField(swap,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
                Duel.MoveSequence(swap,seq)
            end
        end
    end
end
function cm.immcon(e)
    return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil,0xffa)
end
function cm.etarget(e,c)
    return c:IsSetCard(0xffa) and not c:IsType(TYPE_EFFECT)
end
function cm.efilter(e,re)
    return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
