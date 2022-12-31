--Ritmi Mistici - Violinista Ingegnoso
--Script by XGlitchy30
function c76565321.initial_effect(c)
	c:EnableCounterPermit(0x1555)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,76565321)
	e1:SetCondition(c76565321.spcon)
	e1:SetTarget(c76565321.sptg)
	e1:SetOperation(c76565321.spop)
	c:RegisterEffect(e1)
	--protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c76565321.prottg)
	e2:SetValue(c76565321.protval)
	c:RegisterEffect(e2)
	--counter
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1,76165321)
	e3:SetCondition(c76565321.rmcon)
	e3:SetTarget(c76565321.rmtg)
	e3:SetOperation(c76565321.rmop)
	c:RegisterEffect(e3)
end
--filters
function c76565321.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousSetCard(0x7555) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function c76565321.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7555) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
end
function c76565321.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x7555) and c:IsCanRemoveCounter(c:GetControler(),0x1555,1,REASON_EFFECT)
end
--spsummon
function c76565321.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c76565321.spcfilter,1,nil,tp)
end
function c76565321.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c76565321.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--protection
function c76565321.prottg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x7555) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
end
function c76565321.protval(e,re,tp)
	return re:GetHandler():GetControler()~=tp
end
--counter
function c76565321.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
		and Duel.IsExistingMatchingCard(c76565321.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c76565321.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76565321.rmfilter,tp,LOCATION_SZONE,0,1,nil) end
end
function c76565321.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.GetMatchingGroup(c76565321.rmfilter,tp,LOCATION_SZONE,0,nil)
	if g:GetCount()==0 then return end
	local sg=g:Select(tp,1,g:GetCount(),nil)
	local tc=sg:GetFirst()
	while tc do
		if tc:IsCanRemoveCounter(e:GetHandler():GetControler(),0x1555,1,REASON_EFFECT) then
			tc:RemoveCounter(tp,0x1555,1,REASON_EFFECT)
		end
		tc=sg:GetNext()
	end
end