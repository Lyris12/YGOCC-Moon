--created by Seth, coded by Lyris
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, id)
	e1:SetCondition(cid.condition)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
function cid.condition(e, tp, eg, ep, ev, re, r, rp)
	if tp==ep or not Duel.IsChainDisablable(ev) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DISABLE)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsControler, nil, tp)-#tg>0
end
function cid.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetActivityCount(tp, ACTIVITY_BATTLE_PHASE)==0 and c:IsAbleToGraveAsCost() and
		Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost, tp, LOCATION_HAND, 0, 1, c) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, Card.IsAbleToGraveAsCost, tp, LOCATION_HAND, 0, 1, 1, c)
	g:AddCard(c)
	Duel.SendtoGrave(g, REASON_COST)
	--Cannot conduct Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1, 0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1, tp)
end
function cid.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) end
	Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end
function cid.operation(e, tp, eg, ep, ev, re, r, rp)
	Duel.NegateEffect(ev)
	--Cannot activate cards or effects from hand
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1, 0)
	e1:SetValue(cid.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1, tp)
end
function cid.aclimit(e, re, tp)
	return re:GetHandler():IsLocation(LOCATION_HAND)
end
