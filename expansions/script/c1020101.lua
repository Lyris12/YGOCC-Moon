--Galactic Code Upgrade
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(function(e,tp,blah,blah,card,games,waaa,dodalalalalala,chk) if chk==0 then return Duel.CheckLPCost(tp,1000) end Duel.PayLPCost(tp,1000) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.mfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
function s.mfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
function s.spfilter1(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and c:IsSetCard(0xded) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.spfilter3(c,e,tp,m,f,chkf)
	return s.spfilter2(c,e,tp,m,f,chkf) and m:IsExists(s.mfilter1,1,nil)
end
function s.spfilter4(c,e,tp,m,f,chkf)
	return s.spfilter2(c,e,tp,m,f,chkf) and m:IsExists(s.mfilter2,1,nil)
end
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		local res=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if res then return true end
		local t={Duel.GetMatchingGroup(s.mfilter1,tp,LOCATION_DECK,0,nil),Duel.GetMatchingGroup(s.mfilter2,tp,LOCATION_GRAVE,0,nil)}
		for k,bool in pairs({Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil),Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE,nil)~=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)}) do
			local mg2=Group.CreateGroup()
			local mg3=bool and t[k] or Group.CreateGroup()
			mg2:Merge(mg1)
			mg2:Merge(mg3)
			res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,nil,chkf)
			if not res then
				local ce=Duel.GetChainMaterial(tp)
				if ce~=nil then
					local fgroup=ce:GetTarget()
					local mg4=fgroup(ce,e,tp)
					local mf=ce:GetValue()
					res=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg4,mf,chkf)
				end
			end
			if res then return true end
		end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	local m1=Group.CreateGroup()
	m1:Merge(mg1)
	m1:Merge(Duel.GetMatchingGroup(s.mfilter1,tp,LOCATION_DECK,0,nil))
	local a=Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,m1,nil,chkf)
	local m2=Group.CreateGroup()
	m2:Merge(mg1)
	m2:Merge(Duel.GetMatchingGroup(s.mfilter2,tp,LOCATION_GRAVE,0,nil))
	local b=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE,nil)~=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil) and Duel.IsExistingMatchingCard(s.spfilter4,tp,LOCATION_EXTRA,0,1,nil,e,tp,m2,nil,chkf)
	local op=-1
	if a and b then
		if Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf) then
			op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		end
	else
		op=(a and 0) or (b and 1) or 2
	end
	if op==0 then
		mg2=Duel.GetMatchingGroup(s.mfilter1,tp,LOCATION_DECK,0,nil)
	elseif op==1 then
		mg2=Duel.GetMatchingGroup(s.mfilter2,tp,LOCATION_GRAVE,0,nil)
	elseif op==2 then
		mg2=Group.CreateGroup()
	end
	mg1:Merge(mg2)
	local spf=#mg1==Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e) and s.spfilter1 or s.spfilter2
	local sg1=Duel.GetMatchingGroup(spf,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
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
			local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			mat1:Sub(mat2)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
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
