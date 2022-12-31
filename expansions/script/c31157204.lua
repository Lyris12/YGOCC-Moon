--Mezka Yuuka
function c31157204.initial_effect(c)
    --normal summon with 1 tribute
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(31157204,0))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(c31157204.otcon)
    e1:SetOperation(c31157204.otop)
    e1:SetValue(SUMMON_TYPE_ADVANCE)
    c:RegisterEffect(e1)
    --deck check
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31157204,1))
    e2:SetCategory(CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,0x1e0)
    e2:SetTarget(c31157204.target)
    e2:SetOperation(c31157204.operation)
    c:RegisterEffect(e2)
    --tohand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31157204,2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_REMOVE)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCondition(c31157204.thcon)
    e3:SetTarget(c31157204.thtg)
    e3:SetOperation(c31157204.thop)
    c:RegisterEffect(e3)
end
function c31157204.otfilter(c,tp)
    return c:IsSetCard(0xc70) and (c:IsControler(tp) or c:IsFaceup())
end
function c31157204.otcon(e,c,minc)
    if c==nil then return true end
    local tp=c:GetControler()
    local mg=Duel.GetMatchingGroup(c31157204.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
    return c:GetLevel()>6 and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
function c31157204.otop(e,tp,eg,ep,ev,re,r,rp,c)
    local mg=Duel.GetMatchingGroup(c31157204.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
    local sg=Duel.SelectTribute(tp,c,1,1,mg)
    c:SetMaterial(sg)
    Duel.Release(sg, REASON_SUMMON+REASON_MATERIAL)
end
function c31157204.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function c31157204.operation(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
    Duel.ConfirmDecktop(tp,1)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if tc:IsSetCard(0xc70) then
        Duel.DisableShuffleCheck()
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    else
        Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
    end
end
function c31157204.thcon(e,tp,eg,ep,ev,re,r,rp)
    if not re then return false end
    local rc=re:GetHandler()
    return e:GetHandler():IsReason(REASON_EFFECT) and rc:IsSetCard(0xc70) and rc:IsType(TYPE_MONSTER)
end
function c31157204.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c31157204.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end