--The Inner Shisune
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
	local e1=aux.AddRitualProcEqual2(c, cid.filter, LOCATION_HAND+LOCATION_GRAVE)
	--Search a Shisune
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(cid.thcon)
	e2:SetCost(cid.thcost)
	e2:SetTarget(cid.thtg)
	e2:SetOperation(cid.thop)
	c:RegisterEffect(e2)
end

--Search a Shisune

function cid.thcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0)==0
end
function cid.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(), nil, 2, REASON_EFFECT)
end
function cid.tdfilter(c)
    return c:IsSetCard(0x570) and c:IsAbleToDeck()
end
function cid.fselectfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL) and c:IsAbleToDeck()
end
function cid.fselect(g)
	return g:IsExists(cid.fselectfilter, 1, nil)
end
function cid.thfilter(c)
    return c:IsSetCard(0x570) and c:IsAbleToHand()
end
function cid.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g=Duel.GetMatchingGroup(cid.tdfilter, tp, LOCATION_GRAVE, 0, e:GetHandler())
    if chk==0 then return g:CheckSubGroup(cid.fselect, 2, 2)
        and Duel.IsExistingMatchingCard(cid.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 2, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function cid.thop(e, tp, eg, ep, ev, re, r, rp)
    local g=Duel.GetMatchingGroup(cid.tdfilter, tp, LOCATION_GRAVE, 0, e:GetHandler())
    if g:GetCount()==0 then return end
    local rg=g:SelectSubGroup(tp,cid.fselect, false, 2, 2)
    if Duel.SendtoDeck(rg, nil, 2, REASON_EFFECT)~=0 and rg:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        if rg:GetFirst():IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local sg=Duel.SelectMatchingCard(tp, cid.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
        if sg:GetCount()>0 then
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1-tp, sg)
        end
    end
end