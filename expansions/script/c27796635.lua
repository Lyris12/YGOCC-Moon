--Abysslym Malice
--Script by TaxingCorn117
function c27796635.initial_effect(c)
   --spsummon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(27796635,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1,27796635+EFFECT_COUNT_CODE_DUEL)
    e1:SetCondition(c27796635.spcon)
    e1:SetTarget(c27796635.sptg)
    e1:SetOperation(c27796635.spop)
    c:RegisterEffect(e1) 
    --return to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(27796635,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_REMOVE)
    e2:SetCountLimit(1,27796645+EFFECT_COUNT_CODE_DUEL)
    e2:SetCondition(c27796635.retcon)
    e2:SetTarget(c27796635.rettg)
    e2:SetOperation(c27796635.retop)
    c:RegisterEffect(e2)
end
function c27796635.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x49c)
end
function c27796635.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(c27796635.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c27796635.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c27796635.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end

function c27796635.retcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
        and re:GetHandler():IsSetCard(0x49c)
end
function c27796635.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c27796635.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end