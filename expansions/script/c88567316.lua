--Dark Heart of the Divine Blade
function c88567316.initial_effect(c)
    --xyz summon
    aux.AddXyzProcedure(c,c88567316.mfilter,4,2,c88567316.ovfilter,aux.Stringid(88567316,0),99,c88567316.xyzop)
    c:EnableReviveLimit()
    --spsummon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(88567316,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(c88567316.spcost)
    e1:SetTarget(c88567316.sptg)
    e1:SetOperation(c88567316.spop)
    c:RegisterEffect(e1)
    --cannot target
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    --indes
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(aux.indoval)
    c:RegisterEffect(e3)
end
function c88567316.mfilter(c)
    return c:IsRace(RACE_WARRIOR)
end
function c88567316.cfilter(c)
    return c:IsType(TYPE_MONSTER)
end
function c88567316.ovfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1bc2)
end
function c88567316.xyzop(e,tp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c88567316.cfilter,tp,LOCATION_HAND,0,1,nil)
    and Duel.GetFlagEffect(tp,88567316)==0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,c88567316.cfilter,tp,LOCATION_HAND,0,1,1,nil)
    if g:GetCount()>=0 then
        Duel.Overlay(e:GetHandler(),g)
        Duel.RegisterFlagEffect(tp,88567316,RESET_PHASE+PHASE_END,0,1)
    end
end
function c88567316.spfilter(c,e,tp,mc)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(0x1bc2) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function c88567316.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c88567316.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,e:GetHandler())>0
        and Duel.IsExistingMatchingCard(c88567316.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c88567316.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCountFromEx(tp,tp,c)>0 then
        if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,c88567316.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
            local sc=g:GetFirst()
            if sc then
                local mg=c:GetOverlayGroup()
                if mg:GetCount()~=0 then
                    Duel.Overlay(sc,mg)
                end
                sc:SetMaterial(Group.FromCards(c))
                Duel.Overlay(sc,Group.FromCards(c))
                Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
                sc:CompleteProcedure()
            end
        end
    end
end