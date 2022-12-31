--Maiden of the Shisune, Ahri
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    c:EnableReviveLimit()
	--Must be Ritual Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
    c:RegisterEffect(e1)
    --Shuffle and send to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetCondition(cid.tgcon)
    e2:SetTarget(cid.tgtg)
    e2:SetOperation(cid.tgop)
    c:RegisterEffect(e2)
    --Negate a destroying effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
    e3:SetCountLimit(1, id+100)
	e3:SetCondition(cid.negcon)
	e3:SetCost(cid.negcost)
	e3:SetTarget(cid.negtg)
	e3:SetOperation(cid.negop)
	c:RegisterEffect(e3)
end

--Ritual Summon without using a card with the same name

function cid.mat_filter(c)
	return not c:IsCode(id)
end

--Shuffle and send to GY

function cid.tgcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function cid.tdfilter(c)
	return c:IsSetCard(0x570) and c:IsAbleToDeck()
end
function cid.fselect(g)
	return g:GetClassCount(Card.GetCode)==g:GetCount()
end
function cid.tgfilter(c)
	return c:IsSetCard(0x570) and c:IsAbleToGrave()
end
function cid.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
	local g=Duel.GetMatchingGroup(cid.tgfilter, tp, LOCATION_DECK, 0, nil)
    if chk==0 then return g:CheckSubGroup(cid.fselect, 1, 3)
        and Duel.IsExistingMatchingCard(cid.tdfilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, 2, e:GetHandler()) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 2, tp, LOCATION_ONFIELD+LOCATION_GRAVE)
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, 3, 0, 0)
end
function cid.tgop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, cid.tdfilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, 2, 2, e:GetHandler())
    if g:GetCount()==0 then return end
	if Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		if g:GetFirst():IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
        local sg=Duel.GetMatchingGroup(cid.tgfilter, tp, LOCATION_DECK, 0, nil)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
        local tg=sg:SelectSubGroup(tp,cid.fselect, false, 1, 3)
        Duel.SendtoGrave(tg, REASON_EFFECT)
    end
end

--Negate a destroying effect

function cid.filter(c, p)
	return c:GetControler()==p and c:IsSetCard(0x570) and c:IsOnField()
end
function cid.negcon(e, tp, eg, ep, ev, re, r, rp)
	if not Duel.IsChainNegatable(ev) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev, CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(cid.filter,nil,tp)-tg:GetCount()>0
end
function cid.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(), nil, 2, REASON_EFFECT)
end
function cid.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
	end
end
function cid.negop(e, tp, eg, ep, ev, re, r, rp)
	local tc=re:GetHandler()
	if not tc:IsDisabled() then
        if Duel.NegateEffect(ev) and tc:IsRelateToEffect(re) then
            Duel.Destroy(eg, REASON_EFFECT)
        end
    end
end