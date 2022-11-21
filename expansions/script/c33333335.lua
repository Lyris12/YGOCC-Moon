--Quintosigillo Barriera
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(aux.ExceptOnDamageCalc)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local dc=Duel.GetEngagedCard(tp)
	if chk==0 then
		if not (dc and dc:IsMonster() and dc:IsSetCard(0x7eb) and dc:IsCanUpdateEnergy(-2,tp,REASON_COST)) then
			return false
		end
		local lvchk=(not dc:HasLevel() or (dc:GetEnergy()-2)~=dc:GetLevel())
		if not lvchk then
			local eff=dc:UpdateEnergy(-2,tp,REASON_TEMPORARY,nil,e:GetHandler())
			lvchk=dc:IsSpecialSummonable(SUMMON_TYPE_DRIVE)
			eff:Reset()
		end
		return lvchk
	end
	dc:UpdateEnergy(-2,tp,REASON_COST,true,e:GetHandler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=Duel.GetEngagedCard(tp)
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_FACEUP,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,LOCATION_MZONE,1000)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,LOCATION_MZONE,1000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain() or not tc:IsFaceup() then return end
	local rct = (Duel.IsEndPhase(tp)) and 2 or 1
	local e1,e2=tc:UpdateATKDEF(1000,1000,{RESET_PHASE+PHASE_END+RESET_TURN_SELF,rct},e:GetHandler())
	if not tc:IsImmuneToEffect(e1) and not tc:IsImmuneToEffect(e2) and not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		local dc=Duel.GetEngagedCard(tp)
		if dc and dc:HasLevel() and dc:GetEnergy()==dc:GetLevel() and dc:IsSpecialSummonable(SUMMON_TYPE_DRIVE) then
			Duel.SpecialSummonRule(tp,dc,SUMMON_TYPE_DRIVE)
		end
	end
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x7eb,0x7ec) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove(tp,POS_FACEUP,REASON_EFFECT+REASON_REPLACE) and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end