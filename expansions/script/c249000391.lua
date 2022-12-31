--Overlay Ritualist Ritual
function c249000391.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c249000391.cost)
	e1:SetTarget(c249000391.target)
	e1:SetOperation(c249000391.operation)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21893603,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,249000391)
	e2:SetCost(c249000391.thcost)
	e2:SetTarget(c249000391.thtg)
	e2:SetOperation(c249000391.thop)
	c:RegisterEffect(e2)
end
function c249000391.cfilter(c)
	return c:IsSetCard(0x231) and not c:IsPublic()
end
function c249000391.cfilter2(c)
	return c:IsSetCard(0x231) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function c249000391.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000391.cfilter,tp,LOCATION_HAND,0,1,c) or Duel.IsExistingMatchingCard(c249000391.cfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=Duel.GetMatchingGroup(c249000391.cfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g1:GetCount() < 3 then
		local g=Duel.SelectMatchingCard(tp,c249000391.cfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function c249000391.matfilter(c)
	return c:IsLevelAbove(1) and c:IsReleasable()
end
function c249000391.matfilter2(c)
	return c:IsLevelAbove(1) and c:IsAbleToRemove()
end
function c249000391.racefilter(c,race)
	return c:IsRace(race) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE+LOCATION_REMOVED))
end
function c249000391.filter(c,e,tp,m)
	if not c:IsType(TYPE_XYZ) or c:GetRank()<5 or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		or not Duel.IsExistingMatchingCard(c249000391.racefilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c:GetRace()) then return false end
	return m:CheckWithSumGreater(Card.GetLevel,math.floor(c:GetRank()*1.5),c)
end
function c249000391.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(c249000391.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		local exg=Duel.GetMatchingGroup(c249000391.matfilter2,tp,LOCATION_GRAVE,0,nil)
		if Duel.IsExistingMatchingCard(aux.FilterEqualFunction(Card.GetSummonLocation,LOCATION_EXTRA),tp,0,LOCATION_MZONE,1,nil) then
			mg:Merge(exg)
		end
		return Duel.IsExistingMatchingCard(c249000391.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
function c249000391.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(c249000391.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	local exg=Duel.GetMatchingGroup(c249000391.matfilter2,tp,LOCATION_GRAVE,0,nil)
	if Duel.IsExistingMatchingCard(aux.FilterEqualFunction(Card.GetSummonLocation,LOCATION_EXTRA),tp,0,LOCATION_MZONE,1,nil) then
		mg:Merge(exg)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,c249000391.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=tg:GetFirst()
	if tc then
		local rg=Duel.GetMatchingGroup(c249000391.racefilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,tc:GetRace())
		if not rg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE+LOCATION_REMOVED) then
			local confirm = rg:Select(tp,1,1,nil):GetFirst()
			Duel.ConfirmCards(1-tp,confirm)
		end
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
			e1:SetCondition(c249000391.tdcon)
			e1:SetOperation(c249000391.tdop)
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
function c249000391.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c249000391.tdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then Duel.Draw(tp,2,REASON_EFFECT) end
end
function c249000391.thcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and c:IsSetCard(0x231)
end
function c249000391.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000391.thcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c249000391.thcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c249000391.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function c249000391.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end