--Shisune Honden
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
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(cid.activate)
    c:RegisterEffect(e1)
    --Mill and shuffle
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1, id+100)
	e2:SetCondition(cid.discon)
	e2:SetTarget(cid.distg)
	e2:SetOperation(cid.disop)
    c:RegisterEffect(e2)
    --Shuffle and add back to hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id+200)
	e3:SetTarget(cid.tdtg)
	e3:SetOperation(cid.tdop)
    c:RegisterEffect(e3)
end

--Activate

function cid.thfilter(c)
	return c:IsSetCard(0x570) and c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToHand()
end
function cid.tgfilter(c)
    return c:IsSetCard(0x570) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function cid.activate(e, tp, eg, ep, ev, re, r, rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(cid.thfilter, tp, LOCATION_DECK, 0, nil)
    if g:GetCount()==0 then return end
    if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) and Duel.DiscardHand(tp, aux.TRUE, 1, 1, REASON_COST+REASON_DISCARD)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp, 1, 1, nil)
        if Duel.SendtoHand(sg, nil, REASON_EFFECT)~=0 and sg:GetFirst():IsLocation(LOCATION_HAND) then
            Duel.ConfirmCards(1-tp, sg)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local tg=Duel.SelectMatchingCard(tp, cid.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
            if tg:GetCount()>0 then
                Duel.BreakEffect()
                Duel.SendtoGrave(tg, REASON_EFFECT)
            end
        end
	end
end

--Mill and shuffle

function cid.cfilter(c, tp)
    return c:IsSetCard(0x570) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_GRAVE)
end
function cid.discon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(cid.cfilter, 1, nil, tp)
end
function cid.distg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp, 2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, 2)
end
function cid.disfilter(c)
	return c:IsSetCard(0x570) and c:IsLocation(LOCATION_GRAVE)
end
function cid.disop(e, tp, eg, ep, ev, re, r, rp)
	local p,d=Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
	Duel.DiscardDeck(p, d, REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(cid.disfilter, nil)
	if ct>0 then
        local sg=Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, 0, LOCATION_ONFIELD, nil)
        if sg:GetCount()>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local tg=sg:Select(tp, 1, 1, nil)
            Duel.HintSelection(tg)
            Duel.SendtoDeck(tg, nil, 2, REASON_EFFECT)
        end
	end
end

--Shuffle then add back to hand

function cid.tdfilter(c)
    return c:IsSetCard(0x570) and c:IsAbleToDeck()
end
function cid.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter, tp, LOCATION_GRAVE, 0, 1, e:GetHandler())
        and e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, tp, LOCATION_GRAVE)
end
function cid.tdop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, tdfilter, tp, LOCATION_GRAVE, 0, 1, 1, e:GetHandler())
    if g:GetCount()==0 then return end
    if Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        if g:GetFirst():IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
        Duel.SendtoHand(e:GetHandler(), nil, REASON_EFFECT)
    end
end
