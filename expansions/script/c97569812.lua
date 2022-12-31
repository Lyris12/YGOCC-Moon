--Silent Star Wulfric
function c97569812.initial_effect(c)
    --material
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(97569812,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetTarget(c97569812.mattg)
    e1:SetOperation(c97569812.matop)
    c:RegisterEffect(e1)
    --search
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_CHAINING)
    e0:SetRange(LOCATION_MZONE)
    e0:SetOperation(aux.chainreg)
    c:RegisterEffect(e0)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(97569812,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_NO_TURN_RESET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(c97569812.thcon)
    e3:SetTarget(c97569812.thtg)
    e3:SetOperation(c97569812.thop)
    c:RegisterEffect(e3)
end
function c97569812.matfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_XYZ)
end
function c97569812.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c97569812.matfilter(chkc) end
    if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
        and Duel.IsExistingTarget(c97569812.matfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,c97569812.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c97569812.matop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
        Duel.Overlay(tc,Group.FromCards(c))
    end
end
function c97569812.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or c:IsSetCard(0xd0a2) or c:IsType(TYPE_EQUIP) or c:GetFlagEffect(1)<=0 then return false end
    return c:GetColumnGroup():IsContains(re:GetHandler())
end
function c97569812.thfilter(c,rc)
    return c:IsSetCard(0xd0a1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(rc:GetCode()) and c:IsAbleToHand()
end
function c97569812.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local rc=re:GetHandler()
    if chk==0 then return rc and Duel.IsExistingMatchingCard(c97569812.thfilter,tp,LOCATION_DECK,0,1,nil,rc) end
    e:SetLabelObject(rc)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c97569812.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c97569812.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabelObject())
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end