--Mega Warrior X
function c249001130.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,c249001130.mfilter,8,3,c249001130.ovfilter,aux.Stringid(51543904,0),3,c249001130.xyzop)
	c:EnableReviveLimit()
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65884091,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c249001130.operation)
	c:RegisterEffect(e1)
	--destroy quick
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43892408,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c249001130.cost)
	e2:SetTarget(c249001130.target)
	e2:SetOperation(c249001130.activate)
	c:RegisterEffect(e2)
end
function c249001130.ovfilter(c)
	return c:IsFaceup() and c249001130.mfilter(c)
end
function c249001130.mfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c249001130.spfilter(c,code)
	return c:IsAbleToDeckOrExtraAsCost() and c:IsCode(code) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function c249001130.xyzop(e,tp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001130.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,249000005)
		and Duel.IsExistingMatchingCard(c249001130.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,249000006)
		and Duel.IsExistingMatchingCard(c249001130.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,249000529) end
	local g=Group.CreateGroup()
	local g1=Duel.SelectMatchingCard(tp,c249001130.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,249000005)
	g:Merge(g1)
	local g2=Duel.SelectMatchingCard(tp,c249001130.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,249000006)
	g:Merge(g2)
	local g3=Duel.SelectMatchingCard(tp,c249001130.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,249000529)
	g:Merge(g3)
	Duel.SendtoDeck(g,nil,2,REASON_COST)	
end
function c249001130.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c249001130.efilter)
		c:RegisterEffect(e1)
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,c)
		local tc=g:GetFirst()
		while tc do
			c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD-RESET_TOGRAVE-RESET_TOFIELD)
			tc=g:GetNext()
		end
	end
end
function c249001130.efilter(e,te)
	return te:IsActiveType(TYPE_EFFECT) and te:GetOwner()~=e:GetOwner()
end
function c249001130.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST)
end
function c249001130.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c249001130.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c249001130.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end