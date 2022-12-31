--Untergang Knight, Lancelot
function c400005.initial_effect(c)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(423585,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,400005)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c400005.spcost)
	e2:SetTarget(c400005.sptg)
	e2:SetOperation(c400005.spop)
	c:RegisterEffect(e2)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67300516,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(c400005.spcon)
	e1:SetTarget(c400005.target)
	e1:SetOperation(c400005.operation)
	e1:SetCountLimit(1,1400005)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(400001,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c400005.condition)
	e3:SetOperation(c400005.op)
	e3:SetCountLimit(1,11400005)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(400005,ACTIVITY_CHAIN,c400005.chainfilter)
end
function c400005.chainfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL))
end
function c400005.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable(REASON_EFFECT)
end
function c400005.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c400005.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
function c400005.filter(c,e,tp)
	return c:IsSetCard(0x146) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c400005.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c400005.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c400005.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsExistingMatchingCard(c400005.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) then return end
	if Duel.DiscardHand(tp,c400005.costfilter,1,1,REASON_EFFECT+REASON_DISCARD)==0 then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c400005.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c400005.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetCustomActivityCount(400005,tp,ACTIVITY_CHAIN)==0
end
function c400005.thfilter(c)
	return c:GetType()&TYPE_SPELL+TYPE_QUICKPLAY==TYPE_SPELL+TYPE_QUICKPLAY and c:IsSetCard(0x146)
		and c:IsSSetable()
end
function c400005.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c400005.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function c400005.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,c400005.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.SSet(tp,tc)
		Duel.ConfirmCards(1-tp,tc)
	end
end
function c400005.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and re:GetHandler():IsType(TYPE_QUICKPLAY) and re:GetHandler():IsSetCard(0x146) and rp==tp
end
function c400005.chfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x146)
end
function c400005.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c400005.chfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
