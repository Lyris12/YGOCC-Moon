--Inferioringranaggio - Trisrax
--Script by XGlitchy30
function c63553452.initial_effect(c)
	c:EnableCounterPermit(0x1554)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63553452,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,63553452)
	e1:SetCost(c63553452.spcost)
	e1:SetTarget(c63553452.sptg)
	e1:SetOperation(c63553452.spop)
	c:RegisterEffect(e1)
	--place counters (on targets)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63553452,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c63553452.cttg)
	e2:SetOperation(c63553452.ctop)
	c:RegisterEffect(e2)
	--clear strike
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c63553452.actcon)
	e3:SetValue(c63553452.actlimit)
	c:RegisterEffect(e3)
	--pierce
	local prc=Effect.CreateEffect(c)
	prc:SetType(EFFECT_TYPE_SINGLE)
	prc:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(prc)
	--place counter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c63553452.ctrcon)
	e4:SetOperation(c63553452.ctrop)
	c:RegisterEffect(e4)
end
--filters
function c63553452.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4554)
end
function c63553452.cttarget(c)
	return not (c:IsCode(63553462) and c:IsType(TYPE_SPELL+TYPE_TRAP))
end
--special summon
function c63553452.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1554,1,REASON_EFFECT) end
	if Duel.IsCanRemoveCounter(tp,1,1,0x1554,1,REASON_COST) then
		Duel.RemoveCounter(tp,1,1,0x1554,1,REASON_COST)
	end
end
function c63553452.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c63553452.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x47e0000)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
--place counters
function c63553452.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroupCount(c63553452.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chkc then return chkc:IsFaceup() and c63553452.cttarget(chkc) end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c63553452.cttarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c63553452.cttarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x1554,ct)
end
function c63553452.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(c63553452.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if ct<=0 then return end
	local gtc=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=gtc:GetFirst()
	while tc do
		tc:AddCounter(0x1554,ct,true)
		tc=gtc:GetNext()
	end
end
--clear strike
function c63553452.actcon(e)
	local tc=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return tc and tc:IsControler(tp) and tc:GetCounter(0)~=0
end
function c63553452.actlimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
--place counter
function c63553452.ctrcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=eg:GetFirst()
	return rc==e:GetHandler()
end
function c63553452.ctrop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1554,1)
end