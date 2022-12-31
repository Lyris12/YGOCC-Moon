--Legendary Sword of the Black Lotus
--Script by TaxingCorn117
function c27796627.initial_effect(c)
     --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(c27796627.target)
    e1:SetOperation(c27796627.operation)
    c:RegisterEffect(e1)
    --atk/def up
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(500)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
    --Untargetable
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e4:SetValue(aux.tgoval)
    c:RegisterEffect(e4)
    --Equip limit
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_EQUIP_LIMIT)
    e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e5:SetValue(c27796627.eqlimit)
    c:RegisterEffect(e5)
    --salvage
    local e6=Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_TOHAND)
    e6:SetDescription(aux.Stringid(27796627,1))
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_GRAVE)
    e6:SetCountLimit(1,27796627)
    e6:SetCost(c27796627.thcost)
    e6:SetTarget(c27796627.thtg)
    e6:SetOperation(c27796627.thop)
    c:RegisterEffect(e6)
end
--filters
function c27796627.filter(c)
    return c:IsFaceup() and c:IsSetCard(0x42d)
end
function c27796627.thfilter(c)
    return c:IsCode(27796626) and c:IsAbleToRemoveAsCost()
end
--Equip limit
function c27796627.eqlimit(e,c)
    return c:IsSetCard(0x42d)
end
--
function c27796627.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and c27796627.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c27796627.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,c27796627.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c27796627.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Equip(tp,e:GetHandler(),tc)
    end
end
--salvage
function c27796627.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c27796627.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,c27796627.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c27796627.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c27796627.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    end
end