--created by Jake, coded by XGlitchy30
--Bond Between Dawn
if not global_override_reason_effect_check then
	global_override_reason_effect_check = true
end
local s,id=GetID()
s.original_category={}
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetLabel(0)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	s.original_category[e1]=e1:GetCategory()
end
s.dawn_blader_monster_in_text = true
s.scapetoken = nil
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsFusionSetCard(0x613) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_WARRIOR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and (not c:IsRace(RACE_WARRIOR) or c:IsFacedown())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ogcat = type(s.original_category[e])~="nil" and s.original_category[e] or 0
	e:SetCategory(ogcat)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil) then
			local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
			mg1:Merge(mg2)
		end
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	e:SetLabel(0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		if Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil) then
			e:SetCategory(ogcat+CATEGORY_DECKDES)
			e:SetLabel(1)
		end
		if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0) then
			e:SetLabel(e:GetLabel()+2)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	if e:GetLabel()&1==1 then
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
	end
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
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
			if Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)>0 and e:GetLabel()&2==2 then
				local og=Duel.GetOperatedGroup()
				if #og>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					Duel.HintMessage(tp,HINTMSG_DISCARD)
					local dg=og:Select(tp,1,#og,nil)
					if #dg>0 then
						local c=e:GetHandler()
						Duel.HintSelection(dg)
						if not s.scapetoken then
							local token=Duel.CreateToken(tp,UNIVERSAL_GLITCHY_TOKEN)
							token:SetStatus(STATUS_NO_LEVEL,true)
							s.scapetoken=token
						end
						s.scapetoken:Recreate(id,0,0x613,(s.scapetoken:GetType()&~TYPE_NORMAL)|c:GetType(),0,0,0,0)
						s.scapetoken:RegisterEffect(fake_re,true)
						local fake_re=e:Clone()
						fake_re:SetCheatCode(GECC_OVERRIDE_ACTIVE_TYPE)
						e:SetCheatCode(GECC_OVERRIDE_REASON_EFFECT,true)
						e:SetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT,fake_re)
						for tc in aux.Next(dg) do
							if not tc:IsReason(REASON_DISCARD) then
								tc:SetReason(tc:GetReason()|REASON_DISCARD)
							end
							Duel.RaiseSingleEvent(tc,EVENT_DISCARD,fake_re,REASON_EFFECT+REASON_DISCARD+REASON_MATERIAL+REASON_FUSION,tp,tp,0)
						end
						Duel.RaiseEvent(dg,EVENT_DISCARD,fake_re,REASON_EFFECT+REASON_DISCARD+REASON_MATERIAL+REASON_FUSION,tp,tp,0)
					end
				end
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
