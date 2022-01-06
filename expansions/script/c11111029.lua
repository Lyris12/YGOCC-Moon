--Golden Skies Treasure of Welfare
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    --Special Summon a "Golden Skies" from GY if sent to GY by a "Golden Skies" card effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(cid.spcon)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
    c:RegisterEffect(e1)
end

--Special Summon a "Golden Skies" from GY if sent to GY by a "Golden Skies" card effect

function cid.spcon(e, tp, eg, ep, ev, re, r, rp)
	return re:GetHandler():IsSetCard(0x528) and bit.band(r, REASON_EFFECT)~=0
end
function cid.spfilter(c, e, tp)
    return c:IsSetCard(0x528) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function cid.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) 
        and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end
function cid.spop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp, cid.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1, true)
    end
    Duel.SpecialSummonComplete()
end