--Abysslym Overdrive
--Script by TaxingCorn117
function c27796642.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,27796642)
    e1:SetCost(c27796642.cost)
    e1:SetTarget(c27796642.target)
    e1:SetOperation(c27796642.activate)
    c:RegisterEffect(e1)
    if c27796642.counter==nil then
        c27796642.counter=true
        c27796642[0]=0
        c27796642[1]=0
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
        e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
        e2:SetOperation(c27796642.clearop)
        Duel.RegisterEffect(e2,0)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_SPSUMMON_SUCCESS)
        e2:SetOperation(c27796642.checkop)
        Duel.RegisterEffect(e2,0)
    end
end
function c27796642.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x49c) and c:IsAbleToGraveAsCost()
end
function c27796642.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c27796642.cfilter,tp,LOCATION_REMOVED,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c27796642.cfilter,tp,LOCATION_REMOVED,0,3,3,nil)
    Duel.SendtoGrave(g,REASON_COST)
    e:GetHandler():RegisterFlagEffect(27796642,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c27796642.filter(c)
    return c:IsFaceup() and c:IsSetCard(0x49c) and c:IsType(TYPE_LINK)
end
function c27796642.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27796642.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c27796642.filter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,c27796642.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c27796642.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetReset(RESET_PHASE+PHASE_END)
    e2:SetCountLimit(1)
    e2:SetOperation(c27796642.drop)
    Duel.RegisterEffect(e2,tp)
end
function c27796642.checkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        if tc:IsSetCard(0x49c) and tc:IsSummonType(SUMMON_TYPE_LINK) then
            local p=tc:GetSummonPlayer()
            c27796642[p]=c27796642[p]+1
        end
        tc=eg:GetNext()
    end
end
function c27796642.clearop(e,tp,eg,ep,ev,re,r,rp)
    c27796642[0]=0
    c27796642[1]=0
end
function c27796642.drop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,27796642)
    Duel.Draw(tp,c27796642[tp],REASON_EFFECT)
end