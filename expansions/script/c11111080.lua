--Sessho-Seki, The Shisune's Sorrow
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_NEGATE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(cid.condition)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
    c:RegisterEffect(e1)
    --Special Summon a ritual monster from deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cid.spcon)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
end

--Activate

function cid.filter(c, tp)
	return c:IsControler(tp) and c:IsSetCard(0x570) and c:IsFaceup() and c:IsOnField()
end
function cid.condition(e, tp, eg, ep, ev, re, r, rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(cid.filter, 1, nil, tp)
		and Duel.IsChainNegatable(ev)
end
function cid.tdfilter(c)
    return c:IsSetCard(0x570) and c:IsAbleToDeck()
end
function cid.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_ONFIELD+LOCATION_GRAVE)
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
	if re:GetHandler():IsAbleToGrave() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, eg, 1, 0, 0)
	end
end
function cid.activate(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINTMSG_SELECT, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, cid.tdfilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, 1, nil)
    if g:GetCount()==0 then return end
    if Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        if g:GetFirst():IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
        local sg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):Filter(cid.filter, nil, tp)
        if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
            Duel.SendtoGrave(eg, REASON_EFFECT)
        end
    end
end

--Special Summon a ritual monster from deck

function cid.spcon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:GetPreviousControler()==tp
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function cid.spfilter(c, e, tp)
	return (c:IsCode(11111081) or c:IsCode(11111082)) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, false, true)
end
function cid.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(cid.tdfilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, e:GetHandler(), e, tp)
        and Duel.IsExistingMatchingCard(cid.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_ONFIELD+LOCATION_GRAVE)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end
function cid.spop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, cid.tdfilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, 1, e:GetHandler())
    if g:GetCount()==0 then return end
    if Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        if g:GetFirst():IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
        if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp, cid.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
        local tc=sg:GetFirst()
        if tc then
            tc:SetMaterial(nil)
            Duel.SpecialSummon(tc, SUMMON_TYPE_RITUAL, tp, tp, false, true, POS_FACEUP)
            tc:CompleteProcedure()
        end
	end
end
