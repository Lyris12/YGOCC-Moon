--Yobissekai Summoner
function c249001279.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c249001279.cost)
	e1:SetTarget(c249001279.target)
	e1:SetOperation(c249001279.operation)
	c:RegisterEffect(e1)
	--special summon self
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c249001279.spcon)
	c:RegisterEffect(e2)
end
function c249001279.cfilter(c)
	return c:IsSetCard(0x238) and not c:IsPublic()
end
function c249001279.cfilter2(c)
	return c:IsSetCard(0x238) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function c249001279.cost(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingMatchingCard(c249001279.cfilter,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(c249001279.cfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=Duel.GetMatchingGroup(c249001279.cfilter2,tp,LOCATION_GRAVE,0,nil)
	if g1:GetCount() < 3 then
		local g=Duel.SelectMatchingCard(tp,c249001279.cfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function c249001279.matfilter(c)
	return c:IsLevelAbove(1) and c:IsReleasable()
end
function c249001279.matfilter2(c)
	return c:IsLevelAbove(1) and c:IsAbleToRemove()
end
function c249001279.racefilter(c,race)
	return c:IsRace(race) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE+LOCATION_REMOVED))
end
function c249001279.filter(c,e,tp,m)
	if not c:IsSetCard(0x3238) or not c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		or not Duel.IsExistingMatchingCard(c249001275.racefilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c:GetRace()) then return false end
	return m:CheckWithSumGreater(Card.GetLevel,c:GetLevel(),c)
end
function c249001279.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
function c249001279.operation(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.AnnounceCardFilter(tp,0x3238,OPCODE_ISSETCARD,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ,OPCODE_ISTYPE,OPCODE_AND)
	local token=Duel.CreateToken(tp,ac)
	Duel.SendtoDeck(token,tp,SEQ_DECKSHUFFLE,REASON_RULE)
	local mg=Duel.GetMatchingGroup(c249001275.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,e:GetHandler())
	local exg=Duel.GetMatchingGroup(c249001275.matfilter2,tp,LOCATION_GRAVE,0,nil)
	if Duel.IsExistingMatchingCard(aux.FilterEqualFunction(Card.GetSummonLocation,LOCATION_EXTRA),tp,0,LOCATION_MZONE,1,nil) then
		mg:Merge(exg)
	end
	local g=Duel.GetMatchingGroup(c249001275.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
	if g:GetCount()==0 or not Duel.SelectYesNo(tp,2) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,c249001275.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=tg:GetFirst()
	if tc then
		local rg=Duel.GetMatchingGroup(c249001275.racefilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,tc:GetRace())
		if not rg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE+LOCATION_REMOVED) then
			local confirm = rg:Select(tp,1,1,nil):GetFirst()
			Duel.ConfirmCards(1-tp,confirm)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local mat=mg:SelectWithSumGreater(tp,Card.GetLevel,tc:GetLevel(),tc)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		mat:Sub(mat2)
		if mat and mat:GetCount() > 0 then
			Duel.Release(mat,REASON_EFFECT)
		end
		if mat2 and mat2:GetCount() > 0 then
			Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT)
		end
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function c249001279.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end