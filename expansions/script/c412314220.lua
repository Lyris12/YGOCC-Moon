--created by Jake, coded by Glitchy
local s,id=GetID()
function s.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),6,3,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x613) and c:IsType(TYPE_XYZ)
end
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	if #g>=2 then
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,PLAYER_ALL,math.floor(#g/2))
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.Destroy(g,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	if #og>=2 then
		Duel.BreakEffect()
		local ct=math.floor(#og/2)
		local ct2=ct
		local ct3,ct4=Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT),Duel.GetMatchingGroupCount(Card.IsDiscardable,1-tp,LOCATION_HAND,0,nil,REASON_EFFECT)
		if ct3<ct then ct=ct3 end
		if ct4<ct2 then ct2=ct4 end
		Duel.DiscardHand(tp,Card.IsDiscardable,ct,ct,REASON_EFFECT+REASON_DISCARD,nil,REASON_EFFECT)
		Duel.DiscardHand(1-tp,Card.IsDiscardable,ct2,ct2,REASON_EFFECT+REASON_DISCARD,nil,REASON_EFFECT)
	end
end