--Golden Skise Armatus - Gargantua Mech Suit
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion materials
    aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x528),cid.mfilter,true)
    --Send a "Golden Skies Treasure" to GY when Fusion Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(cid.tgcon)
    e1:SetTarget(cid.tgtg)
    e1:SetOperation(cid.tgop)
    c:RegisterEffect(e1)
    --Shuffle a "Golden Skies Treasure" to deck to negate a card or effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_NEGATE)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, id+100)
	e2:SetCondition(cid.negcon)
	e2:SetTarget(cid.negtg)
	e2:SetOperation(cid.negop)
	c:RegisterEffect(e2)
end

--Fusion Materials filter

function cid.mfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsLevelAbove(5) or c:IsRankAbove(5))
end

--Send a "Golden Skies Treasure" to GY when Fusion Summoned

function cid.tgcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
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

--Shuffle a "Golden Skies Treasure" to deck to negate a card or effect

function cid.negcon(e, tp, eg, ep, ev, re, r, rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function cid.tdfilter(c)
	return c:IsCode(11111040) and c:IsAbleToDeck()
end
function cid.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_GRAVE)
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0, CATEGORY_TODECK, eg, 1, 0, 0)
	end
end
function cid.negop(e, tp, eg, ep, ev, re, r, rp)
    local ec=re:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, cid.tdfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if g:GetCount()==0 then return end
    if Duel.SendtoDeck(g, tp, 2, REASON_EFFECT)~=0 and Duel.ShuffleDeck(tp)~=0 and Duel.NegateActivation(ev)~=0 and re:GetHandler():IsRelateToEffect(re) then
        ec:CancelToGrave()
        Duel.SendtoDeck(ec, nil, 2, REASON_EFFECT)
	end
end