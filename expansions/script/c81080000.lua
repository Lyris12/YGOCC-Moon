--Alchemage Concoction
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableCounterPermit(0x1818)
	--add counters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--token
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	--sent to gy
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(cid.condition)
	e3:SetTarget(cid.destg)
	e3:SetOperation(cid.desop)
	c:RegisterEffect(e3)
end
--Conditions
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:GetPreviousControler()==tp
end
--Filters
function cid.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or c:IsSetCard(0x8108)
end
--add counters
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanAddCounter(tp,0x1818,5,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,5,0,0x1818)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1818,5)
	end
end
--token spawn
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,21770262,0,0x4011,300,300,1,RACE_AQUA,ATTRIBUTE_WATER) and e:GetHandler():GetCounter(0x1818)>2  end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:GetCounter(0x1818)>=10 then
		c:RemoveCounter(tp,0x1818,3,REASON_EFFECT)
		local token=Duel.CreateToken(tp,21770264)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		token:AddCounter(0x1818,3)
		--immune spell
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(cid.efilter)
		token:RegisterEffect(e2,true)
		token:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(21770264,0))
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(aux.TargetBoolFunction(aux.NOT(Card.IsSetCard),0x8108))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	elseif c:GetCounter(0x1818)>=6 then
		c:RemoveCounter(tp,0x1818,3,REASON_EFFECT)
		local token=Duel.CreateToken(tp,21770263)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		token:AddCounter(0x1818,3)
		--immune spell
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(cid.efilter)
		token:RegisterEffect(e2,true)
		token:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(21770263,0))
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(aux.TargetBoolFunction(aux.NOT(Card.IsSetCard),0x8108))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	elseif c:GetCounter(0x1818)>=3 then
		c:RemoveCounter(tp,0x1818,3,REASON_EFFECT)
		local token=Duel.CreateToken(tp,21770262)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		token:AddCounter(0x1818,3)
		--immune spell
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(cid.efilter)
		token:RegisterEffect(e2,true)
		token:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(21770262,0))
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(aux.TargetBoolFunction(aux.NOT(Card.IsSetCard),0x8108))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	else
		return
	end
end
function cid.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--Spawn from being sent
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,73915052,0,0x4011,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21770262,0,0x4011,300,300,1,RACE_AQUA,ATTRIBUTE_WATER) then
		local token1=Duel.CreateToken(tp,21770262)
		local token2=Duel.CreateToken(tp,21770262)
		Duel.SpecialSummon(token1,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummon(token2,0,tp,tp,false,false,POS_FACEUP)
	end
end