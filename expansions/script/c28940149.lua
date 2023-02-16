--Symphaerie Motif, Jrako
local ref,id=GetID()
function ref.initial_effect(c)
	--[Pendulum]
	aux.EnablePendulumAttribute(c,false)
	--Activate
	local pe1=Effect.CreateEffect(c)
	pe1:SetCategory(CATEGORY_REMOVE)
	pe1:SetType(EFFECT_TYPE_ACTIVATE)
	pe1:SetCode(EVENT_FREE_CHAIN)
	pe1:SetOperation(ref.actop)
	c:RegisterEffect(pe1)
	--Change Scale
	local pe2=Effect.CreateEffect(c)
	pe2:SetDescription(aux.Stringid(id,1))
	pe2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	pe2:SetType(EFFECT_TYPE_IGNITION)
	pe2:SetCode(EVENT_FREE_CHAIN)
	pe2:SetRange(LOCATION_PZONE)
	pe2:SetCountLimit(1)
	pe2:SetCost(ref.sccost)
	pe2:SetOperation(ref.scop)
	c:RegisterEffect(pe2)

	--[Monster]
	--Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return not aux.exccon(e) end)
	e1:SetTarget(ref.postg)
	e1:SetOperation(ref.posop)
	c:RegisterEffect(e1)
	--Special Synchro
	----Level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(ref.slevel)
	c:RegisterEffect(e2)
	----Race
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SYNCHRO_CHECK)
	e3:SetValue(ref.syncheck)
	c:RegisterEffect(e3)
	----Non Response
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e4:SetCondition(ref.effcon)
	e4:SetOperation(ref.effop1)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BE_PRE_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e5:SetCondition(ref.effcon)
	e5:SetOperation(ref.effop2)
	c:RegisterEffect(e5)
end

--Activate
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=g:Select(tp,1,3,nil)
		local ct=Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		if ct>0 then Duel.SortDecktop(tp,tp,ct) end
	end
end

--Scale
function ref.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,Card.IsCanTurnSet,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_MZONE) then Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	else Duel.ChangePosition(tc,POS_FACEDOWN) end
end
function ref.scop(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		c:RegisterEffect(e2)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetLabelObject(c)
		e3:SetCondition(ref.descon)
		e3:SetOperation(ref.desop)
		Duel.RegisterEffect(e3,tp)
	end
end
function ref.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function ref.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end

--Special Synchro
----Level
function ref.slevel(e,c)
	local lv=aux.GetCappedLevel(e:GetHandler())
	return (3<<16)+lv
end
----Race
function ref.syncheck(e,c) c:AssumeProperty(ASSUME_RACE,RACE_DRAGON) end
----Nonresponse
function ref.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
function ref.effop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetOperation(ref.sumop)
	rc:RegisterEffect(e1,true)
end
function ref.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(function(e,rp,tp) return tp==rp end)
end
function ref.effop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end


--Set
function ref.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsCanTurnSet() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function ref.posop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsLocation(LOCATION_MZONE) then Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		else Duel.ChangePosition(tc,POS_FACEDOWN) end
	end
end
