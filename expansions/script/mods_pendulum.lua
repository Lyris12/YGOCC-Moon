function Auxiliary.EnablePendulumMod(mod)
	if not aux.EnabledPendulumMods then
		aux.EnabledPendulumMods={}
	end
	if mod then
		aux.EnabledPendulumMods[mod]=true
	end
end

EFFECT_PENDULUM_SUMMON_WITH_ONE_SCALE	= 100000060

function Auxiliary.PandePendScale(c,seq)
	return Auxiliary.PaCheckFilter(c) and c:IsHasEffect(EFFECT_PANDEPEND_SCALE) and c:GetSequence()==math.abs(4-seq)
end

local _PendCondition, _PConditionFilter, _PendOperation = aux.PendCondition, aux.PConditionFilter, aux.PendOperation

Auxiliary.PendCondition = function(e,c,og)
	if not aux.EnabledPendulumMods then
		return _PendCondition(e,c,og)
	else
		if c==nil then return true end
		local tp=c:GetControler()
		local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
		if Auxiliary.PendulumChecklist&(0x1<<tp)~=0 and #eset==0 then return false end
		
		local lpz,rpz = Duel.GetFieldCard(tp,LOCATION_PZONE,0),Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		
		if aux.EnabledPendulumMods[EFFECT_PANDEPEND_SCALE] then
			local pande=Duel.GetMatchingGroup(Auxiliary.PandePendScale,tp,LOCATION_SZONE,0,c,c:GetSequence()):GetFirst()
			if pande then
				if c==lpz then
					rpz=pande
				else
					lpz=pande
				end
			end
		end
		
		local scales=Group.CreateGroup()
		if lpz then
			scales:AddCard(lpz)
		end
		if rpz then
			scales:AddCard(rpz)
		end
		local ct=#scales
		
		if aux.EnabledPendulumMods[EFFECT_PENDULUM_SUMMON_WITH_ONE_SCALE] and c:IsHasEffect(EFFECT_PENDULUM_SUMMON_WITH_ONE_SCALE) then
			if ct>1 and c==rpz and lpz:IsType(TYPE_PENDULUM) then
				return false
			end
		elseif ct<2 or (c==rpz and lpz and not lpz:IsHasEffect(EFFECT_PANDEPEND_SCALE)) then
			return false
		end
		
		local loc=0
		if Duel.GetMZoneCount(tp,aux.LeavingCardForPendulumSummon)>0 then loc=loc|LOCATION_HAND end
		if Duel.GetLocationCountFromEx(tp,tp,aux.LeavingCardForPendulumSummon,TYPE_PENDULUM)>0 then loc=loc|LOCATION_EXTRA end
		if loc==0 then return false end
		local g=nil
		if og then
			g=og:Filter(Card.IsLocation,nil,loc)
		else
			g=Duel.GetFieldGroup(tp,loc,0)
		end
		
		local res1,res2 = false,false
		local lscale,rscale
		if ct==2 then
			lscale,rscale = lpz:GetLeftScale(),rpz:GetRightScale()
			if lscale>rscale then lscale,rscale=rscale,lscale end
			res1=g:IsExists(Auxiliary.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
			
			if aux.EnabledPendulumMods[EFFECT_PENDULUM_SUMMON_WITH_ONE_SCALE] and scales:IsExists(aux.NOT(Card.IsType),1,c,TYPE_PENDULUM) then
				local eset2={c:IsHasEffect(EFFECT_PENDULUM_SUMMON_WITH_ONE_SCALE)}
				for _,ce in ipairs(eset2) do
					lscale,rscale = c:GetLeftScale(),c:GetRightScale()
					local tg=ce:GetTarget()
					local val=ce:GetValue()
					if val then
						if c==lpz then
							rscale=val
						else
							lscale=val
						end
					end
					if lscale>rscale then lscale,rscale=rscale,lscale end
					if g:IsExists(Auxiliary.PConditionFilter,1,nil,e,tp,lscale,rscale,eset,tg) then
						res2=true
						break
					end
				end
			end
			
			return res1 or res2
			
		elseif aux.EnabledPendulumMods[EFFECT_PENDULUM_SUMMON_WITH_ONE_SCALE] then
			lscale,rscale = c:GetLeftScale(),c:GetRightScale()
			local eset2={c:IsHasEffect(EFFECT_PENDULUM_SUMMON_WITH_ONE_SCALE)}
			for _,ce in ipairs(eset2) do
				lscale,rscale = c:GetLeftScale(),c:GetRightScale()
				local tg=ce:GetTarget()
				local val=ce:GetValue()
				if val then
					if c==lpz then
						rscale=val
					else
						lscale=val
					end
				end
				if lscale>rscale then lscale,rscale=rscale,lscale end
				if g:IsExists(Auxiliary.PConditionFilter,1,nil,e,tp,lscale,rscale,eset,tg,ce) then
					return true
				end
			end
			return false
		end
		
		return false
	end
end

function Auxiliary.PConditionFilter(c,e,tp,lscale,rscale,eset,tg,ce)
	if not aux.EnabledPendulumMods then return _PConditionFilter(c,e,tp,lscale,rscale,eset) end
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	local bool=Auxiliary.PendulumSummonableBool(c)
	
	if type(tg)=="function" then
		if not tg(ce,c) then
			return false
		end
	end
	
	return (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
		and lv>lscale and lv<rscale and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,bool,bool)
		and not c:IsForbidden()
		and (Auxiliary.PendulumChecklist&(0x1<<tp)==0 or Auxiliary.PConditionExtraFilter(c,e,tp,lscale,rscale,eset))
end

function Auxiliary.PendOperation(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	if not aux.EnabledPendulumMods then
		return _PendOperation(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	else
		local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
		local tg=nil
		local loc=0
		local ft1=Duel.GetMZoneCount(tp,aux.LeavingCardForPendulumSummon)
		local ft2=Duel.GetLocationCountFromEx(tp,tp,aux.LeavingCardForPendulumSummon,TYPE_PENDULUM)
		local ft=Duel.GetUsableMZoneCount(tp)
		local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
		if ect and ect<ft2 then ft2=ect end
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then
			if ft1>0 then ft1=1 end
			if ft2>0 then ft2=1 end
			ft=1
		end
		if ft1>0 then loc=loc|LOCATION_HAND end
		if ft2>0 then loc=loc|LOCATION_EXTRA end
		if og then
			tg=og:Filter(Card.IsLocation,nil,loc)
		else
			tg=Duel.GetFieldGroup(tp,loc,0)
		end
		
		local lpz,rpz = Duel.GetFieldCard(tp,LOCATION_PZONE,0),Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		
		local pande
		if aux.EnabledPendulumMods[EFFECT_PANDEPEND_SCALE] then
			pande=Duel.GetMatchingGroup(Auxiliary.PandePendScale,tp,LOCATION_SZONE,0,c,c:GetSequence()):GetFirst()
			if pande then
				if c==lpz then
					rpz=pande
				else
					lpz=pande
				end
			end
		end
		
		local scales=Group.CreateGroup()
		if lpz then
			scales:AddCard(lpz)
		end
		if rpz then
			scales:AddCard(rpz)
		end
		local ct=#scales
		
		
		local lscale,rscale
		local hint
		local used_scales=Group.CreateGroup()
		if ct==1 or pande then
			local options,descs={},{}
			local pandepend=false
			
			if aux.EnabledPendulumMods[EFFECT_PANDEPEND_SCALE] then
				if ct==2 then
					lscale,rscale = lpz:GetLeftScale(),rpz:GetRightScale()
					if lscale>rscale then lscale,rscale=rscale,lscale end
					local eset2={pande:IsHasEffect(EFFECT_PANDEPEND_SCALE)}
					local te=eset2[#eset2]
					local desc=te:GetDescription()
					if not desc or desc==0 then
						desc=STRING_PANDEPEND_SCALE
					end
					if tg:IsExists(Auxiliary.PConditionFilter,1,nil,e,tp,lscale,rscale,eset) then
						pandepend=true
						table.insert(options,te)
						table.insert(descs,desc)
					end
				end
			end
			
			if aux.EnabledPendulumMods[EFFECT_PENDULUM_SUMMON_WITH_ONE_SCALE] then
				local eset2={c:IsHasEffect(EFFECT_PENDULUM_SUMMON_WITH_ONE_SCALE)}
				for _,ce in ipairs(eset2) do
					lscale,rscale = c:GetLeftScale(),c:GetRightScale()
					local targ=ce:GetTarget()
					local val=ce:GetValue()
					if val then
						if c==lpz then
							rscale=val
						else
							lscale=val
						end
						if lscale>rscale then lscale,rscale=rscale,lscale end
					end
					if tg:IsExists(Auxiliary.PConditionFilter,1,nil,e,tp,lscale,rscale,eset,targ,ce) then
						table.insert(options,ce)
						table.insert(descs,ce:GetDescription())
					end
				end
			end
			
			if #options>0 then
				local opt=Duel.SelectOption(tp,table.unpack(descs))+1
				local ce=options[opt]
				hint=ce:GetHandler():GetCode()
				if opt>1 or not pandepend then
					local targ=ce:GetTarget()
					local val=ce:GetValue()
					if val then
						if not rscale then
							rscale=val
						else
							lscale=val
						end
					end
					if lscale>rscale then lscale,rscale=rscale,lscale end
					tg=tg:Filter(Auxiliary.PConditionFilter,nil,e,tp,lscale,rscale,eset,targ,ce)
					used_scales:AddCard(c)
				else
					lscale,rscale = lpz:GetLeftScale(),rpz:GetRightScale()
					if lscale>rscale then lscale,rscale=rscale,lscale end
					tg=tg:Filter(Auxiliary.PConditionFilter,nil,e,tp,lscale,rscale,eset)
					used_scales=scales:Clone()
				end
			end
		else
			lscale,rscale = lpz:GetLeftScale(),rpz:GetRightScale()
			if lscale>rscale then lscale,rscale=rscale,lscale end
			tg=tg:Filter(Auxiliary.PConditionFilter,nil,e,tp,lscale,rscale,eset)
			used_scales=scales:Clone()
		end
		
		local ce=nil
		local b1=Auxiliary.PendulumChecklist&(0x1<<tp)==0
		local b2=#eset>0
		if b1 and b2 then
			local options={1163}
			for _,te in ipairs(eset) do
				table.insert(options,te:GetDescription())
			end
			local op=Duel.SelectOption(tp,table.unpack(options))
			if op>0 then
				ce=eset[op]
			end
		elseif b2 and not b1 then
			local options={}
			for _,te in ipairs(eset) do
				table.insert(options,te:GetDescription())
			end
			local op=Duel.SelectOption(tp,table.unpack(options))
			ce=eset[op+1]
		end
		if ce then
			tg=tg:Filter(Auxiliary.PConditionExtraFilterSpecific,nil,e,tp,lscale,rscale,ce)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		Auxiliary.GCheckAdditional=Auxiliary.PendOperationCheck(ft1,ft2,ft)
		local g=tg:SelectSubGroup(tp,aux.TRUE,true,1,math.min(#tg,ft))
		Auxiliary.GCheckAdditional=nil
		if not g then return end
		if ce then
			Duel.Hint(HINT_CARD,0,ce:GetOwner():GetOriginalCode())
			ce:UseCountLimit(tp)
		else
			Auxiliary.PendulumChecklist=Auxiliary.PendulumChecklist|(0x1<<tp)
		end
		sg:Merge(g)
		Duel.HintSelection(used_scales)
		if hint then
			Duel.Hint(HINT_CARD,tp,hint)
		end
	end
end