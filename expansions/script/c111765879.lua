--Variamorivarias
function c111765879.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(111765879,1))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,111765979)
    e1:SetCondition(c111765879.condition)
    e1:SetOperation(c111765879.activate)
    c:RegisterEffect(e1)
    --set
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(111765879,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,111765879)
    e2:SetCondition(c111765879.setcon)
    e2:SetCost(c111765879.cost)
    e2:SetTarget(c111765879.settg)
    e2:SetOperation(c111765879.setop)
    c:RegisterEffect(e2)
end
--end battle phase
function c111765879.cfilter(c,tp)
    return c:IsSetCard(0x736) and c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function c111765879.condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c111765879.cfilter,1,nil,tp)
        and Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
function c111765879.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
--set
function c111765879.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c111765879.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c111765879.setfilter(c)
    return c:IsSetCard(0x736) and not c:IsCode(111765879) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function c111765879.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(c111765879.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c111765879.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,c111765879.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SSet(tp,g:GetFirst())
        Duel.ConfirmCards(1-tp,g)
    end
end