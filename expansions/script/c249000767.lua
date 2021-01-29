--Varia-Force Vetran Tactician
function c249000767.initial_effect(c)
	--destroy replace
	--local e1=Effect.CreateEffect(c)
	--e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	--e1:SetCode(EFFECT_DESTROY_REPLACE)
	--e1:SetRange(LOCATION_GRAVE)
	--e1:SetTarget(c249000767.reptg)
	--e1:SetValue(c249000767.repval)
	--e1:SetOperation(c249000767.repop)
	--c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1108)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,24900767)
	e2:SetCondition(c249000767.condition)
	e2:SetCost(c249000767.cost)
	e2:SetTarget(c249000767.target)
	e2:SetOperation(c249000767.operation)
	c:RegisterEffect(e2)
	--count
	if not c249000767.global_check then
		c249000767.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c249000767.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		Duel.RegisterEffect(ge3,0)
	end
end
--function c249000767.repfilter(c,tp)
--	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x1B6)
--		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
--end
--function c249000767.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
--	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c249000767.repfilter,1,nil,tp) end
--	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
--end
--function c249000767.repval(e,c)
--	return c249000767.repfilter(c,e:GetHandlerPlayer())
--end
--function c249000767.repop(e,tp,eg,ep,ev,re,r,rp)
--	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
--end
function c249000767.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),249000767,RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
function c249000767.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(1-tp,249000767)>=3
end
function c249000767.costfilter(c)
	return c:IsSetCard(0x1B6) and c:IsDiscardable()
end
function c249000767.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and
		Duel.IsExistingMatchingCard(c249000767.costfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c249000767.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function c249000767.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,4-ht)
end
function c249000767.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c249000767.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ht<4 then
		Duel.Draw(tp,4-ht,REASON_EFFECT)
	end
end
function c249000767.damval(e,re,val,r,rp,rc)
	return val/2
end
