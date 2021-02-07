--Change True Power of Superquant - Magnus Union
function c249001159.initial_effect(c)
	return
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(c249001159.condition)
	e1:SetTarget(c249001159.target)
	e1:SetOperation(c249001159.operation)
	c:RegisterEffect(e1)
end
function c249001159.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(249001155)
end
function c249001159.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001159.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(tp,249001159)==0
end
function c249001159.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,84025439,0xdc,TYPE_MONSTER+TYPE_XYZ+TYPE_EFFECT,3600,3200,12, RACE_MACHINE,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function c249001159.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,249001159)~=0 then return end
	Duel.RegisterFlagEffect(tp,249001159,0,0,0)
	local cc=Duel.CreateToken(tp,84025439)
	if Duel.SpecialSummonStep(cc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetCondition(c249001159.tdcon)
		e1:SetOperation(c249001159.tdop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		cc:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
	local i=0
	for i=0,4 do
		local tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
		if tc2 then
			Duel.Overlay(cc,tc2)
		end
	end
end
function c249001159.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c249001159.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
end