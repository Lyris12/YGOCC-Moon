--Paladawn Recovery, <name>
function c91672813.initial_effect(c)
    c:SetUniqueOnField(1,0,91672813)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)    
    --add from extra
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(91672813,0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(c91672813.target)
    e2:SetOperation(c91672813.operation)
    c:RegisterEffect(e2)
    --draw
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(91672813,1))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(c91672813.drcon)
    e3:SetTarget(c91672813.drtg)
    e3:SetOperation(c91672813.drop)
    c:RegisterEffect(e3)
    if not c91672813.global_check then
        c91672813.global_check=true
        c91672813[0]=0
        c91672813[1]=0
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
        ge1:SetOperation(c91672813.checkop)
        Duel.RegisterEffect(ge1,0)
        local ge2=Effect.CreateEffect(c)
        ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
        ge2:SetOperation(c91672813.clearop)
        Duel.RegisterEffect(ge2,0)
    end
end
function c91672813.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xbb8)
end
function c91672813.thfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xbb8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c91672813.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroupCount(c91672813.cfilter,tp,LOCATION_PZONE,0,nil)
    if chk==0 then return Duel.IsExistingMatchingCard(c91672813.thfilter,tp,LOCATION_EXTRA,0,ct,nil) end
    local rg=Duel.GetMatchingGroup(c91672813.thfilter,tp,LOCATION_EXTRA,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,rg,ct,0,0)
end
function c91672813.operation(e,tp,eg,ep,ev,re,r,rp,chk)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local ct=Duel.GetMatchingGroupCount(c91672813.cfilter,tp,LOCATION_PZONE,0,nil)
    local rg=Duel.GetMatchingGroup(c91672813.thfilter,tp,LOCATION_EXTRA,0,nil)
    if rg:GetCount()<ct then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local sg=rg:Select(tp,ct,ct,nil)
    Duel.SendtoHand(sg,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,sg)
end

function c91672813.checkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        if tc:IsSetCard(0xbb8) and tc:IsSummonType(SUMMON_TYPE_LINK) then
            local p=tc:GetSummonPlayer()
            c91672813[p]=c91672813[p]+1
        end
        tc=eg:GetNext()
    end
end
function c91672813.clearop(e,tp,eg,ep,ev,re,r,rp)
    c91672813[0]=0
    c91672813[1]=0
end
function c91672813.drcon(e,tp,eg,ep,ev,re,r,rp)
    return c91672813[tp]>0
end
function c91672813.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,c91672813[tp]) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,c91672813[tp])
end
function c91672813.drop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Draw(tp,c91672813[tp],REASON_EFFECT)
end
