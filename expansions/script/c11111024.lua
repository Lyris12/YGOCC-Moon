--Golden Skies - Garnier the Lost Hero
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    --Special Summon from hand if "Golden Skies Treasure" is in GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCondition(cid.spcon)
    e1:SetTarget(cid.sptg)
    e1:SetOperation(cid.spop)
    c:RegisterEffect(e1)
    --Shuffle "Golden Skies Treasure" into deck and Search a "Golden Skies" spell
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id+100)
    e2:SetTarget(cid.tgtg)
    e2:SetOperation(cid.tgop)
    c:RegisterEffect(e2)
end

--Special Summon from hand if "Golden Skies Treasure" is in GY

function cid.spfilter(c)
    return c:IsCode(CARD_GOLDEN_SKIES_TREASURE)
end
function cid.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(cid.spfilter, tp, LOCATION_GRAVE, 0, 1, nil)
end
function cid.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
        and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function cid.spop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE)<0 then return end
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)~=0 then
        --Special Summon Limit
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1, 0)
        e1:SetTarget(cid.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end
function cid.splimit(e, c)
    return not c:IsRace(RACE_WARRIOR)
end

--Shuffle "Golden Skies Treasure" into deck and Search a "Golden Skies" spell

function cid.tdfilter(c)
    return c:IsCode(CARD_GOLDEN_SKIES_TREASURE) and c:IsAbleToDeck()
end
function cid.tgfilter(c)
    return c:IsCode(CARD_GOLDEN_SKIES_TREASURE) and c:IsAbleToGrave()
end
function cid.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil)
        and Duel.IsExistingMatchingCard(cid.tgfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND+LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function cid.tgop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g1=Duel.SelectMatchingCard(tp, cid.tdfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, 1, nil)
    if g1:GetCount()==0 then return end
    if Duel.SendtoDeck(g1, tp, 2, REASON_EFFECT)~=0 and Duel.ShuffleDeck(tp)~=0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
        local g2=Duel.SelectMatchingCard(tp, cid.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
        if g2:GetCount()>0 then
            Duel.SendtoGrave(g2, REASON_EFFECT)
        end
    end
end