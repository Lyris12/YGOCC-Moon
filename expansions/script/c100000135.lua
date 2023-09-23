--Vyasa-Purana
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,9,s.TLcon,{s.TLfilter,true})
	c:EnableReviveLimit()
	--[[(Quick Effect): You can banish this Time Leap Summoned card; Special Summon 2 monsters that are banished, or in the GYs, with different card types from each other
	(Fusion, Synchro, Xyz, Link, Bigbang, Time Leap), except "Vyasa-Purana", then roll a six-sided die, and if you do, until the end of the next turn, you can apply the following effect.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,s.cost,s.target,s.operation)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true		
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD)
		ge2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_IGNORE_RANGE)
		ge2:SetCode(EFFECT_MATERIAL_CHECK)
		ge2:SetValue(s.valcheck)
		Duel.RegisterEffect(ge2,0)
	end
end
s.toss_dice=true

function s.TLcon(e,c,tp)
	return Duel.GetFlagEffect(0,id)>=2
end
function s.TLfilter(c,e,mg)
	local tc=e:GetHandler()
	return c:IsLevel(tc:GetFuture()-1)
		or (c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:HasFlagEffect(id))
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		if tc:IsSummonLocation(LOCATION_EXTRA) then
			Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g and g:IsExists(s.cfilter,1,nil) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_TOFIELD,0,1)
	end
end
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end

