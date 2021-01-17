--Lord of the Shisune, Inari Okami
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
    c:EnableReviveLimit()
	--Must be Ritual Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
    c:RegisterEffect(e1)
    --Disable a monster's effect and shuffle
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DISABLE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(cid.distg)
    e2:SetOperation(cid.disop)
    c:RegisterEffect(e2)
    --Shuffle 2 cards from field
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_DECK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(cid.tdcon)
    e3:SetTarget(cid.tdtg)
    e3:SetOperation(cid.tdop)
    c:RegisterEffect(e3)
    --Search a Shisune monster
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1, id+100)
	e4:SetCost(cid.thcost2)
	e4:SetTarget(cid.thtg2)
	e4:SetOperation(cid.thop2)
	c:RegisterEffect(e4)
end

--Ritual Summon without using a card with the same name

function cid.mat_filter(c)
	return not c:IsCode(id)
end

--Disable a monster's effect and shuffle

function cid.tdfilter(c)
    return c:IsSetCard(0x570) and c:IsAbleToDeck()
end
function cid.distg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) and chkc:GetControler()~=tp end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil)
        and Duel.IsExistingMatchingCard(cid.tdfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
end
function cid.disop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, cid.tdfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if g:GetCount()>0 and Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)~=0 then
        Duel.ShuffleDeck(tp)
        local tc=Duel.GetFirstTarget()
        if tc:IsFaceup() and tc:IsRelateToEffect(e) then
            Duel.NegateRelatedChain(tc, RESET_TURN_SET)
            --negate effects
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
            --shuffle into deck
            Duel.BreakEffect()
            Duel.SendtoDeck(tc, nil, 2, REASON_EFFECT)
        end
    end
end

--Shuffle 2 cards from field

function cid.cfilter(c, tp)
    return c:IsSetCard(0x570) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_GRAVE)
end
function cid.tdcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(cid.cfilter, 1, nil, tp)
end
function cid.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_ONFIELD, 0, 1, e:GetHandler())
        and Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, 0, LOCATION_ONFIELD, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, 0, 0)
end
function cid.tdop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_ONFIELD, 0, 1, 1, e:GetHandler())
    if g:GetCount()==0 then return end
    if Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        Duel.ShuffleDeck(tp)
        local sg=Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, 0, LOCATION_ONFIELD, nil)
        if sg:GetCount()>0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
            local tg=sg:Select(tp, 1, 1, nil)
            Duel.HintSelection(tg)
            Duel.SendtoDeck(tg, nil, 2, REASON_EFFECT)
        end
    end
end

--Search a Shisune monster

function cid.thcost2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(), REASON_COST+REASON_DISCARD)
end
function cid.thfilter2(c)
	return c:IsSetCard(0x570) and not c:IsCode(id) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cid.thtg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter2, tp,LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function cid.thop2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp, cid.thfilter2, tp, LOCATION_DECK, 0, 1, 1, nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end