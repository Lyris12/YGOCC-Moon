--Mireya, Shield of the Divine Blade
function c88567307.initial_effect(c)
    --xyz summon
    aux.AddXyzProcedure(c,c88567307.matfilter,4,2,nil,nil,99)
    c:EnableReviveLimit()
    --remove
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(88567307,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_BATTLED)
    e1:SetCondition(c88567307.condition)
    e1:SetTarget(c88567307.target)
    e1:SetOperation(c88567307.operation)
    c:RegisterEffect(e1)
    --attack up
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(88567307,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(TIMING_BATTLE_PHASE)
    e2:SetCondition(c88567307.condition1)
    e2:SetCost(c88567307.cost)
    e2:SetTarget(c88567307.target1)
    e2:SetOperation(c88567307.operation1)
    c:RegisterEffect(e2)
end
function c88567307.matfilter(c)
    return c:IsSetCard(0x1bc2)
end
function c88567307.condition(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c88567307.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local bc=e:GetHandler():GetBattleTarget()
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
function c88567307.operation(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc:IsRelateToBattle() then
        Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
    end
end
function c88567307.condition1(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local at=Duel.GetAttackTarget()
    return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and at and ((a:IsControler(tp) and a:IsOnField() and a:IsSetCard(0x1bc2))
        or (at:IsControler(tp) and at:IsOnField() and at:IsFaceup() and at:IsSetCard(0x1bc2)))
end
function c88567307.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,88567307)==0 and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
    Duel.RegisterFlagEffect(tp,88567307,RESET_PHASE+PHASE_DAMAGE,0,1)
end
function c88567307.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetCard(Duel.GetAttacker())
    Duel.SetTargetCard(Duel.GetAttackTarget())
end
function c88567307.operation1(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local at=Duel.GetAttackTarget()
    if at:IsControler(tp) then a,at=at,a end
    if a:IsFacedown() or not a:IsRelateToEffect(e) or not at:IsRelateToEffect(e) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
    a:RegisterEffect(e1,true)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
    e2:SetValue(1)
    e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
    a:RegisterEffect(e2,true)
    if at:IsType(TYPE_EFFECT) then
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_DISABLE)
        e3:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
        at:RegisterEffect(e3)
        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_SINGLE)
        e4:SetCode(EFFECT_DISABLE_EFFECT)
        e4:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
        at:RegisterEffect(e4)
    end
end