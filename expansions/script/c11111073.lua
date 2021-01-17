--Shisune Yakusha
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
    --Activation Limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_RELEASE)
	e1:SetOperation(cid.operation)
    c:RegisterEffect(e1)
    --Send a monster from deck to GY and search a Shisune card then draw
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(cid.tgtg)
    e2:SetOperation(cid.tgop)
    c:RegisterEffect(e2)
end

--Activation Limit

function cid.operation(e, tp, eg, ep, ev, re, r, rp)
    --Opponent can't chain to Shisune Ritual Spells
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAINING)
    e1:SetOperation(cid.actop)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1, tp)
    --Opponent can't chain to Shisune Ritual Summons
    local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(cid.sumcon)
	e2:SetOperation(cid.sumsuc)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2, tp)
end
function cid.actop(e, tp, eg, ep, ev, re, r, rp)
	local rc=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsSetCard(0x570) and re:IsActiveType(TYPE_RITUAL) then
		Duel.SetChainLimit(cid.actlimit)
	end
end
function cid.actlimit(e, rp, tp)
	return tp==rp
end
function cid.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x570) and c:GetSummonType()==SUMMON_TYPE_RITUAL
end
function cid.sumcon(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(cid.filter, 1, nil)
end
function cid.sumsuc(e, tp, eg, ep, ev, re, r, rp)
	Duel.SetChainLimitTillChainEnd(cid.efun)
end
function cid.efun(e, ep, tp)
	return ep==tp
end

--Send a monster from deck to GY and search a Shisune card then draw a card

function cid.chkcfilter(c, tp)
    return c:IsSetCard(0x570) and c:IsType(TYPE_MONSTER) 
        and Duel.IsExistingMatchingCard(cid.tgfilter, tp, LOCATION_DECK+LOCATION_EXTRA, 0, 1, nil, c:GetLevel())
end
function cid.tgfilter(c, lv)
    return c:IsType(TYPE_MONSTER) and c:IsLevel(lv) and c:IsAbleToGrave()
end
function cid.thfilter(c)
    return c:IsSetCard(0x570) and c:IsAbleToHand()
end
function cid.tgtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cid.chkcfilter(chkc, tp) end
    if chk==0 then return Duel.IsExistingTarget(cid.chkcfilter, tp, LOCATION_MZONE, 0, 1, nil, tp)
        and Duel.IsExistingMatchingCard(cid.thfilter, tp, LOCATION_DECK, 0, 1, nil)
        and e:GetHandler():IsAbleToDeck() end
    Duel.Hint(HINTMSG_SELECT, tp, HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp, cid.chkcfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK+LOCATION_EXTRA)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
end
function cid.tgop(e, tp, eg, ep, ev, re, r, rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local lv=tc:GetLevel()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp, cid.tgfilter, tp, LOCATION_DECK+LOCATION_EXTRA, 0, 1, 1, nil, lv)
        if g:GetCount()==0 then return end
        if Duel.SendtoGrave(g, REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
            local sg=Duel.GetMatchingGroup(cid.thfilter, tp, LOCATION_DECK, 0, nil)
            if sg:GetCount()==0 then return end
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            local tg=sg:Select(tp, 1, 1, nil)
            if Duel.SendtoHand(tg, nil, REASON_EFFECT)~=0 and tg:GetFirst():IsLocation(LOCATION_HAND) then
                Duel.ConfirmCards(1-tp, tg)
                Duel.BreakEffect()
                Duel.SendtoDeck(e:GetHandler(), nil, 2, REASON_EFFECT)
            end
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetTargetRange(1, 0)
            e1:SetTarget(cid.splimit)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1, tp)
        end
    end
end
function cid.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    return not c:IsSetCard(0x570) and c:IsLocation(LOCATION_EXTRA)
end