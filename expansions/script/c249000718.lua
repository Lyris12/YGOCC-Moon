--Evolution-Knight's Aura
function c249000718.initial_effect(c)
	--end battle phase
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c249000718.condition)
	e1:SetTarget(c249000718.target)
	e1:SetOperation(c249000718.operation)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5818294,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c249000718.negcon)
	e2:SetCost(c249000718.negcost)
	e2:SetTarget(c249000718.negtg)
	e2:SetOperation(c249000718.negop)
	c:RegisterEffect(e2)
end
function c249000718.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function c249000718.filter(c,e,tp)
	return c:IsSetCard(0x1E9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c249000718.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c249000718.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c249000718.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000718.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
	end
end
function c249000718.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and (c:IsSetCard(0x1E9) or c:IsType(TYPE_XYZ) or c:IsType(TYPE_SYNCHRO))
end
function c249000718.confilter(c)
	return c:IsSetCard(0x1E9) and not c:IsCode(249000718)
end
function c249000718.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c249000718.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev) and Duel.IsExistingMatchingCard(c249000718.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
function c249000718.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c249000718.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function c249000718.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end 