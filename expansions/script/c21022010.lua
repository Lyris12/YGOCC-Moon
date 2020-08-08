--Advent of Etherveil
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
	local e0=Effect.CreateEffect(c)
                e0:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
                e0:SetCountLimit(1,id)
	e0:SetTarget(cid.target)
	e0:SetOperation(cid.activate)
	c:RegisterEffect(e0)
                --recover
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCategory(CATEGORY_TOHAND)
                e4:SetCountLimit(1,id)
	e4:SetCost(cid.tdcost)
	e4:SetTarget(cid.thtg)
	e4:SetOperation(cid.thop)
	c:RegisterEffect(e4)
end
function cid.filter1(c)
	return c:IsSetCard(0x312) and c:IsAbleToRemove()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter1,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.SelectMatchingCard(tp,cid.filter1,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g1)
	if g1:GetCount()==0 then return end
                Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
	Duel.BreakEffect()
                Duel.Draw(tp,2,REASON_EFFECT)
end
function cid.cfilter(c)
	return c:IsFacedown() and c:IsAbleToDeckAsCost()
end
function cid.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_REMOVED,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_REMOVED,0,3,3,e:GetHandler())
	Duel.SendtoDeck(g,nil,3,REASON_COST)
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end