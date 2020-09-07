--created & coded by Lyris
--フェイト・ヒーロー希望のダスクガイ
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunFunRep(c,cid.mfilter1,cid.mfilter2,2,2,false,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(cid.indct)
	e2:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.mfilter1(c,fc,sub,mg,sg)
	return c:IsLevelAbove(5) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:Filter(Card.IsLevelAbove,c,1):CheckWithSumGreater(Card.GetLevel,fc:GetLevel()-c:GetLevel()))
end
function cid.mfilter2(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0xf7a) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:Filter(Card.IsLevelAbove,c,1):CheckWithSumGreater(Card.GetLevel,fc:GetLevel()-c:GetLevel()))
end
function cid.indct(e,re,r,rp)
	if r&REASON_BATTLE+REASON_EFFECT~=0 then
		e:Reset()
		return 1
	else return 0 end
end
function cid.spfilter0(c)
	return c:IsLocation(LOCATION_HAND) and c:IsAbleToRemove()
end
function cid.spfilter1(c,e)
	return c:IsLocation(LOCATION_HAND) and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function cid.fcheck(tp,sg,fc)
	return sg:Filter(Card.IsLevelAbove,nil,1):CheckWithSumGreater(Card.GetLevel,fc:GetLevel())
end
function cid.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function cid.spfilter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(cid.spfilter0,nil)+Duel.GetMatchingGroup(cid.spfilter3,tp,LOCATION_GRAVE,0,1,nil)
		local res=Duel.IsExistingMatchingCard(cid.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(cid.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(cid.spfilter1,nil,e)+Duel.GetMatchingGroup(cid.spfilter3,tp,LOCATION_GRAVE,0,1,nil)
	local sg1=Duel.GetMatchingGroup(cid.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(cid.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		aux.FCheckAdditional=cid.fcheck
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	aux.FCheckAdditional=nil
end
