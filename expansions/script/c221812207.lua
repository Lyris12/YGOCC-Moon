--S.S.D.: Solid State Dragon
function c221812207.initial_effect(c)
	c:EnableReviveLimit()
	--Materials: 2+ Cyberse monsters
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERS),2,4)
	--This card cannot be destroyed by battle while it points to an Xyz monster.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c221812207.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Once per turn, when a monster this card points to is targeted by a card effect (Quick Effect): You can detach 1 material from an Xyz Monster you control OR pay 1000 LP; negate the effect, and if you do, destroy that card.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1)
	e1:SetDescription(aux.Stringid(221812207,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetCondition(c221812207.condition)
	e1:SetCost(c221812207.cost)
	e1:SetTarget(c221812207.distg)
	e1:SetOperation(c221812207.disop)
	c:RegisterEffect(e1)
end
function c221812207.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function c221812207.indcon(e)
	return e:GetHandler():GetLinkedGroup():FilterCount(c221812207.indfilter,nil)>0
end
function c221812207.cfilter(c,g)
	return g:IsContains(c)
end
function c221812207.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	return Duel.IsChainDisablable(ev)
		and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):FilterCount(c221812207.cfilter,nil,lg)>0
end
function c221812207.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST)
	local b2=Duel.CheckLPCost(tp,1000)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(221812207,0),aux.Stringid(221812207,1))
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(221812207,1))+1
	else op=Duel.SelectOption(tp,aux.Stringid(221812207,0)) end
	if op~=0 then
		Duel.PayLPCost(tp,1000)
	else Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST) end
end
function c221812207.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c221812207.disop(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
