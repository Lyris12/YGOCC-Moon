--Shisune No Yomeiri
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    --You can only control 1 "Shisune No Yomeiri"
    c:SetUniqueOnField(1, 0, id)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
    --Special Summon a Shisune from hand or GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCost(cid.spcost)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
    c:RegisterEffect(e2)
    --Send a Shisune from deck to GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(cid.tgcon)
	e3:SetTarget(cid.tgtg)
	e3:SetOperation(cid.tgop)
    c:RegisterEffect(e3)
    --Search a Shisune card
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_DECK)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1, id+100)
    e4:SetCondition(cid.thcon)
    e4:SetTarget(cid.thtg)
    e4:SetOperation(cid.thop)
    c:RegisterEffect(e4)
end

--Special Summon a Shisune from hand or GY

function cid.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
	Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST+REASON_DISCARD)
end
function cid.spfilter(c, e, tp)
	return c:IsSetCard(0x570) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function cid.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(cid.spfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil, e, tp) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_GRAVE)
end
function cid.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp, cid.spfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
	end
end

--Send a Shisune from deck to GY

function cid.filter(c)
    return c:IsSetCard(0x570) and c:GetSummonType()==SUMMON_TYPE_RITUAL
end
function cid.tgcon(e, tp, eg, ep, ev, re, r, rp)
    return rp==tp and eg:IsExists(cid.filter, 1, nil, tp)
end
function cid.tgfilter(c)
	return c:IsSetCard(0x570) and c:IsAbleToGrave()
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

--Search a Shisune card

function cid.cfilter(c, tp)
    return c:IsSetCard(0x570) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_GRAVE)
end
function cid.thcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(cid.cfilter, 1, nil, tp)
end
function cid.thfilter(c)
    return c:IsSetCard(0x570) and c:IsAbleToHand()
end
function cid.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function cid.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp, cid.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g, tp, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end
