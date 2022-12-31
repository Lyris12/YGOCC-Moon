--C.VIATRIX: Comandante
--Script by XGlitchy30
function c1020094.initial_effect(c)
	--link procedure
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	--boost
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1020094,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c1020094.lkcon)
	e1:SetOperation(c1020094.lkop)
	c:RegisterEffect(e1)
	--immunity
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1020094,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c1020094.imcost)
	e2:SetOperation(c1020094.imop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1020094,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,1020094)
	e3:SetCondition(c1020094.spcon)
	e3:SetTarget(c1020094.sptg)
	e3:SetOperation(c1020094.spop)
	c:RegisterEffect(e3)
end
--filters
function c1020094.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_CYBERSE)
end
function c1020094.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x39c) and c:IsType(TYPE_MONSTER)
end
function c1020094.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_MONSTER) and c:GetLevel()<=4 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--boost
function c1020094.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c1020094.lkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c1020094.atkfilter,tp,LOCATION_MZONE,0,nil)
	local gval=Duel.GetMatchingGroup(c1020094.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	local atk=gval:GetCount()*400
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
function c1020094.atkval(e,c)
	return Duel.GetMatchingGroupCount(c1020094.atkfilter,c:GetControler(),LOCATION_MZONE,0,c)*400
end
--immunity
function c1020094.imcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c1020094.costfilter,1,e:GetHandler()) end
	local cg=Duel.SelectReleaseGroup(tp,c1020094.costfilter,1,1,e:GetHandler())
	Duel.Release(cg,REASON_COST)
end
function c1020094.imop(e,tp,eg,ep,ev,re,r,rp)
	local phase=0
	if Duel.GetTurnPlayer()==tp then
		phase=RESET_OPPO_TURN
	else
		phase=RESET_SELF_TURN
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTarget(c1020094.imtg)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END+phase)
	e1:SetValue(c1020094.imval)
	e1:SetOwnerPlayer(tp)
	Duel.RegisterEffect(e1,tp)
end
function c1020094.imtg(e,c)
	return c:IsSetCard(0x39c) and c:IsType(TYPE_MONSTER)
end
function c1020094.imval(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetOwnerPlayer() 
end
--spsummon
function c1020094.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp
end
function c1020094.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c1020094.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function c1020094.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c1020094.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end