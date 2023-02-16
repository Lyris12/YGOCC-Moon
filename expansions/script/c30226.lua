--Hawk
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:IsSetCard(0x7d0) or (tc:GetCode()>30200 and tc:GetCode()<30230) end)
	--synchro summon
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,Card.IsMantra,aux.NonTuner(nil),1)
	--
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,s_id+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(aux.SynchroSummonedCond)
	e1:SetTarget(scard.tg)
	e1:SetOperation(scard.op)
	c:RegisterEffect(e1)
end
function scard.filter(c)
	return c:IsMantra() and c:IsType(TYPE_MONSTER) and c:NotOnFieldOrFaceup() and not c:IsCode(s_id)
end
function scard.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(scard.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE)
end
function scard.ctfilter(c,e)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_EFFECT) and c:GetReasonEffect()==e
end
function scard.op(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(scard.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,nil)
	if #rg<=0 then return end
	local g=rg:SelectSubGroup(tp,aux.dncheck,false,1,3)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local ct=Duel.GetOperatedGroup():FilterCount(scard.ctfilter,nil,e)
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(ct*600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
