--Overlay Ritualist Invoker
function c249000392.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c249000392.cost)
	e1:SetTarget(c249000392.target)
	e1:SetOperation(c249000392.operation)
	c:RegisterEffect(e1)
	--special summon self
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c249000392.spcon)
	c:RegisterEffect(e2)
end
function c249000392.cfilter(c)
	return c:IsSetCard(0x155) and not c:IsPublic()
end
function c249000392.cfilter2(c)
	return c:IsSetCard(0x155) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function c249000392.cost(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingMatchingCard(c249000392.cfilter,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(c249000392.cfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=Duel.GetMatchingGroup(c249000392.cfilter2,tp,LOCATION_GRAVE,0,nil)
	if g1:GetCount() < 3 then
		local g=Duel.SelectMatchingCard(tp,c249000392.cfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function c249000392.matfilter(c)
	return c:IsLevelAbove(1) and c:IsReleasable()
end
function c249000392.matfilter2(c)
	return c:IsLevelAbove(1) and c:IsAbleToRemove()
end
function c249000392.filter(c,e,tp,m)
	if not c:IsType(TYPE_XYZ) or c:GetRank()<5 or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) then return false end
	return m:CheckWithSumGreater(Card.GetLevel,math.floor(c:GetRank()*1.5),c)
end
function c249000392.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(c249000392.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		local exg=Duel.GetMatchingGroup(c249000392.matfilter2,tp,LOCATION_GRAVE,0,nil)
		if Duel.IsExistingMatchingCard(aux.FilterEqualFunction(Card.GetSummonLocation,LOCATION_EXTRA),tp,0,LOCATION_MZONE,1,nil) then
			mg:Merge(exg)
		end
		return Duel.IsExistingMatchingCard(c249000392.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
function c249000392.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(c249000392.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	local exg=Duel.GetMatchingGroup(c249000392.matfilter2,tp,LOCATION_GRAVE,0,nil)
	if Duel.IsExistingMatchingCard(aux.FilterEqualFunction(Card.GetSummonLocation,LOCATION_EXTRA),tp,0,LOCATION_MZONE,1,nil) then
		mg:Merge(exg)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,c249000392.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=tg:GetFirst()
	if tc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local mat=mg:SelectWithSumGreater(tp,Card.GetLevel,math.floor(tc:GetRank()*1.5),tc)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		mat:Sub(mat2)
		if mat and mat:GetCount() > 0 then
			Duel.Release(mat,REASON_EFFECT)
		end
		if mat2 and mat2:GetCount() > 0 then
			Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT)
		end
		Duel.BreakEffect()
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCountLimit(1)
			e1:SetCondition(c249000392.tdcon)
			e1:SetOperation(c249000392.tdop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			tc:RegisterEffect(e1,true)
		end
		Duel.SpecialSummonComplete()
		local tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
		if tc2 then
			Duel.Overlay(tc,tc2)
		end
		tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
		if tc2 then
			Duel.Overlay(tc,tc2)
		end
		tc:CompleteProcedure()
	end
end
function c249000392.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c249000392.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
end
function c249000392.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end