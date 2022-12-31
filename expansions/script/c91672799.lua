--Amelia, Paladawn Virtue
function c91672799.initial_effect(c)
    c:SetSPSummonOnce(91672799)
    --link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xbb8),3)
	--cannot be tributed
	local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCode(EFFECT_UNRELEASABLE_SUM)
    e0:SetCondition(c91672799.immcon)
    e0:SetValue(1)
    c:RegisterEffect(e0)
    local e1=e0:Clone()
    e1:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e1)
	--negate
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(c91672799.discon)
    e2:SetTarget(c91672799.distg)
    e2:SetOperation(c91672799.disop)
    c:RegisterEffect(e2)
	--spsummon
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e3:SetCondition(c91672799.spcon)
    e3:SetTarget(c91672799.sptg)
    e3:SetOperation(c91672799.spop)
    c:RegisterEffect(e3)
end
function c91672799.immfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function c91672799.immcon(e)
    return e:GetHandler():GetLinkedGroup():IsExists(c91672799.immfilter,1,nil)
end
function c91672799.discon(e,tp,eg,ep,ev,re,r,rp)
    return re:GetHandler()~=e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
        and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function c91672799.disfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xbb8) and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
function c91672799.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c91672799.disfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function c91672799.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,c91672799.disfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 then
        if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
            Duel.Destroy(eg,REASON_EFFECT)
        end
    end
end
function c91672799.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_BATTLE)
        or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:GetPreviousControler()==tp)
end
function c91672799.spfilter(c,e,tp)
    return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xbb8)
        and Duel.IsExistingMatchingCard(c91672799.spfilter2,tp,LOCATION_DECK,0,2,nil,c:GetCode(),e,tp)
end
function c91672799.spfilter2(c,code,e,tp)
    return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c91672799.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c91672799.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function c91672799.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,c91672799.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if g:GetCount()==0 then return end
    local code=g:GetFirst():GetCode()
    local dg=Duel.GetMatchingGroup(c91672799.spfilter2,tp,LOCATION_DECK,0,nil,code,e,tp)
    if dg:GetCount()>1 then
        local c=e:GetHandler()
        local fid=c:GetFieldID()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg1=dg:Select(tp,1,1,nil)
        local tc1=sg1:GetFirst()
        local sg2=dg:Filter(Card.IsCode,tc1,tc1:GetCode())
        local tc2=sg2:GetFirst()
        Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
        Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
        Duel.SpecialSummonComplete()
    end
end