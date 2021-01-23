--Crisis Claw - Madness Revealed
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
    --Search
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
    e1:SetOperation(cid.activate)
    c:RegisterEffect(e1)
    --Destroy cards
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
    e2:SetTarget(cid.destg)
    e2:SetOperation(cid.desop)
    c:RegisterEffect(e2)
end
--Search
function cid.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, e:GetHandler()) end
	Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST+REASON_DISCARD, nil)
end
function cid.filter(c)
    return c:IsSetCard(0x571) and not c:IsCode(id) and c:IsAbleToHand()
end
function cid.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.filter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function cid.activate(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp, cid.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g, tp, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end
--Destroy cards
function cid.desfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x571)
end
function cid.desfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cid.ffilter(c, tp)
	return c:IsPreviousSetCard(0x571) and c:GetPreviousControler()==tp and c:GetPreviousTypeOnField()&TYPE_MONSTER~=0
		and c:IsPreviousPosition(POS_FACEUP)
end
function cid.destg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chkc then return false end
	local b1=(Duel.IsExistingTarget(cid.desfilter1, tp, LOCATION_ONFIELD, 0, 1, e:GetHandler()
	          and
			  Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil)))
			  
	local b2=(Duel.IsExistingTarget(cid.desfilter1, tp, LOCATION_ONFIELD, 0, 1, e:GetHandler()
	          and
			  Duel.IsExistingTarget(cid.desfilter2, tp, 0, LOCATION_ONFIELD, 1, nil)))
			  
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp, aux.Stringid(id, 2),aux.Stringid(id, 3))
	elseif b1 then
		op=Duel.SelectOption(tp, aux.Stringid(id, 2))
	else
		op=Duel.SelectOption(tp, aux.Stringid(id, 3))
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
		local g1=Duel.SelectTarget(tp, cid.desfilter1, tp, LOCATION_ONFIELD, 0, 1, 1, e:GetHandler())
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
		local g2=Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1, nil)
		g1:Merge(g2)
		Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
		Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 1, tp, 1)
	else
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
		local g1=Duel.SelectTarget(tp, cid.desfilter1, tp, LOCATION_ONFIELD, 0, 1, 1, e:GetHandler())
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
		local g2=Duel.SelectTarget(tp, cid.desfilter2, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
		g1:Merge(g2)
		Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
		Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 1, tp, 1)
	end
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local g=Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
		local tg=g:Filter(Card.IsRelateToEffect, nil, e)
		if tg:GetCount()>0 then
			Duel.Destroy(tg, REASON_EFFECT)
			local og=Duel.GetOperatedGroup()
			if og:IsExists(cid.ffilter, 1, nil, tp) and Duel.IsPlayerCanDraw(tp, 1) then
				Duel.BreakEffect()
				Duel.Draw(tp, 1, REASON_EFFECT)
			end
		end
	else
		local g=Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
		local tg=g:Filter(Card.IsRelateToEffect, nil, e)
		if tg:GetCount()>0 then
			Duel.Destroy(tg, REASON_EFFECT)
			local og=Duel.GetOperatedGroup()
			if og:IsExists(cid.ffilter, 1, nil, tp) and Duel.IsPlayerCanDraw(tp, 1) then
				Duel.BreakEffect()
				Duel.Draw(tp, 1, REASON_EFFECT)
			end
		end
	end
end