--Everlasting Vertex Melody
--Scripted by Zerry
function c11111312.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(11111312,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e0)
	local e1=e0:Clone(c)
	e1:SetDescription(aux.Stringid(11111312,1))
	e1:SetCountLimit(1,11111312)
	e1:SetCondition(c11111312.pencon)
	e1:SetTarget(c11111312.pentg)
	e1:SetOperation(c11111312.penop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,11111312)
	e2:SetCost(c11111312.pencost)
	e2:SetTarget(c11111312.pentg)
	e2:SetOperation(c11111312.penop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,11111312)
	e3:SetCondition(c11111312.condition)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c11111312.target)
	e3:SetOperation(c11111312.operation)
	c:RegisterEffect(e3)
end
--If no Scale, set Scale
function c11111312.penfilter(c)
	return c:IsSetCard(0x5a3) and c:IsType(TYPE_PENDULUM) and c:IsFacedown() and not c:IsForbidden()
end
function c11111312.pencon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.GetFieldCard(tp,LOCATION_PZONE,0) and not Duel.GetFieldCard(tp,LOCATION_PZONE,1)
end
--If scale, replace scale with other scale
function c11111312.cfilter(c)
	return c:IsSetCard(0x5a3) and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
end
function c11111312.pencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11111312.cfilter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c11111312.cfilter,tp,LOCATION_PZONE,0,1,1,nil)
	Duel.Destroy(g,nil,REASON_COST)
end
function c11111312.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(c11111312.penfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function c11111312.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,c11111312.penfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--If no monster, summon Arietta
function c11111312.filter(c,e,tp)
	return c:IsCode(11111301) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11111312.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function c11111312.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c11111312.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c11111312.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c11111312.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
