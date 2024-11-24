--Ignitronix Plasmawave Propulsorium
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,s.matfilter,1,1,Card.IsPositive,1,1,Card.IsNegative,1,1)
	--When your opponent activates a card or effect (Quick Effect): You can decrease the Energy of your Engaged "Ignitronix Engine" by 3; negate the activation, and if you do, banish it. 
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.negcon)
    e1:SetCost(s.negcost)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
	--If this card is destroyed by battle or card effect: You can Equip 1 "Ignitronix" monster from your Deck or GY to a face-up monster on the field.
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.eqcon)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)
end
function s.matfilter(c)
	return c:IsNeutral() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) and Duel.IsChainNegatable(ev) and ep~=tp
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local en=Duel.GetEngagedCard(tp)
    if chk==0 then return en and en:IsMonster(TYPE_DRIVE) and en:IsCode(77222587) and en:IsCanUpdateEnergy(-3,tp,REASON_COST) end
    en:UpdateEnergy(-3,tp,REASON_COST,true,e:GetHandler())
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
    end
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) 
end
function s.eqfilter(c)
    return c:IsSetCard(0x725) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
        and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    local eq=g:GetFirst()
    if eq then
        if not Duel.Equip(tp,eq,tc) then return end
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(s.eqlimit)
        e1:SetLabelObject(tc)
        eq:RegisterEffect(e1)
    end
end
function s.eqlimit(e,c)
    return c==e:GetLabelObject()
end