--Shalia, la Nottesfumo Decadenza
--Script by XGlitchy30
function c62613308.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x6233),4,2,c62613308.ovfilter,aux.Stringid(62613308,0),2,c62613308.xyzop)
	c:EnableReviveLimit()
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62613308,1))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,62613308)
	e1:SetCondition(c62613308.negcon)
	e1:SetCost(c62613308.negcost)
	e1:SetTarget(c62613308.negtg)
	e1:SetOperation(c62613308.negop)
	c:RegisterEffect(e1)
end
--filters
function c62613308.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6233) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_SYNCHRO) and c:GetLevel()==4
end
function c62613308.cfilter(c)
	return c:IsSetCard(0x6233) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
--xyz alternative limit
function c62613308.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,62613308)==0 end
	Duel.RegisterFlagEffect(tp,62613308,RESET_PHASE+PHASE_END,0,1)
end
--negate
function c62613308.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function c62613308.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c62613308.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c62613308.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c62613308.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c62613308.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end