--
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,scard.tuner,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--change name
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e0:SetValue(44508094)
	c:RegisterEffect(e0)
	local e3=e0:Clone()
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetValue(0xa3)
	c:RegisterEffect(e3)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(scard.condition)
	e1:SetCost(scard.cost)
	e1:SetOperation(scard.operation)
	c:RegisterEffect(e1)
	--Revive
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(scard.sumtg)
	e2:SetOperation(scard.sumop)
	c:RegisterEffect(e2)
end
function scard.tuner(c)
	return c:IsSetCard(0xa3) or c:IsSetCard(0x43)
end
function scard.cfilter(c,tp)
	return c:GetSummonPlayer()~=tp
end
function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(scard.cfilter,1,nil,tp)
end
function scard.cfcost1(c)
	return c:IsFaceup() and c:IsSetCard(0xa3) and c:IsReleasable()
end
function scard.cfcost2(c)
	return c:IsCode(84012625) and c:IsAbleToRemoveAsCost()
end
function scard.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(scard.cfcost1,tp,LOCATION_MZONE,0,1,nil)
		or Duel.IsExistingMatchingCard(scard.cfcost2,tp,LOCATION_GRAVE,0,1,nil)) end
	if Duel.IsExistingMatchingCard(scard.cfcost1,tp,LOCATION_MZONE,0,1,nil) then
		local g=Duel.SelectMatchingCard(tp,scard.cfcost1,tp,LOCATION_MZONE,0,1,1,nil)
		e:SetLabel(g:GetFirst():GetAttack())
		if g:GetFirst()==e:GetHandler() and Duel.IsExistingMatchingCard(scard.cfcost2,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(84012625,0)) then
			local tg=Duel.GetFirstMatchingCard(scard.cfcost2,tp,LOCATION_GRAVE,0,nil)
			Duel.Remove(tg,POS_FACEUP,REASON_COST)
		else if g then Duel.Release(g,REASON_EFFECT) end
		end
	else
		local tg=Duel.GetFirstMatchingCard(scard.cfcost2,tp,LOCATION_GRAVE,0,nil)
		Duel.Remove(tg,POS_FACEUP,REASON_COST)
		e:SetLabel(e:GetHandler():GetAttack())
	end
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
	local val=e:GetLabel()
	if eg:GetCount()>0 then
		local ec=eg:GetFirst()
		for i=1,eg:GetCount() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			e1:SetValue(-val)
			ec:RegisterEffect(e1)
			local ec=eg:GetNext()
		end
	end
	e:GetHandler():RegisterFlagEffect(s_id,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,0)
end
function scard.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetFlagEffect(s_id)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function scard.sumop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
