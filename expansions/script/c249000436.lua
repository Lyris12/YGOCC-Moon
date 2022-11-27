--Heterochromic Mysterious Fuser
xpcall(function() require("expansions/script/bannedlist") end,function() require("script/bannedlist") end)
function c249000436.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(511)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,249000436)
	e1:SetCondition(c249000436.spcon)
	e1:SetTarget(c249000436.sptg)
	e1:SetOperation(c249000436.spop)
	c:RegisterEffect(e1)
	--special summon create
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1191)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,249000436)
	e2:SetCost(c249000436.cost)
	e2:SetTarget(c249000436.target)
	e2:SetOperation(c249000436.operation)
	c:RegisterEffect(e2)
end
function c249000436.confilter(c)
	return c:IsSetCard(0x1BE) and not c:IsCode(249000436)
end
function c249000436.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249000436.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
function c249000436.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
function c249000436.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function c249000436.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c249000436.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
function c249000436.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(c249000436.filter0,nil)
		local mg2=Duel.GetMatchingGroup(c249000436.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		local res=Duel.IsExistingMatchingCard(c249000436.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c249000436.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000436.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c249000436.filter1,nil,e)
	local mg2=Duel.GetMatchingGroup(c249000436.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	local sg1=Duel.GetMatchingGroup(c249000436.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c249000436.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
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
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
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
function c249000436.costfilter(c)
	return c:IsSetCard(0x1BE) and c:IsAbleToRemoveAsCost()
end
function c249000436.costfilter2(c,e)
	return c:IsSetCard(0x1BE) and not c:IsPublic()
end
function c249000436.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000436.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000436.costfilter2,tp,LOCATION_HAND,0,1,nil,e)) end
	local option
	if Duel.IsExistingMatchingCard(c249000436.costfilter2,tp,LOCATION_HAND,0,1,nil,e)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000436.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000436.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000436.costfilter2,tp,LOCATION_HAND,0,1,nil,e) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000436.costfilter2,tp,LOCATION_HAND,0,1,1,nil,e)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000436.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000436.mfilter1(c,e)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e) and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
end
function c249000436.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(c249000436.mfilter1,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function c249000436.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		g=Duel.SelectMatchingCard(tp,c249000436.mfilter1,tp,LOCATION_MZONE,0,1,1,nil,e)
	else
		g=Duel.SelectMatchingCard(tp,c249000436.mfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e)
	end
	if g:GetCount() < 1 then return end
	local tc=g:GetFirst()
	local key
	local value
	local ac
	local cc
	local material_table={}
	local i=1
	repeat
		ac=Duel.AnnounceCardFilter(tp,TYPE_FUSION,OPCODE_ISTYPE,249000436,OPCODE_ISCODE,OPCODE_OR)
		if ac==249000436 then return end
		cc=Duel.CreateToken(tp,ac)
		material_table={}
		for key,value in pairs(cc.material) do
			material_table[i]=key
			i=i+1
		end
	until (cc.material and material_table and tc:IsCode(table.unpack(material_table)) and cc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) and not banned_list_table[ac]
	Duel.SendtoGrave(tc,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	cc:SetMaterial(Group.FromCards(tc))
	Duel.SpecialSummon(cc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	cc:CompleteProcedure()
	if cc:GetBaseAttack() >= 2800 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(c249000436.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function c249000436.damval(e,re,val,r,rp,rc)
	return val/2
end