--Absolute Chaos Ritual
function c249000905.initial_effect(c)
	if aux.AddXyzProcedure then
		if not c249000905_AddXyzProcedure then
			c249000905_AddXyzProcedure=aux.AddXyzProcedure
			aux.AddXyzProcedure = function (c,f,lv,ct,alterf,desc,maxct,op)
				local code=c:GetOriginalCode()
				local mt=_G["c" .. code]
				mt.xyz_minct=ct
				if maxct then mt.xyz_maxct=maxct else mt.xyz_maxct=ct end
				if f then mt.xyz_filter=f end
				c249000905_AddXyzProcedure(c,f,lv,ct,alterf,desc,maxct,op)
			end
		end
	end
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c249000905.cost)
	e1:SetTarget(c249000905.target)
	e1:SetOperation(c249000905.activate)
	c:RegisterEffect(e1)
	--xyz
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c249000905.target2)
	e2:SetOperation(c249000905.operation2)
	c:RegisterEffect(e2)
end
function c249000905.cfilter(c)
	return (c:IsSetCard(0xcf) or c:IsSetCard(0x1048) or c:IsSetCard(0x1073)) and not c:IsPublic()
end
function c249000905.cfilter2(c)
	return c:IsSetCard(0xcf) or c:IsSetCard(0x1048) or c:IsSetCard(0x1073)
end
function c249000905.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000905.cfilter,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(c249000905.cfilter2,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=Duel.GetMatchingGroup(c249000905.cfilter2,tp,LOCATION_GRAVE,0,nil)
	if g1:GetCount() < 3 then
		local g=Duel.SelectMatchingCard(tp,c249000905.cfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function c249000905.filter(c,e,tp,m1,m2,ft)
	if not c:IsType(TYPE_MONSTER) or not c:IsSetCard(0xcf) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	mg:Merge(m2)
	if ft>0 then
		return mg:CheckWithSumGreater(Card.GetRitualLevel,c:GetLevel(),c)
	else
		return ft>-1 and mg:IsExists(c249000905.mfilterf,1,nil,tp,mg,c)
	end
end
function c249000905.mfilterf(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
		Duel.SetSelectedCard(c)
		return mg:CheckWithSumGreater(Card.GetRitualLevel,rc:GetLevel(),rc)
	else return false end
end
function c249000905.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
function c249000905.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg1=Duel.GetRitualMaterial(tp)
		local mg2=Duel.GetMatchingGroup(c249000905.mfilter,tp,LOCATION_GRAVE,0,nil)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(c249000905.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,mg1,mg2,ft)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
function c249000905.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg1=Duel.GetRitualMaterial(tp)
	local mg2=Duel.GetMatchingGroup(c249000905.mfilter,tp,LOCATION_GRAVE,0,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000905.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,mg1,mg2,ft)
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		local mat=nil
		if ft>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetLevel(),tc)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:FilterSelect(tp,c249000905.mfilterf,1,1,nil,tp,mg,tc)
			Duel.SetSelectedCard(mat)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local mat2=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetLevel(),tc)
			mat:Merge(mat2)
		end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
		if not tc:IsType(TYPE_RITUAL) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetValue(TYPE_RITUAL)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e1)
		end
	end
end
function c249000905.filter2(c)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xcf) or c:IsSetCard(0x1048) or c:IsSetCard(0x1073)) and c:GetLevel() > 0
end
function c249000905.xyzfilter(c,mg)
	local code=c:GetOriginalCode()
	local mt=_G["c" .. code]
	return (mt.xyz_minct==2 or mt.xyz_minct==3) and c:IsXyzSummonable(mg) and c:IsSetCard(0x48)
end
function c249000905.mfilter1(c,exg)
	return exg:IsExists(c249000905.mfilter2,1,nil,c)
end
function c249000905.mfilter2(c,mc)
	local code=mc:GetOriginalCode()
	local mt=_G["c" .. code]
	return (not mt.xyz_filter or mt.xyz_filter(c)) and c:IsType(TYPE_MONSTER) and c:GetLevel()==mc:GetRank() and (c:IsSetCard(0xcf) or c:IsSetCard(0x1048) or c:IsSetCard(0x1073))
end
function c249000905.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(c249000905.filter2,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and mg:GetCount()>1
		and Duel.IsExistingMatchingCard(c249000905.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg) end
end
function c249000905.operation2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local mg=Duel.GetMatchingGroup(c249000905.filter2,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil,e,tp)
	local exg=Duel.GetMatchingGroup(c249000905.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if exg:GetCount() < 1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=exg:Select(tp,1,1,nil):GetFirst()
	local maxct
	local code=xyz:GetOriginalCode()
	local mt=_G["c" .. code]
	if mt.xyz_minct==2 then maxct=2 else maxct=3 end
	local g=Duel.SelectMatchingCard(tp,c249000905.mfilter2,tp,LOCATION_GRAVE+LOCATION_MZONE,0,mt.xyz_minct,maxct,nil,xyz)
	Duel.XyzSummon(tp,xyz,g)
end