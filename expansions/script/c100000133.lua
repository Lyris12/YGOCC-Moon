--MMS - Fusion
--MMS - Fusione
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Discard 1 card; apply 1 of the following effects, but you cannot apply the other effect of "MMS - Fusion" for the rest of the Duel.
	● Fusion Summon 1 "MMS -" Fusion Monster from your Extra Deck, by banishing Fusion Materials mentioned on it from your hand, field, and/or Deck.
	● Fusion Summon 1 "MMS -" Fusion Monster from your Extra Deck, using monsters from either field as Fusion Material.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_FUSION_SUMMON|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(nil,s.cost,s.target(nil),s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(ARCHE_MMS)
end
--Cost Functions
function s.dcfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsDiscardable() then return false end
	return s.target(c)(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return (not e:IsHasType(EFFECT_TYPE_ACTIVATE) or Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0)
		and Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
	Duel.DiscardHand(tp,s.dcfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE|PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterHint(tp,id+1,PHASE_END,1,id,3)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(ARCHE_MMS)
end
--Fusion filters
function s.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function s.filter_field(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
function s.filter_oppofield(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m1,m2,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsSetCard(ARCHE_MMS) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	if m1 and m2 then
		return (not Duel.PlayerHasFlagEffectLabel(tp,id,1) and c:CheckFusionMaterial(m1,nil,chkf)) or (not Duel.PlayerHasFlagEffectLabel(tp,id,0) and c:CheckFusionMaterial(m2,nil,chkf))
	elseif m1 and m2==nil then
		return c:CheckFusionMaterial(m1,nil,chkf)
	end
	return false
end
function s.filter3(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
--Target Function
function s.target(exc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					if e:IsCostChecked() and not exc then return true end
					local chkf=tp
					
					local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,exc,e)
					local mg12=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_DECK,0,exc,e)
					mg1:Merge(mg12)
					
					local mg2=Duel.GetFusionMaterial(tp):Filter(s.filter_field,exc,e)
					local mg22=Duel.GetMatchingGroup(s.filter_oppofield,tp,0,LOCATION_MZONE,exc,e)
					mg2:Merge(mg22)
					
					local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,mg2,nil,chkf)
					if not res then
						local ce=Duel.GetChainMaterial(tp)
						if ce~=nil then
							local fgroup=ce:GetTarget()
							local mg3=fgroup(ce,e,tp)
							local mf=ce:GetValue()
							res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,nil,mf,chkf)
						end
					end
					return res
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
				Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_DECK)
			end
end
--Operation Function
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	local mg12=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_DECK,0,nil,e)
	mg1:Merge(mg12)
	
	local mg2=Duel.GetFusionMaterial(tp):Filter(s.filter_field,exc,e)
	local mg22=Duel.GetMatchingGroup(s.filter_oppofield,tp,0,LOCATION_MZONE,exc,e)
	mg2:Merge(mg22)
	
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,mg2,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,nil,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local b1 = (not Duel.PlayerHasFlagEffectLabel(tp,id,1) and #mg1>0 and tc:CheckFusionMaterial(mg1,nil,chkf))
			local b2 = (not Duel.PlayerHasFlagEffectLabel(tp,id,0) and #mg2>0 and tc:CheckFusionMaterial(mg2,nil,chkf))
			local opt=aux.Option(tp,id,1,b1,b2)
			if not Duel.PlayerHasFlagEffectLabel(tp,id,opt) then
				Duel.RegisterFlagEffect(tp,id,0,0,1,opt)
			end
			local matg = opt==0 and mg1 or mg2
			local mat1=Duel.SelectFusionMaterial(tp,tc,matg,nil,chkf)
			tc:SetMaterial(mat1)
			if opt==0 then
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
			else
				Duel.SendtoGrave(mat1,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
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