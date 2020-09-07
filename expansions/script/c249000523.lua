--Varia-Mage Temporal Master
function c249000523.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,2490005231)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c249000523.spcon)
	e1:SetTarget(c249000523.sptg)
	e1:SetOperation(c249000523.spop)
	c:RegisterEffect(e1)
	--spsummon success
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,2490005232)
	e2:SetCondition(c249000523.spcon2)
	e2:SetTarget(c249000523.sptg2)
	e2:SetOperation(c249000523.spop2)
	c:RegisterEffect(e2)
	--spsummon from extra
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(34206604,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,2490005233)
	e3:SetCondition(c249000523.condition)
	e3:SetTarget(c249000523.target)
	e3:SetOperation(c249000523.operation)
	c:RegisterEffect(e3)
end
function c249000523.spfilter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp and c:IsType(TYPE_MONSTER)
end
function c249000523.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c249000523.spfilter,1,nil,tp)
end
function c249000523.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c249000523.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function c249000523.filter1(c)
	return c:IsSetCard(0x1C8) and c:IsType(TYPE_MONSTER)
end
function c249000523.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0x1C8) and Duel.IsExistingMatchingCard(c249000523.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler())
end
function c249000523.filter2(c,e,tp)
	return (c:GetTurnID()==Duel.GetTurnCount() or c:GetTurnID()==Duel.GetTurnCount()-1) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c249000523.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c249000523.filter2(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c249000523.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		local g=Duel.SelectTarget(tp,c249000523.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	else
		local g=Duel.SelectTarget(tp,c249000523.filter2,tp,LOCATION_GRAVE,0,1,2,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
function c249000523.spop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if g:GetCount()<=ct then
		if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
		local tc=g:GetFirst()
		while tc do
			Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2,true)
			tc=g:GetNext()
		end
		Duel.SpecialSummonComplete()
	end
end
function c249000523.filter3(c)
	return c:IsSetCard(0x1C8) and c:IsType(TYPE_MONSTER)
end
function c249000523.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c249000523.filter3,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,e:GetHandler())
	local ct=g:GetClassCount(Card.GetCode)
	return ct>2
end
function c249000523.filter4(c,e,tp)
	if not (c:GetLevel() > 0) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	local mg=Duel.GetMatchingGroup(c249000523.filter5,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
	return mg:CheckWithSumGreater(Card.GetLevel,math.ceil(c:GetLevel()*1.5),c)
end
function c249000523.filter5(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
function c249000523.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then	return Duel.IsExistingMatchingCard(c249000523.filter4,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000523.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(c249000523.filter5,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,c249000523.filter4,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=tg:GetFirst()
	if tc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local mat=mg:SelectWithSumGreater(tp,Card.GetLevel,math.ceil(tc:GetLevel()*1.5),tc)	
		Duel.Remove(mat,POS_FACEUP,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end