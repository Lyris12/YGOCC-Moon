--Divine Blade - Darius
function c88567301.initial_effect(c)
    --remove
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(88567301,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_BATTLED)
    e1:SetCondition(c88567301.condition)
    e1:SetTarget(c88567301.target)
    e1:SetOperation(c88567301.operation)
    c:RegisterEffect(e1)
    --material
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(88567301,1))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetTarget(c88567301.mattg)
    e1:SetOperation(c88567301.matop)
    c:RegisterEffect(e1)
    --Gain ATK
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(88567301,2))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(c88567301.atkcon)
    e3:SetTarget(c88567301.atktg)
    e3:SetOperation(c88567301.atkop)
    c:RegisterEffect(e3)
end
function c88567301.condition(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c88567301.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local bc=e:GetHandler():GetBattleTarget()
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
function c88567301.operation(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc:IsRelateToBattle() then
        Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
    end
end
function c88567301.matfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1bc2) and c:IsType(TYPE_XYZ)
end
function c88567301.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c88567301.matfilter(chkc) end
    if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
        and Duel.IsExistingTarget(c88567301.matfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,c88567301.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c88567301.matop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
        Duel.Overlay(tc,Group.FromCards(c))
    end
end
function c88567301.atkcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return c:IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
  and c:IsPreviousLocation(LOCATION_OVERLAY) and re:GetHandler():IsSetCard(0x1bc2)
end
function c88567301.atkfilter(c)
  return c:IsFaceup() and c:IsSetCard(0x1bc2) and c:IsType(TYPE_XYZ) and c:IsType(TYPE_MONSTER)
end
function c88567301.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(c88567301.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
  Duel.SelectTarget(tp,c88567301.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c88567301.atkop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsFaceup() and tc:IsRelateToEffect(e) then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(700)
    e1:SetReset(RESET_EVENT+0x1fe0000)
    tc:RegisterEffect(e1)
  end
end