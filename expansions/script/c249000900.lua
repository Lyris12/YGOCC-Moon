--Transcending Fusion
function c249000900.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c249000900.cost)
	e1:SetTarget(c249000900.target)
	e1:SetOperation(c249000900.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_DECK+LOCATION_GRAVE)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetValue(24094653)
	c:RegisterEffect(e2)
end
function c249000900.costfilter(c)
	return c:IsSetCard(0x4046) and c:IsAbleToRemoveAsCost()
end
function c249000900.costfilter2(c)
	return c:IsSetCard(0x4046) and not c:IsPublic()
end
function c249000900.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000900.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000900.costfilter2,tp,LOCATION_HAND,0,1,c)) end
	local option
	if Duel.IsExistingMatchingCard(c249000900.costfilter2,tp,LOCATION_HAND,0,1,c)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000900.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000900.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000900.costfilter2,tp,LOCATION_HAND,0,1,c) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000900.costfilter2,tp,LOCATION_HAND,0,1,1,c)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000900.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000900.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function c249000900.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:GetTextAttack() < 3500 and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,true) and c:CheckFusionMaterial(m,nil,chkf,false)
end
function c249000900.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		local res=Duel.IsExistingMatchingCard(c249000900.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c249000900.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000900.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c249000900.filter1,nil,e)
	local sg1=Duel.GetMatchingGroup(c249000900.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c249000900.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,true,true,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
			if tc:IsLocation(LOCATION_EXTRA) then
				tc:SetMaterial(mat2)
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,true,true,POS_FACEUP)
			end
		end
		tc:CompleteProcedure()
	end
end
