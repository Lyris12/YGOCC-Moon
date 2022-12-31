--This file was automatically coded by Kinny's Numeron Code~!
local ref=_G['c'..28916160]
local id=28916160
function ref.initial_effect(c)
	--Effect 0
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetCountLimit(1,289161600)
	e0:SetCondition(ref.sscon)
	e0:SetTarget(ref.target0)
	e0:SetOperation(ref.operation0)
	c:RegisterEffect(e0)
	--Effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,289161601)
	e1:SetCondition(ref.cond1)
	e1:SetCost(ref.cost1)
	e1:SetTarget(ref.target1)
	e1:SetOperation(ref.operation1)
	c:RegisterEffect(e1)
end
function ref.filterE0P0(c,e,tp)
	return c:IsCode(28916161) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function ref.filterE1P0(c)
	return c:IsCanTurnSet() and c:IsType(TYPE_MONSTER)
end
function ref.sscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(ref.sscfilter,tp,LOCATION_ONFIELD,0,1,c,c)
end
function ref.sscfilter(c,tc)
	return c:IsFaceup() and c:IsSetCard(1856)
		and c:GetCode()~=tc:GetCode()
end
function ref.target0(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.filterE0P0,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function ref.operation0(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local g0 = Duel.SelectMatchingCard(tp,ref.filterE0P0,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g0<=0 then return end
	Duel.SpecialSummon(g0,0,tp,tp,false,false,POS_FACEUP)
end
function ref.cond1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function ref.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.filterE1P0,tp,LOCATION_MZONE,0,1,nil) end
	local g0 = Duel.SelectMatchingCard(tp,ref.filterE1P0,tp,LOCATION_MZONE,0,1,1,nil)
	if #g0>0 then
		Duel.HintSelection(g0)
		Duel.ChangePosition(g0,POS_FACEDOWN_DEFENSE)
	end
end
function ref.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function ref.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then 
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
