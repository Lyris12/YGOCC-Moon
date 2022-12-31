--Abyssal Frostshard
function c888799.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,888799)
    e1:SetTarget(c888799.target)
    e1:SetOperation(c888799.activate)
    c:RegisterEffect(e1)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetTargetRange(LOCATION_SZONE,0)
    e3:SetCondition(c888799.cond)
    e3:SetTarget(c888799.etarget)
    e3:SetValue(c888799.efilter)
    c:RegisterEffect(e3)
end

function c888799.filter(c)
    return c:IsCode(88810101) and c:IsAbleToGrave()
end
function c888799.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xffc)
end
function c888799.cond(e,c)
    if c==nil then return true end
    return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c888799.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function c888799.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c888799.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c888799.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c888799.filter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

function c888799.operation(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetOperation(c888799.spop)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function c888799.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function c888799.etarget(e,c)
    return c:IsSetCard(0xffc)
end