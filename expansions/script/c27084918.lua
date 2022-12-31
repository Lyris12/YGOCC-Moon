--EX-Exostorm Divine Blade
function c27084918.initial_effect(c)
    --xyz summon
    aux.AddXyzProcedure(c,nil,7,3,c27084918.ovfilter,aux.Stringid(27084918,1),3,c27084918.xyzop)
    c:EnableReviveLimit()
    --atkup
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,27084918)
    e1:SetCondition(c27084918.atkcon)
    e1:SetCost(c27084918.atkcost)
    e1:SetTarget(c27084918.atktg)
    e1:SetOperation(c27084918.atkop)
    c:RegisterEffect(e1)
end
function c27084918.ovfilter(c)
    return c:IsFaceup() and c:IsCode(27084917)
end
function c27084918.xyzop(e,tp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,27084918)==0 end
    Duel.RegisterFlagEffect(tp,27084918,RESET_PHASE+PHASE_END,0,1)
end
function c27084918.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()==PHASE_MAIN1
end
function c27084918.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c27084918.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xc1c) and not c:IsCode(27084918)
end
function c27084918.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c27084918.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetProperty(EFFECT_FLAG_OATH)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(c27084918.ftarget)
    e1:SetLabel(e:GetHandler():GetFieldID())
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function c27084918.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetHandler()
    if tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local g=Duel.GetMatchingGroup(c27084918.atkfilter,tp,LOCATION_MZONE,0,nil)
        local atk=g:GetSum(Card.GetAttack)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
        e1:SetValue(math.ceil(atk/2))
        tc:RegisterEffect(e1)
    end
end
function c27084918.ftarget(e,c)
    return e:GetLabel()~=c:GetFieldID()
end