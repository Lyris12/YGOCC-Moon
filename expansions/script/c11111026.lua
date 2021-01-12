--Golden Skies - Erith the Grand Usurper
--Scripted by Yuno
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
    --Shuffle to "Golden Skies Treasure" to deck and Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetTarget(cid.sptg)
    e1:SetOperation(cid.spop)
    c:RegisterEffect(e1)
    --Send "Golden Skies Treasure" from deck to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1, id+100)
    e2:SetCondition(cid.tgcon)
    e2:SetTarget(cid.tgtg)
    e2:SetOperation(cid.tgop)
    c:RegisterEffect(e2)
end

--Shuffle to "Golden Skies Treasure" to deck and Special Summon

function cid.tdfilter(c, tp, mc)
	local g=Group.FromCards(c)
	if mc then g:AddCard(mc) end
	return c:IsCode(11111040) and c:IsAbleToDeck() and Duel.GetMZoneCount(tp, g)>0
end
function cid.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil) 
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
	Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function cid.spop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, cid.tdfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, 1, nil, tp)
    if g:GetCount()>0 and Duel.SendtoDeck(g, tp, 2, REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_DECK) and Duel.ShuffleDeck(tp)~=0
    and c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c, 0, tp, tp, false, false, POS_FACEUP)~=0 then
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
    Duel.SpecialSummonComplete()
end
function cid.splimit(e, c)
    return not c:IsRace(RACE_WARRIOR)
end

--Send "Golden Skies Treasure" from deck to GY

function cid.tgcon(e, tp, eg, ep, ev, re, r, rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
function cid.tgfilter(c)
	return c:IsCode(11111040) and c:IsAbleToGrave()
end
function cid.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.tgfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end
function cid.tgop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, cid.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if g:GetCount()>0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end