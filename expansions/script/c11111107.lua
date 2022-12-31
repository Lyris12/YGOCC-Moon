--Crisis Claw - Deceit
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    --Search a "Crisis Claw" equip spell
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetTarget(cid.thtg)
    e1:SetOperation(cid.thop)
    c:RegisterEffect(e1)
    --Set 1 "Crisis Claw" equip spell from GY
    local e2=Effect.CreateEffect(c)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1, id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.settg)
	e2:SetOperation(cid.setop)
	c:RegisterEffect(e2)
end
--Search a "Crisis Claw" equip spell
function cid.thfilter(c)
    return c:IsSetCard(0x571) and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function cid.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter, tp, LOCATION_DECK, 0, 2, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function cid.thop(e, tp, eg, ep, ev, re, r, rp)
    local g=Duel.GetMatchingGroup(cid.thfilter, tp, LOCATION_DECK, 0, nil)
	if g:GetCount()>=2 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local sg=g:Select(tp, 2, 2, nil)
		Duel.ConfirmCards(1-tp, sg)
		Duel.Hint(HINT_SELECTMSG, 1-tp, HINTMSG_ATOHAND)
		local tg=sg:Select(1-tp, 1, 1, nil)
		Duel.SendtoHand(tg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, tg)
        sg:RemoveCard(tg)
        Duel.SendtoGrave(sg, REASON_EFFECT)
    end
end
--Set 1 "Crisis Claw" equip spell from GY
function cid.setfilter(c)
	return c:IsSetCard(0x571) and c:IsType(TYPE_EQUIP) and c:IsSSetable()
end
function cid.settg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and cid.setfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(cid.setfilter, tp, LOCATION_GRAVE, 0, 1, nil)
        and Duel.GetLocationCount(tp, LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
	local g=Duel.SelectTarget(tp, cid.setfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, 1, 0, 0)
end
function cid.setop(e, tp, eg, ep, ev, re, r, rp)
    local tc=Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp, LOCATION_SZONE)<=0 then return end
	if tc and tc:IsRelateToEffect(e) and tc:IsSSetable() then
		Duel.SSet(tp, tc)
	end
end