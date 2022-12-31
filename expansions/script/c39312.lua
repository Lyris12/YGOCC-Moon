function c39312.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39312.target)
	e1:SetOperation(c39312.operation)
	c:RegisterEffect(e1)
	--atk change
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e2:SetCode(511001265)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c39312.spcon1)
	e2:SetTarget(c39312.sptg)
	e2:SetOperation(c39312.spop)
	e2:SetCountLimit(1,39312)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c39312.spcon2)
	e3:SetTarget(c39312.sptg)
	e3:SetOperation(c39312.spop)
	e3:SetCountLimit(1,39312)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetRange(LOCATION_HAND)
	e4:SetTarget(c39312.sptg)
	e4:SetOperation(c39312.spop)
	e4:SetCountLimit(1,39312)
	c:RegisterEffect(e4)
	if not c39312.global_check then
		c39312.global_check=true
		--register
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetCountLimit(1)
		ge1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		ge1:SetOperation(c39312.atkchk)
		Duel.RegisterEffect(ge1,0)
	end
end
function c39312.atkchk(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,419)==0 and Duel.GetFlagEffect(1-tp,419)==0 then
		Duel.CreateToken(tp,419)
		Duel.CreateToken(1-tp,419)
		Duel.RegisterFlagEffect(tp,419,nil,0,1)
		Duel.RegisterFlagEffect(1-tp,419,nil,0,1)
	end
end
function c39312.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (eg:GetCount()>0) then return false end
	local val=0
	local chk=0
	local tc=eg:GetFirst()
	while tc do
		if tc:GetFlagEffect(284)>0 then val=tc:GetFlagEffectLabel(284) end
		if tc:GetAttack()>val then chk=chk+1 end
		tc=eg:GetNext()
	end
	-- Debug.Message("poi")
	Debug.Message(chk)
	return chk>0
end
function c39312.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c39312.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (not c:IsRelateToEffect(e)) or Duel.GetFlagEffect(tp,39312)>0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SendtoGrave(c,REASON_RULE)
	end
end
function c39312.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (eg:GetCount()>0) then return false end
	if eg:IsExists(Card.IsType,1,nil,TYPE_TOKEN) then return true else return false end
end
function c39312.spcon3(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
function c39312.filter(c)
	return c:IsFaceup() and c:GetCode()>39300 and c:GetCode()<39319 and not c:IsCode(39311,39312)
end
function c39312.filter(c)
	return c:IsFaceup()
end
function c39312.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c39312.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c39312.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) and Duel.GetFlagEffect(tp,39312)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c39312.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.RegisterFlagEffect(tp,39312,RESET_PHASE+PHASE_END,0,1)
end
function c39312.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
