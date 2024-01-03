--Cyber Dragon Variieren
function c249001148.initial_effect(c)
	--spsummon on attack
	--local e1=Effect.CreateEffect(c)
	--e1:SetDescription(aux.Stringid(12423762,0))
	--e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	--e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	--e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	--e1:SetRange(LOCATION_GRAVE)
	--e1:SetCountLimit(1,249001148)
	--e1:SetCondition(c249001148.spcon)
	--e1:SetTarget(c249001148.sptg)
	--e1:SetOperation(c249001148.spop)
	--c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1108)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetCountLimit(1,249001148)
	e2:SetCondition(c249001148.drcon)
	e2:SetCost(c249001148.cost)
	e2:SetTarget(c249001148.drtg)
	e2:SetOperation(c249001148.drop)
	c:RegisterEffect(e2)
	--spsummon on summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(2)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,249001148)
	e3:SetCondition(c249001148.spcon2)
	e3:SetCost(c249001148.cost)
	e3:SetTarget(c249001148.sptg2)
	e3:SetOperation(c249001148.spop2)
	c:RegisterEffect(e3)
	--name change
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CHANGE_CODE)
	e4:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e4:SetValue(70095154)
	c:RegisterEffect(e4)
	Duel.AddCustomActivityCounter(249001148,ACTIVITY_SPSUMMON,c249001148.counterfilter)
end
function c249001148.counterfilter(c)
	return not c:IsSetCard(0x4093)
end
--function c249001148.spcon(e,tp,eg,ep,ev,re,r,rp)
--	local at=Duel.GetAttacker()
--	return at:GetControler()~=tp and Duel.GetAttackTarget()==nil
--end
--function c249001148.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
--	local c=e:GetHandler()
--	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
--		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
--	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
--end
--function c249001148.spop(e,tp,eg,ep,ev,re,r,rp)
--	local c=e:GetHandler()
--	if c:IsRelateToEffect(e) then
--		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
--			Duel.NegateAttack()
--		end
--	end
--end
function c249001148.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function c249001148.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(2490001148,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c249001148.splimit)
	Duel.RegisterEffect(e1,tp)
end
function c249001148.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsSetCard(0x4093)
end
function c249001148.drspfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function c249001148.drdisfilter(c)
	return c:IsSetCard(0x1093) and c:IsType(TYPE_MONSTER)
end
function c249001148.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(c249001148.drspfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return ct> 0 and Duel.IsPlayerCanDraw(tp,ct) and Duel.IsExistingMatchingCard(c249001148.drdisfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,2)
end
function c249001148.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,c249001148.drdisfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	local ct=Duel.GetMatchingGroupCount(c249001148.drspfilter,tp,0,LOCATION_MZONE,nil)
	if ct>0 then Duel.Draw(tp,ct,REASON_EFFECT) end
end
function c249001148.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1093)
end
function c249001148.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c249001148.cfilter,1,nil)
end
function c249001148.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c249001148.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(5)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end