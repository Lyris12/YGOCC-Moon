--Shisune Omnyoji
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
    --Can be used as the entire requirement
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetValue(cid.rlevel)
    c:RegisterEffect(e1)
    --Shuffle and special summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_RELEASE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(cid.spcon)
    e2:SetTarget(cid.sptg)
    e2:SetOperation(cid.spop)
    c:RegisterEffect(e2)
    --Search a Shisune card
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_DECK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id+100)
    e3:SetCondition(cid.thcon)
    e3:SetTarget(cid.thtg)
    e3:SetOperation(cid.thop)
    c:RegisterEffect(e3)
end

--Can be used as the entire requirement

function cid.rlevel(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsRace(RACE_DIVINE) then
		local clv=c:GetLevel()
		return lv*65536+clv
	else return lv end
end

--Shuffle and special summon

function cid.spcon(e, tp, eg, ep, ev, re, r, rp)
    return bit.band(r, REASON_EFFECT)~=0
end
function cid.tdfilter(c)
    return c:IsSetCard(0x570) and c:IsAbleToDeck()
end
function cid.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter, tp, LOCATION_GRAVE, 0, 1, e:GetHandler())
        and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function cid.spop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, cid.tdfilter, tp, LOCATION_GRAVE, 0, 1, 1, e:GetHandler())
    if g:GetCount()==0 then return end
    if Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        if g:GetFirst():IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
        if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end

--Search a Shisune card

function cid.cfilter(c, tp)
    return c:IsSetCard(0x570) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_GRAVE)
end
function cid.cfilter2(c)
    return c:IsSetCard(0x570) and c:IsType(TYPE_RITUAL)
end
function cid.thcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(cid.cfilter, 1, nil, tp) and Duel.IsExistingMatchingCard(cid.cfilter2, tp, LOCATION_MZONE, 0, 1, nil)
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