--Risveglio Puntodifuoco
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--extra deck summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(cid.edcon)
	e2:SetTarget(cid.edtg)
	e2:SetOperation(cid.edop)
	c:RegisterEffect(e2)
end
--filters
function cid.matfilter(c)
	return c:IsOnField() and c:IsSetCard(0xb05) and c:IsType(TYPE_MONSTER)
end
function cid.fusionmat(c,e)
	return c:IsOnField() and c:IsSetCard(0xb05) and (not e or not c:IsImmuneToEffect(e))
end
function cid.fusionalt(c)
	return c:IsCanBeFusionMaterial() and c:IsSetCard(0xb05)
end
function cid.edfilter(c,e,tp,m,f,chkf)
	return c:IsSetCard(0xb05) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) 
	and ((c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf))
		or c:IsSpecialSummonable(SUMMON_TYPE_SYNCHRO) or c:IsSpecialSummonable(SUMMON_TYPE_XYZ))
end
--extra deck summon
function cid.edcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function cid.edtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local el={}
		local mg=Duel.GetMatchingGroup(cid.matfilter,tp,LOCATION_MZONE,0,nil)
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,mg)
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			tc:RegisterEffect(e3)
			table.insert(el,e1)
			table.insert(el,e2)
			table.insert(el,e3)
		end
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(cid.fusionmat,nil)
		local res=Duel.IsExistingMatchingCard(cid.edfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp):Filter(cid.fusionalt,nil)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(cid.edfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		for _,e in ipairs(el) do
			e:Reset()
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.edop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local el={}
	local mg=Duel.GetMatchingGroup(cid.matfilter,tp,LOCATION_MZONE,0,nil)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,mg)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(cid.fusionmat,nil,e)
	--prevent illegal materials from being used
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e3)
		table.insert(el,e1)
		table.insert(el,e2)
		table.insert(el,e3)
	end
	--define spsummonable group
	local xg=Duel.GetMatchingGroup(cid.edfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp):Filter(cid.fusionalt,nil)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(cid.edfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	--check available summon types
	local num=1
	local typ,opval={},{}
	if xg:FilterCount(Card.IsType,nil,TYPE_FUSION)>0 or (sg2~=nil and sg2:FilterCount(Card.IsType,nil,TYPE_FUSION)>0) then
		typ[num]=aux.Stringid(id,1)
		opval[num-1]=SUMMON_TYPE_FUSION
		num=num+1
	end
	if xg:IsExists(Card.IsSpecialSummonable,1,nil,SUMMON_TYPE_SYNCHRO) then
		typ[num]=aux.Stringid(id,2)
		opval[num-1]=SUMMON_TYPE_SYNCHRO
		num=num+1
	end
	if xg:IsExists(Card.IsSpecialSummonable,1,nil,SUMMON_TYPE_XYZ) then
		typ[num]=aux.Stringid(id,3)
		opval[num-1]=SUMMON_TYPE_XYZ
		num=num+1
	end
	local op=Duel.SelectOption(tp,table.unpack(typ))
	e:SetLabel(opval[op])
	local lab=e:GetLabel()
	--fusion procedure
	if lab==SUMMON_TYPE_FUSION then
		local sg=xg:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_FUSION)
		local tc=tg:GetFirst()
		if xg:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
	else
	--synchro and xyz procedure
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=xg:FilterSelect(tp,Card.IsSpecialSummonable,1,1,nil,lab):GetFirst()
		if tc then
			Duel.SpecialSummonRule(tp,tc,lab)
		end
	end
	--reset "CANNOT_BE_MATERIAL" effects
	for _,e in ipairs(el) do
		e:Reset()
	end
end