--Shisune Miko
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    --Can be used as the entire requirement
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetValue(cid.rlevel)
    c:RegisterEffect(e1)
    --Special Summon on ritual summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(cid.spcon)
    e2:SetTarget(cid.sptg)
    e2:SetOperation(cid.spop)
    c:RegisterEffect(e2)
    --Shuffle a card from opponent's GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_DECK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id+100)
    e3:SetCondition(cid.drcon)
    e3:SetTarget(cid.drtg)
    e3:SetOperation(cid.drop)
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

--Special Summon on ritual summon

function cid.filter(c)
    return c:IsSetCard(0x570) and c:GetSummonType()==SUMMON_TYPE_RITUAL
end
function cid.spcon(e, tp, eg, ep, ev, re, r, rp)
    return rp==tp and eg:IsExists(cid.filter, 1, nil, tp)
end
function cid.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function cid.spop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

--Shuffle a card from opponent's GY

function cid.cfilter(c, tp)
    return c:IsSetCard(0x570) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_GRAVE)
end
function cid.drcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(cid.cfilter, 1, nil, tp)
end
function cid.drtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck, tp, 0, LOCATION_GRAVE, 1, nil)
        and Duel.IsPlayerCanDraw(tp, 1) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp, Card.IsAbleToDeck, tp, 0, LOCATION_GRAVE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, 1-tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 1, tp, 1)
end
function cid.drop(e, tp, eg, ep, ev, re, r, rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc, 1-tp, 2, REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tc:GetControler()) end
		Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end