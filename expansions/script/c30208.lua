--Mantra Mantis
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:GetCode()>30200 and tc:GetCode()<30230 end)
	--Activate(summon)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCondition(scard.condition1)
	e1:SetCost(scard.cost1)
	e1:SetTarget(scard.target1)
	e1:SetOperation(scard.activate1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,s_id)
	c:RegisterEffect(e1)
	--Activate(effect)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(scard.condition2)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(scard.cost2)
	e4:SetTarget(scard.target2)
	e4:SetOperation(scard.activate2)
	e4:SetCountLimit(1,s_id)
	c:RegisterEffect(e4)
end
function scard.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
end
function scard.cfilter1(c)
	return c:IsMantra() and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function scard.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(scard.cfilter1,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,scard.cfilter1,1,1,REASON_COST)
end
function scard.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
function scard.activate1(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
function scard.condition2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) then return false end
	if re:IsActiveType(TYPE_MONSTER) and re:IsHasType(EFFECT_TYPE_ACTIVATE) then return true end
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
end
function scard.cfilter2(c)
	return c:IsMantra() and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function scard.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(scard.cfilter2,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,scard.cfilter2,1,1,REASON_COST)
end
function scard.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function scard.activate2(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
