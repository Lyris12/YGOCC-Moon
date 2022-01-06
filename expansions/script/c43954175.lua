--Felgrandrise Fusion
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
--ACTIVATE
function cid.cfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xfe9) or c:IsCode(table.unpack(c43954163.FELGRAND)))
end
function cid.filter1(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
function cid.mfilter3(c)
	return c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:IsCanBeFusionMaterial()
end
function cid.exfilter0(c)
	return cid.cfilter(c) and c:IsCanBeFusionMaterial()
		and c:IsAbleToDeck()
end
function cid.exfilter1(c,e)
	return cid.cfilter(c) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
		and c:IsAbleToDeck()
end
function cid.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function cid.filter2_alt(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (c:IsSetCard(0xfe9) or c:IsCode(table.unpack(c43954163.FELGRAND))) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function cid.fcheck(tp,sg,fc)
	return sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetClassCount(Card.GetCode)==#sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
end
function cid.gcheck(sg)
	return sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetClassCount(Card.GetCode)==#sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
end
-----------
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToGrave,nil)
		if Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_GRAVE,0,1,nil) then
			local sg=Duel.GetMatchingGroup(cid.exfilter0,tp,LOCATION_GRAVE,0,nil)
			if sg:GetCount()>0 then
				mg1:Merge(sg)
				Auxiliary.FCheckAdditional=cid.fcheck
				Auxiliary.GCheckAdditional=cid.gcheck
			end
		end
		local res=Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if res then
			Auxiliary.FCheckAdditional=nil
			Auxiliary.GCheckAdditional=nil
			return true
		end
		local mg2=Duel.GetMatchingGroup(cid.mfilter3,tp,LOCATION_SZONE,0,nil)
		mg2:Merge(mg1)
		res=Duel.IsExistingMatchingCard(cid.filter2_alt,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,nil,chkf)
		Auxiliary.FCheckAdditional=nil
		Auxiliary.GCheckAdditional=nil
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_GRAVE)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(cid.filter1,nil,e)
	local exmat=false
	if Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_GRAVE,0,1,nil) then
		local sg=Duel.GetMatchingGroup(cid.exfilter1,tp,LOCATION_GRAVE,0,nil,e)
		if sg:GetCount()>0 then
			mg1:Merge(sg)
			exmat=true
		end
	end
	local mg2=Duel.GetMatchingGroup(cid.mfilter3,tp,LOCATION_SZONE,0,nil):Filter(cid.filter1,nil,e)
	mg2:Merge(mg1)
	if exmat then
		Auxiliary.FCheckAdditional=cid.fcheck
		Auxiliary.GCheckAdditional=cid.gcheck
	end
	local sg1=Duel.GetMatchingGroup(cid.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local sg2=Duel.GetMatchingGroup(cid.filter2_alt,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,nil,chkf)
	sg2:Merge(sg1)
	Auxiliary.FCheckAdditional=nil
	Auxiliary.GCheckAdditional=nil
	local mg3=nil
	local sg3=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg3=Duel.GetMatchingGroup(cid.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg3~=nil and sg3:GetCount()>0) then
		local sg=sg1:Clone()
		if sg3 then sg:Merge(sg3) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		if sg1:IsContains(tc) and (sg3==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				Auxiliary.FCheckAdditional=cid.fcheck
				Auxiliary.GCheckAdditional=cid.gcheck
			end
			if (tc:IsSetCard(0xfe9) or tc:IsCode(table.unpack(c43954163.FELGRAND))) then
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				Auxiliary.FCheckAdditional=nil
				Auxiliary.GCheckAdditional=nil
				tc:SetMaterial(mat1)
				local rg=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
				mat1:Sub(rg)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.SendtoDeck(rg,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			else
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				Auxiliary.FCheckAdditional=nil
				Auxiliary.GCheckAdditional=nil
				tc:SetMaterial(mat1)
				local rg=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
				mat1:Sub(rg)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.SendtoDeck(rg,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			end
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end