--E1
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsMonster(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_BIGBANG|TYPE_TIMELEAP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.gcheck(g)
	return g:GetClassCount(s.classfunction)==#g
end
function s.classfunction(c)
	return c:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_BIGBANG|TYPE_TIMELEAP)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsTimeleapSummoned() and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>=2
	end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.Group(s.spfilter,tp,LOCATION_GB,LOCATION_GB,nil,e,tp)
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>=2) and #g>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and g:CheckSubGroup(s.gcheck,2,2,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_GB)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.Group(aux.Necro(s.spfilter),tp,LOCATION_GB,LOCATION_GB,nil,e,tp)
	if #g<2 then return end
	Duel.HintMessage(tp,HINTMSG_SPSUMMON)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		local d=Duel.TossDice(tp,1)
		local cat=(d==1) and CATEGORIES_FUSION_SUMMON or CATEGORY_SPECIAL_SUMMON
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,d))
		e1:SetCategory(cat)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetLabel(d)
		e1:SetRelevantTimings()
		e1:SetFunctions(nil,s.spcost,s.sptg,s.spop)
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.vyasapurana(c,e,tp,d)
	if not (c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if d==1 then
		return Duel.IsExists(false,s.fusfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,c)
	elseif d==2 then
		return Duel.IsExists(false,s.synfilter,tp,LOCATION_EXTRA,0,1,c,tp,c)
	elseif d==3 then
		return Duel.IsExists(false,s.xyzfilter,tp,LOCATION_EXTRA,0,1,c,tp,c)
	elseif d==4 then
		return Duel.IsExists(false,s.lnkfilter,tp,LOCATION_EXTRA,0,1,c,tp,c)
	elseif d==5 then
		return Duel.IsExists(false,s.bbgfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,c)
	elseif d==6 then
		return Duel.IsExists(false,s.tmlfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,c)
	end
end
function s.fusfilter(c,e,tp,mc)
	if not (c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	local chkf=tp
	local m=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	if mc then
		m:AddCard(mc)
	end
	local res=c:CheckFusionMaterial(m,nil,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=mf(c) and c:CheckFusionMaterial(mg2,nil,chkf)
		end
	end
	return res
end
function s.synfilter(c,tp,mc)
	if mc then
		local mg=aux.GetSynMaterials(tp,c)
		mg:AddCard(mc)
		return c:IsSynchroSummonable(nil,mg)
	else
		return c:IsSynchroSummonable(nil)
	end
end
function s.xyzfilter(c,tp,mc)
	if mc then
		local mg=Duel.GetMatchingGroup(aux.XyzLevelFreeFilter,tp,LOCATION_MZONE,0,nil,c)
		mg:AddCard(mc)
		return c:IsXyzSummonable(mg)
	else
		return c:IsXyzSummonable(nil)
	end
	return false
end
function s.lnkfilter(c,tp,mc)
	if mc then
		local res=false
		local eset=c:GetEffects()
		for i,ce in ipairs(eset) do
			if ce and not ce:WasReset(c) then
				if ce:GetCode()==EFFECT_SPSUMMON_PROC then
					local sumtyp=0
					local val=ce:GetValue()
					if type(val)=="function" then
						sumtyp=val(ce,c)
					else
						sumtyp=val
					end
					if sumtyp==SUMMON_TYPE_LINK then
						local mg=Auxiliary.GetLinkMaterials(tp,nil,c,ce)
						mg:AddCard(mc)
						if c:IsLinkSummonable(mg) then
							res=true
							break
						end
					end
				end
			else
				aux.MarkResettedEffect(c,i)
			end
		end
		aux.DeleteResettedEffects(c)
		return res
	else
		return c:IsLinkSummonable(nil)
	end
	return false
end
function s.bbgfilter(c,e,tp,mc)
	local mg=Duel.GetMatchingGroup(Card.IsCanBeBigbangMaterial,tp,LOCATION_MZONE,0,nil,c)
	local mg2=Duel.GetMatchingGroup(Auxiliary.BigbangExtraFilter,tp,0xff,0xff,nil,c,tp)
	mg:Merge(mg2)
	if mc then
		mg:AddCard(mc)
	end
	if not c:IsType(TYPE_BIGBANG) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false) or Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	local res=false
	local eset=c:GetEffects()
	for i,ce in ipairs(eset) do
		if ce and not ce:WasReset(c) then
			if ce:GetCode()==EFFECT_SPSUMMON_PROC then
				local ev=ce:GetValue()
				local ec=ce:GetCondition()
				if ev and (aux.GetValueType(ev)=="function" and ev(ce,c)&340==340 or ev&340==340) and (not ec or ec(ce,c,mg,nil)) then return true end
			end
		else
			aux.MarkResettedEffect(c,i)
		end
	end
	aux.DeleteResettedEffects(c)
	return res
end
function s.tmlfilter(c,e,tp,mc)
	local mg=Duel.GetMatchingGroup(Card.IsCanBeTimeleapMaterial,tp,LOCATION_MZONE,0,nil,c):Filter(Card.IsFaceup,nil)
	local mg2=Duel.GetMatchingGroup(Auxiliary.TimeleapExtraFilter,tp,0xff,0xff,nil,nil,c,tp)
	mg:Merge(mg2)
	if mc then
		mg:AddCard(mc)
	end
	if not c:IsType(TYPE_TIMELEAP) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_TIMELEAP,tp,false,false) or Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	local res=false
	local eset=c:GetEffects()
	for i,ce in ipairs(eset) do
		if ce and not ce:WasReset(c) then
			if ce:GetCode()==EFFECT_SPSUMMON_PROC then
				local ev=ce:Evaluate(c)
				local ec=ce:GetCondition()
				if ev and ev&SUMMON_TYPE_TIMELEAP==SUMMON_TYPE_TIMELEAP and (not ec or ec(ce,c,mg)) then
					return true
				end
			end
		else
			aux.MarkResettedEffect(c,i)
		end
	end
	aux.DeleteResettedEffects(c)
	return res
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:HasFlagEffect(id+100) or Duel.GetMZoneCount(tp)<=0 or not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return false end
		local d=e:GetLabel()
		return Duel.IsExists(false,s.vyasapurana,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp,d)
	end
	c:RegisterFlagEffect(id+100,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_EXTRA|LOCATION_REMOVED)
	Duel.SetAdditionalOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetAdditionalOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=e:GetLabel()
	
	local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.vyasapurana,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp,d)
	if #sg>0 and Duel.SpecialSummon(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP)>0 then
	
		if d==1 then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			if #g>0 then
				local tc=g:GetFirst()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
				e1:SetCode(EFFECT_SPSUMMON_PROC)
				e1:SetRange(LOCATION_EXTRA)
				e1:SetValue(SUMMON_TYPE_FUSION)
				e1:SetOperation(function(E,TP,EG,EP,EV,RE,R,RP,C)
					s.fusop(e,tp,eg,ep,ev,re,r,rp,C)
				end
				)
				tc:RegisterEffect(e1,true)
				Duel.SpecialSummonRule(tp,tc,SUMMON_TYPE_FUSION)
				if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
			end
		
		elseif d==2 then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
			if #g>0 then
				local tc=g:GetFirst()
				Duel.SynchroSummon(tp,tc,nil)
			end
		
		elseif d==3 then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
			if #g>0 then
				local tc=g:GetFirst()
				Duel.XyzSummon(tp,tc,nil)
			end
		
		elseif d==4 then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.lnkfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
			if #g>0 then
				local tc=g:GetFirst()
				Duel.LinkSummon(tp,tc,nil)
			end
		
		elseif d==5 then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.bbgfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			if #g>0 then
				local tc=g:GetFirst()
				Duel.SpecialSummonRule(tp,tc,340)
				if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
			end
		
		elseif d==6 then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.tmlfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			if #g>0 then
				local tc=g:GetFirst()
				Duel.SpecialSummonRule(tp,tc,SUMMON_TYPE_TIMELEAP)
				if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
			end
		end
	end
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp,c)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	local sg1=c:CheckFusionMaterial(mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=c:CheckFusionMaterial(mg2,nil,chkf)
	end
	if sg1 or sg2 then
		local check=false
		if sg1 and (not sg2 or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,c,mg1,nil,chkf)
			c:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_MATERIAL|REASON_FUSION)
		else
			local mat2=Duel.SelectFusionMaterial(tp,c,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,c,mat2)
		end
		c:CompleteProcedure()
	end
	e:Reset()
end