--Statua della Perpetuità
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--summon proc
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.otcon)
	e1:SetOperation(s.otop)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_GRAVE,0)
	e3:SetTarget(s.mattg)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	--SS
	c:TributedForATributeSummonTrigger(false,nil,1,CATEGORY_SPECIAL_SUMMON,false,{1,0},s.cond,nil,s.tg,s.op)
	--
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_MSET)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if not tc:HasFlagEffect(FLAG_UNCOUNTED_NORMAL_SET) then
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end

function s.cond(e,tp,eg,ep,ev,re,r,rp,c,rc)
	return c:IsLocation(LOCATION_GRAVE)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if chk==0 then return aux.SSSelfTarget(e,tp,eg,ep,ev,re,r,rp,chk) end
	aux.SSSelfTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	rc:CreateEffectRelation(e)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if aux.SSSelfOperation()(e,tp,eg,ep,ev,re,r,rp) and rc:IsRelateToEffect(e) and rc:IsSummonLocation(LOCATION_HAND) and rc:IsPreviousControler(tp) then
		Duel.BreakEffect()
		if Duel.GetFlagEffect(tp,id)~=0 then return end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetTargetRange(LOCATION_ALL,0)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,5))
		e1:SetValue(0x1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_EXTRA_SET_COUNT)
		Duel.RegisterEffect(e2,tp)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end

function Card.IsGlitchySummonable(c)
	local tp=c:GetControler()
	if not c:IsSummonableCard() or c:IsForbidden() then return false end
	if not ign and not c:IsHasEffect(EFFECT_EXTRA_SUMMON_COUNT) and not Duel.CheckSummonedCount(c) then return false end
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
	local summon_count_limit=1
	for _,ce in ipairs(eset) do
		if ce and ce.GetValue then
			local ct=ce:GetValue()
			if ct and ct>summon_count_limit then
				summon_count_limit=ct
			end
		end
	end
	if Duel.GetFlagEffect(tp,id)>=summon_count_limit and (not Duel.IsPlayerCanAdditionalSummon(tp) or not c:IsHasEffect(EFFECT_EXTRA_SUMMON_COUNT)) then return false end
	for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_SUMMON_COST)}) do
		if ce and ce.SetLabel then
			local cost=ce:GetCost()
			if cost and not cost(ce,c,tp) then
				return false
			end
		end
	end
	if c:IsHasEffect(EFFECT_CANNOT_SUMMON) then return false end
	--
	local peset={}
	local res=c:FilterSummonProc(tp,peset)
	if #peset==0 and (aux.GetValueType(res)=="boolean" and not res or aux.GetValueType(res)=="number" and res==-2) then
		return false
	end
	
	return true				
end	
function Card.IsGlitchyMSetable(c)
	local tp=c:GetControler()
	if not c:IsSummonableCard() or c:IsForbidden() or c:IsHasEffect(EFFECT_CANNOT_MSET) then return false end
	if not c:IsHasEffect(EFFECT_EXTRA_SET_COUNT) and not Duel.CheckSummonedCount(c) then return false end
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
	local summon_count_limit=1
	for _,ce in ipairs(eset) do
		if ce and ce.GetValue then
			local ct=ce:GetValue()
			if ct and ct>summon_count_limit then
				summon_count_limit=ct
			end
		end
	end
	if Duel.GetFlagEffect(tp,id)>=summon_count_limit and (not Duel.IsPlayerCanAdditionalSummon(tp) or not c:IsHasEffect(EFFECT_EXTRA_SET_COUNT)) then return false end
	for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_MSET_COST)}) do
		if ce and ce.SetLabel then
			local cost=ce:GetCost()
			if cost and not cost(ce,c,tp) then
				return false
			end
		end
	end
	--
	local peset={}
	local res,peset=c:FilterSetProc(tp,peset)
	if #peset==0 and (aux.GetValueType(res)=="boolean" and not res or aux.GetValueType(res)=="number" and res==-2) then
		return false
	end
	
	return true				
end
function Card.FilterSummonProc(c,tp,peset)
	if c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC) then
		for _,ce in ipairs({c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC)}) do
			if ce and ce.SetLabel then
				if c:CheckSummonProc(ce,tp) then
					table.insert(peset,ce)
				end
			end
		end
		if #peset>0 then
			return -1
		end
		return -2
	end
	for _,ce in ipairs({c:IsHasEffect(EFFECT_SUMMON_PROC)}) do
		if ce and ce.SetLabel then
			if c:CheckSummonProc(ce,tp) then
				table.insert(peset,ce)
			end
		end
	end
	if not Duel.IsPlayerCanSummon(tp,SUMMON_TYPE_NORMAL,c) or not c:CheckUniqueOnField(tp,LOCATION_MZONE) then return false end
	
	local rcount=c:GetSummonTributeCount()
	local min=rcount&0xffff
	local max=(rcount>>16)&0xffff
	if not Duel.IsPlayerCanSummon(tp,SUMMON_TYPE_ADVANCE,c) then max=0 end
	if min<1 then min=1 end
	if max<min then return false end
	
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
	local summon_count_limit=1
	for _,ce in ipairs(eset) do
		if ce and ce.GetValue then
			local ct=ce:GetValue()
			if ct and ct>summon_count_limit then
				summon_count_limit=ct
			end
		end
	end
	if Duel.GetFlagEffect(tp,id)>=summon_count_limit and Duel.IsPlayerCanAdditionalSummon(tp) then
		for _,ke in ipairs({c:IsHasEffect(EFFECT_EXTRA_SUMMON_COUNT)}) do
			local retval={}
			local val=ke:GetValue()
			if aux.GetValueType(val)=="function" then
				local res={val(ke,c)}
				table.insert(retval,table.unpack(res))
			else
				table.insert(retval,val)
			end
			local new_min_tribute = #retval>0 and retval[1] or 0
			local new_zone = #retval>1 and retval[2] or 0x1f
			local releasable = 0xff00ff
			if #retval>2 then
				if retval[3]<0 then
					releasable = 0xff00ff+retval[3]
				else
					releasable = retval[3]
				end
			end
			if new_min_tribute<1 then new_min_tribute=1 end
			new_zone = new_zone&0x1f
			--
			if Duel.GlitchyCheckTribute(c,new_min_tribute,max,nil,tp,new_zone,releasable,0) then
				return true
			end
		end
	
	else
		return Duel.GlitchyCheckTribute(c,min,max,nil,tp,0x1f,0xff00ff,0)
	end
	
	return false
end
function Card.FilterSetProc(c,tp,peset)
	if c:IsHasEffect(EFFECT_LIMIT_SET_PROC) then
		for _,ce in ipairs({c:IsHasEffect(EFFECT_LIMIT_SET_PROC)}) do
			if ce and ce.SetLabel then
				if c:CheckSetProc(ce,tp) then
					table.insert(peset,ce)
				end
			end
		end
		if #peset>0 then
			return -1,peset
		end
		return -2,peset
	end
	for _,ce in ipairs({c:IsHasEffect(EFFECT_SET_PROC)}) do
		if ce and ce.SetLabel then
			if c:CheckSetProc(ce,tp) then
				table.insert(peset,ce)
			end
		end
	end
	if not Duel.IsPlayerCanMSet(tp,SUMMON_TYPE_NORMAL,c) then return false,peset end
	
	local rcount=c:GetSetTributeCount()
	local min=rcount&0xffff
	local max=(rcount>>16)&0xffff
	if not Duel.IsPlayerCanMSet(tp,SUMMON_TYPE_ADVANCE,c) then max=0 end
	if min<1 then min=1 end
	if max<min then return false,peset end
	
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
	local summon_count_limit=1
	for _,ce in ipairs(eset) do
		if ce and ce.GetValue then
			local ct=ce:GetValue()
			if ct and ct>summon_count_limit then
				summon_count_limit=ct
			end
		end
	end
	if Duel.GetFlagEffect(tp,id)>=summon_count_limit and Duel.IsPlayerCanAdditionalSummon(tp) then
		for _,ke in ipairs({c:IsHasEffect(EFFECT_EXTRA_SET_COUNT)}) do
			local retval={}
			local val=ke:GetValue()
			if aux.GetValueType(val)=="function" then
				local res={val(ke,c)}
				table.insert(retval,table.unpack(res))
			else
				table.insert(retval,val)
			end
			local new_min_tribute = #retval>0 and retval[1] or 0
			local new_zone = #retval>1 and retval[2] or 0x1f
			local releasable = 0xff00ff
			if #retval>2 then
				if retval[3]<0 then
					releasable = 0xff00ff+retval[3]
				else
					releasable = retval[3]
				end
			end
			if new_min_tribute<1 then new_min_tribute=1 end
			new_zone = new_zone&0x1f
			--
			if Duel.GlitchyCheckTribute(c,new_min_tribute,max,nil,tp,new_zone,releasable,POS_FACEDOWN_DEFENSE) then
				return true,peset
			end
		end
	
	else
		return Duel.GlitchyCheckTribute(c,min,max,nil,tp,0x1f,0xff00ff,POS_FACEDOWN_DEFENSE),peset
	end
	
	return false,peset
end
function Card.CheckSummonProc(c,ce,tp)
	if not ce:CheckCountLimit(tp) then return false end
	local toplayer=tp
	if ce:IsHasProperty(EFFECT_FLAG_SPSUM_PARAM) then
		local s,o=ce:GLGetTargetRange()
		if o and o~=0 then
			toplayer=1-tp
		end
	end
	local sumtype=ce:GetValue() and ce:GetValue() or SUMMON_TYPE_NORMAL
	for _,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_SUMMON)}) do
		if pe and pe.SetLabel then
			local tg=pe:GetTarget()
			if not tg then return false end
			if tg(pe,c,tp,sumtype,POS_FACEUP,toplayer) then return false end
		end
	end
	if not c:CheckUniqueOnField(toplayer,LOCATION_MZONE) then return false end
	
	local cond=ce:GetCondition()
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
	local summon_count_limit=1
	for _,ce in ipairs(eset) do
		if ce and ce.GetValue then
			local ct=ce:GetValue()
			if ct and ct>summon_count_limit then
				summon_count_limit=ct
			end
		end
	end
	if Duel.GetFlagEffect(tp,id)>=summon_count_limit and Duel.IsPlayerCanAdditionalSummon(tp) then
		for _,ke in ipairs({c:IsHasEffect(EFFECT_EXTRA_SUMMON_COUNT)}) do
			local retval={}
			local val=ke:GetValue()
			if aux.GetValueType(val)=="function" then
				local res={val(ke,c)}
				table.insert(retval,table.unpack(res))
			else
				table.insert(retval,val)
			end
			local new_min_tribute = #retval>0 and retval[1] or 0
			local new_zone = #retval>1 and retval[2] or 0x1f001f
			local releasable = 0xff00ff
			if #retval>2 then
				if retval[3]<0 then
					releasable = 0xff00ff+retval[3]
				else
					releasable = retval[3]
				end
			end
			if new_min_tribute<1 then new_min_tribute=1 end
			if ce:IsHasProperty(EFFECT_FLAG_SPSUM_PARAM) then
				local s,o=ce:GLGetTargetRange()
				if o~=0 then
					new_zone = (new_zone >> 16) | (new_zone & 0xffff << 16)
				end
			end
			new_zone = new_zone&0x1f
			--
			if not cond or cond(ce,c,new_min_tribute,new_zone,releasable,ke) then
				return true
			end
		end
	else
		if not cond or cond(ce,c,1,0x1f) then
			return true
		end
	end
	return false
end
function Card.CheckSetProc(c,ce,tp)
	if not ce:CheckCountLimit(tp) then return false end
	local toplayer=tp
	if ce:IsHasProperty(EFFECT_FLAG_SPSUM_PARAM) then
		local s,o=ce:GLGetTargetRange()
		if o and o~=0 then
			toplayer=1-tp
		end
	end
	local sumtype=ce:GetValue() and ce:GetValue() or SUMMON_TYPE_NORMAL
	for _,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_MSET)}) do
		if pe and pe.SetLabel then
			local tg=pe:GetTarget()
			if not tg then return false end
			if tg(pe,c,tp,sumtype,POS_FACEDOWN,toplayer) then return false end
		end
	end
	
	local cond=ce:GetCondition()
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
	local summon_count_limit=1
	for _,ce in ipairs(eset) do
		if ce and ce.GetValue then
			local ct=ce:GetValue()
			if ct and ct>summon_count_limit then
				summon_count_limit=ct
			end
		end
	end
	if Duel.GetFlagEffect(tp,id)>=summon_count_limit and Duel.IsPlayerCanAdditionalSummon(tp) then
		for _,ke in ipairs({c:IsHasEffect(EFFECT_EXTRA_SET_COUNT)}) do
			local retval={}
			local val=ke:GetValue()
			if aux.GetValueType(val)=="function" then
				local res={val(ke,c)}
				table.insert(retval,table.unpack(res))
			else
				table.insert(retval,val)
			end
			local new_min_tribute = #retval>0 and retval[1] or 0
			local new_zone = #retval>1 and retval[2] or 0x1f001f
			local releasable = 0xff00ff
			if #retval>2 then
				if retval[3]<0 then
					releasable = 0xff00ff+retval[3]
				else
					releasable = retval[3]
				end
			end
			if new_min_tribute<1 then new_min_tribute=1 end
			new_zone = new_zone&0x1f
			--
			if not cond or cond(ce,c,new_min_tribute,new_zone,releasable) then
				return true
			end
		end
	else
		if not cond or cond(ce,c,1,0x1f) then
			return true
		end
	end
	return false
end
function Card.GetSummonTributeCount(c)
	local min,max = 0,0
	local lv=c:GetLevel()
	if lv<5 then
		return 0
	elseif lv<7 then
		min=1
		max=1
	else
		min=2
		max=2
	end
	local dupe={}
	for _,ce in ipairs({c:IsHasEffect(EFFECT_DECREASE_TRIBUTE)}) do
		if not (ce:IsHasProperty(EFFECT_FLAG_COUNT_LIMIT) and ce:GetCountLimit()==0) then
			local retval={}
			local val=ce:GetValue()
			if aux.GetValueType(val)=="function" then
				local res={val(ce,c)}
				table.insert(retval,table.unpack(res))
			else
				table.insert(retval,val)
			end
			local dec = #retval>0 and retval[1] or 0
			local code = #retval>1 and retval[2] or 0
			if code>0 then
				local check=true
				for _,it in ipairs(dupe) do
					if it==code then
						check=false
						break
					end
				end
				if check then
					table.insert(dupe,code)
				end
			end
			min = min-(dec&0xffff)
			max = max-(dec>>16)
		end
	end
	min = (min<0) and 0 or min
	max = (max<min) and min or max
	
	return min+(max<<16)
end
function Card.GetSetTributeCount(c)
	local min,max = 0,0
	local lv=c:GetLevel()
	if lv<5 then
		return 0
	elseif lv<7 then
		min=1
		max=1
	else
		min=2
		max=2
	end
	local dupe={}
	for _,ce in ipairs({c:IsHasEffect(EFFECT_DECREASE_TRIBUTE_SET)}) do
		if not (ce:IsHasProperty(EFFECT_FLAG_COUNT_LIMIT) and ce:GetCountLimit()==0) then
			local retval={}
			local val=ce:GetValue()
			if aux.GetValueType(val)=="function" then
				local res={val(ce,c)}
				table.insert(retval,table.unpack(res))
			else
				table.insert(retval,val)
			end
			local dec = #retval>0 and retval[1] or 0
			local code = #retval>1 and retval[2] or 0
			if code>0 then
				local check=true
				for _,it in ipairs(dupe) do
					if it==code then
						check=false
						break
					end
				end
				if check then
					table.insert(dupe,code)
				end
			end
			min = min-(dec&0xffff)
			max = max-(dec>>16)
		end
	end
	min = (min<0) and 0 or min
	max = (max<min) and min or max
	
	return min+(max<<16)
end
function Duel.GlitchyCheckTribute(c,min,max,mg,toplayer,zone,releasable,pos)
	local ex=false
	local sump=c:GetControler()
	if toplayer==1-sump then ex=true end
	local release_list,ex_list=Group.CreateGroup(),Group.CreateGroup()
	release_list:KeepAlive()
	ex_list:KeepAlive()
	local m,release_list,ex_list=Duel.GetSummonTributeList(c,release_list,ex_list,nil,mg,ex,releasable,pos)
	if max>m then
		max=m
	end
	if min>max then
		return false
	end
	
	zone = zone & 0x1f
	local s=0
	local ct=Duel.GetToFieldCount(c,toplayer,sump,LOCATION_REASON_TOFIELD,zone)
	if ct<=0 and max<=0 then
		return false
	end
	
	if #ex_list>=min then
		for tc in aux.Next(ex_list) do
			if tc:IsLocation(LOCATION_MZONE) and tc:GetControler()==toplayer then
				s=s+1
				if (zone>>tc:GetSequence())&1>0 then
					ct=ct+1
				end
			end
		end
	else
		for tc in aux.Next(release_list) do
			if tc:IsLocation(LOCATION_MZONE) and tc:GetControler()==toplayer then
				s=s+1
				if (zone>>tc:GetSequence())&1>0 then
					ct=ct+1
				end
			end
		end
	end
	
	release_list:DeleteGroup()
	ex_list:DeleteGroup()
	
	if ct<=0 then return false end
	
	max = max-#ex_list
	local fcount=Duel.GetMZoneLimit(toplayer,sump,LOCATION_REASON_TOFIELD)
	if s<(1-fcount) then
		return false
	end
	if max<0 then
		max=0
	end
	if max<(1-fcount) then
		return false
	end
	
	return true
end
function Duel.GetSummonTributeList(c,release_list,ex_list,ex_list_oneof,mg,ex,releasable,pos,getparams)
	local tp=c:GetControler()
	local ex_set=Group.CreateGroup()
	ex_set:KeepAlive()
	for _,ce in ipairs({c:IsHasEffect(EFFECT_ADD_EXTRA_TRIBUTE)}) do
		if ce and ce.SetLabel then
			local val=ce:GetValue()
			if aux.GetValueType(val)=="function" then
				val=val(ce)
			end
			if val&pos>0 then
				ex_set=ce:FilterInRangeCards(ex_set)
			end
		end
	end
	
	local rcount=0
	local release_param_list={}
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	for tc in aux.Next(g) do
		if (releasable>>tc:GetSequence())&1>0 and tc:IsReleasableBySummon(tp,c) then
			if not mg or mg:IsContains(tc) then
				if release_list then
					release_list:AddCard(tc)
				end
				local release_param
				for _,ce in ipairs({tc:IsHasEffect(EFFECT_DOUBLE_TRIBUTE)}) do
					if ce and ce.SetLabel then
						local val=ce:GetValue()
						if aux.GetValueType(val)~="function" or val(ce,c) then
							release_param=2
							break
						end
					end
				end
				if not release_param then release_param=1 end
				if getparams then release_param_list[tc]=release_param end
				rcount=rcount+release_param
			end
		end
	end
	
	local ex_oneof_max=0
	local g=Duel.GetFieldGroup(1-tp,LOCATION_MZONE,0)
	for tc in aux.Next(g) do
		if (releasable>>(tc:GetSequence()+16))&1>0 and tc:IsReleasableBySummon(tp,c) then
			if not mg or mg:IsContains(tc) then
				local release_param
				for _,ce in ipairs({tc:IsHasEffect(EFFECT_DOUBLE_TRIBUTE)}) do
					if ce and ce.SetLabel then
						local val=ce:GetValue()
						if aux.GetValueType(val)~="function" or val(ce,c) then
							release_param=2
							break
						end
					end
				end
				if not release_param then release_param=1 end
				if getparams then
					release_param_list[tc]=release_param
				end
				if ex or ex_set:IsContains(tc) then
					if release_list then
						release_list:AddCard(tc)
					end
					rcount=rcount+release_param
					
				elseif c:IsHasEffect(EFFECT_EXTRA_RELEASE) then
					if ex_list then
						ex_list:AddCard(tc)
					end
					rcount=rcount+release_param
				
				else
					local ce=tc:IsHasEffect(EFFECT_EXTRA_RELEASE_SUM)
					if ce and not (ce:IsHasProperty(EFFECT_FLAG_COUNT_LIMIT) and ce:GetCountLimit()==0) then
						if ex_list_oneof then
							ex_list_oneof:AddCard(tc)
						end
						if ex_oneof_max<release_param then
							ex_oneof_max=release_param
						end
					end
				end
			end
		end
	end
	
	for tc in aux.Next(ex_set) do
		if not tc:IsLocation(LOCATION_MZONE) and tc:IsReleasableBySummon(tp,c) then
			if release_list then
				release_list:AddCard(tc)
			end
			for _,ce in ipairs({tc:IsHasEffect(EFFECT_DOUBLE_TRIBUTE)}) do
				if ce and ce.SetLabel then
					local val=ce:GetValue()
					if aux.GetValueType(val)~="function" or val(ce,c) then
						release_param=2
						break
					end
				end
			end
			if not release_param then release_param=1 end
			if getparams then release_param_list[tc]=release_param end
			rcount=rcount+release_param
		end
	end
	
	ex_set:DeleteGroup()
	
	if getparams then
		return rcount+ex_oneof_max,release_list,ex_list,ex_list_oneof,release_param_list
	else
		return rcount+ex_oneof_max,release_list,ex_list,ex_list_oneof
	end
end
function Effect.FilterInRangeCards(e,set)
	if e:IsHasProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_SPSUM_PARAM) then return end
	local self=e:GetHandlerPlayer()
	if self==PLAYER_NONE then return end
	local s,o=e:GLGetTargetRange()
	local g=Group.CreateGroup()
	for p=0,1 do
		local locs={LOCATION_MZONE,LOCATION_SZONE,LOCATION_GRAVE,LOCATION_REMOVED,LOCATION_HAND,LOCATION_DECK,LOCATION_EXTRA}
		for _,loc in ipairs(locs) do
			if s&loc>0 then g:Merge(Duel.GetFieldGroup(p,loc,0)) end
		end
		s=o
		self=1-self
	end
	local tg=e:GetTarget()
	for tc in aux.Next(g) do
		if not tg or tg(e,tc) then
			set:AddCard(tc)
		end
	end
	return set
end
function Duel.FilterMustUseMZone(tp,up,r,c,flag)
	local eset={}
	if up<2 then
		for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(up,EFFECT_MUST_USE_MZONE)}) do
			table.insert(eset,ce)
		end
	end
	if c then
		for _,ce in ipairs({c:IsHasEffect(EFFECT_MUST_USE_MZONE)}) do
			table.insert(eset,ce)
		end
	end
	
	for _,ce in ipairs(eset) do
		if not ce:IsHasProperty(EFFECT_FLAG_COUNT_LIMIT) or ce:GetCountLimit()~=0 then
			local value=0x1f
			local val=ce:GetValue()
			if ce:IsHasProperty(EFFECT_FLAG_PLAYER_TARGET) then
				if aux.GetValueType(val)=="function" then
					value=val(ce)
				else
					value=val
				end
			
			else
				if aux.GetValueType(val)=="function" then
					value=val(ce,c,tp,up,r)
				else
					value=val
				end
			end
			if ce:GetHandlerPlayer()==tp then
				flag = flag | (~(value)&0x7f)
			else
				flag = flag | (~(value>>16)&0x7f)
			end
		end
	end
	
	return flag
end
function Card.IsReleasableBySummon(c,tp,tc)
	for _,ce in ipairs({c:IsHasEffect(EFFECT_UNRELEASABLE_SUM)}) do
		if ce and ce.SetLabel then
			local val=ce:GetValue()
			if aux.GetValueType(val)~="function" or val(ce,tc) then
				return false
			end
		end
	end
	for _,ce in ipairs({tc:IsHasEffect(EFFECT_TRIBUTE_LIMIT)}) do
		if ce and ce.SetLabel then
			local val=ce:GetValue()
			if aux.GetValueType(val)~="function" or val(ce,c) then
				return false
			end
		end
	end
	return not c:IsStatus(STATUS_SUMMONING) and Duel.IsPlayerCanRelease(tp,c)
end
function Duel.GetToFieldCount(c,tp,up,r,zone)
	local _,flag=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD)
	flag = ~flag
	flag=Duel.FilterMustUseMZone(tp,up,r,c,flag)
	flag = (flag|~zone)&0x1f
	
	local field_used_count = {0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5}
	return 5-field_used_count[flag+1]
end
function Duel.GetMZoneLimit(tp,up,r)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local used_flag=0
	for tc in aux.Next(g) do
		used_flag = used_flag|(1<<tc:GetSequence())
	end
	used_flag = used_flag&0x1f
	local max=5
	local field_used_count = {0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5}
	local used_count=field_used_count[used_flag+1]
	
	if Duel.GetMasterRule()>=4 then
		max=7
		for seq=5,6 do
			if g:IsExists(aux.FilterEqualFunction(Card.GetSequence,seq),1,nil) then
				used_count = used_count+1
			end
		end
	end
	
	local eset
	if up<2 then
		eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MAX_MZONE)}
	else
		eset={}
	end
	for _,ce in ipairs(eset) do
		if ce and ce.SetLabel then
			local v
			local val=ce:GetValue()
			if aux.GetValueType(val)=="function" then
				v=val(ce,tp,up,r)
			else
				v=val
			end
			if v<max then
				max=v
			end
		end
	end
	
	return max-used_count
end

function s.mattg(e,c)
	return c:IsLevelAbove(5)
end
function s.otfilter(c,tp)
	return c:IsCode(id) and (c:IsControler(tp) or c:IsFaceup())
end
function s.otcon(e,tp)
	local c=e:GetHandler()
	local mi,ma=c:GetTributeRequirement()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_TRIBUTE_LIMIT)
	e1:SetValue(s.recon)
	c:RegisterEffect(e1)
	local res=c:IsLevelAbove(5) and mi>=1 and (c:IsGlitchySummonable(false,nil,1) or c:IsGlitchyMSetable(false,nil,1))
	e1:Reset()
	return res
end
function s.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi>=1 and c:IsLevelAbove(5)
end
function s.otop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_TRIBUTE_LIMIT)
	e1:SetValue(s.recon)
	c:RegisterEffect(e1)
	local s1=c:IsGlitchySummonable(false,nil,1)
	local s2=c:IsGlitchyMSetable(false,nil,1)
	if (s1 and (not s2 or Duel.SelectPosition(tp,c,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK)) then
		Duel.Summon(tp,c,false,nil,1)
	elseif s2 then
		--Duel.SendtoHand(c,nil,REASON_RULE)
		Duel.GlitchyMSet(tp,c)
	end
	e1:Reset()
end
function s.recon(e,c)
	return not c:IsCode(id)
end

function Duel.GlitchyMSet(tp,c)
	local skip3,skip5,skip6=false,false,false
	
	--Step 0
	if not c:IsSummonableCard() or c:GetOriginalType()&TYPE_MONSTER==0 or c:IsHasEffect(EFFECT_CANNOT_MSET) then return false end
	local eset={}
	local res,eset=c:FilterSetProc(tp,eset)
	if res==-2 then return false end
	local select_effects={}
	local select_options={}
	if res then
		table.insert(select_effects,0)
		table.insert(select_options,1)
	end
	for _,ce in ipairs(eset) do
		table.insert(select_effects,ce)
		table.insert(select_options,ce:GetDescription())
	end
	local result,result2
	if #select_options==1 then
		result=0
	else
		result=Duel.SelectOption(tp,table.unpack(select_options))
	end
	
	--Step 1
	eset={c:IsHasEffect(EFFECT_EXTRA_SET_COUNT)}
	local proc=select_effects[result+1]
	select_effects={}
	select_options={}
	local peset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
	local summon_count_limit=1
	for _,ce in ipairs(peset) do
		if ce and ce.GetValue then
			local ct=ce:GetValue()
			if ct and ct>summon_count_limit then
				summon_count_limit=ct
			end
		end
	end
	if Duel.GetFlagEffect(tp,id)<summon_count_limit then
		table.insert(select_effects,0)
		table.insert(select_options,1)
	end
	
	local cond= aux.GetValueType(proc)=="Effect" and proc:GetCondition()
	if Duel.IsPlayerCanAdditionalSummon(tp) then
		for _,ce in ipairs(eset) do
			local skip=false
			local retval={}
			local val=ce:GetValue()
			if aux.GetValueType(val)=="function" then
				local res={val(ce,c)}
				table.insert(retval,table.unpack(res))
			else
				table.insert(retval,val)
			end
			local new_min_tribute = #retval>0 and retval[1] or 0
			local new_zone = #retval>1 and retval[2] or 0x1f
			local releasable = 0xff00ff
			if #retval>2 then
				if retval[3]<0 then
					releasable = 0xff00ff+retval[3]
				else
					releasable = retval[3]
				end
			end
			if new_min_tribute<1 then new_min_tribute=1 end
			new_zone = new_zone&0x1f
			
			if aux.GetValueType(proc)=="Effect" then
				if new_min_tribute<1 then new_min_tribute=1 end
				if not cond or cond(proc,c,new_min_tribute,new_zone,releasable) then skip=true end
			else
				local rcount=c:GetSetTributeCount()
				local min=rcount&0xffff
				local max=(rcount>>16)&0xffff
				if not Duel.IsPlayerCanMSet(tp,SUMMON_TYPE_ADVANCE,c) then max=0 end
				if min<1 then min=1 end
				
				if max<min then
					skip=true
				else
					if min<new_min_tribute then
						min=new_min_tribute
					end
					if not Duel.GlitchyCheckTribute(c,min,max,nil,tp,new_zone,releasable,POS_FACEDOWN_DEFENSE) then
						skip=true
					end
				end
			end
			
			if not skip then
				table.insert(select_effects,ce)
				table.insert(select_options,ce:GetDescription())
			end
		end
	end
	if #select_options==1 then
		result=0
	else
		result=Duel.SelectOption(tp,table.unpack(select_options))
	end
	
	--Step 2
	local tributes=Group.CreateGroup()
	tributes:KeepAlive()
	
	local rcount,release_cards,release_cards_ex,release_cards_ex_oneof,release_param_list=0,Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup(),{}
	
	local arg1,arg2
	local pextra=select_effects[result+1]
	--
	local releasable=0xff00ff
	
	if aux.GetValueType(pextra)=="Effect" then
		local retval={}
		local val=ce:GetValue()
		if aux.GetValueType(val)=="function" then
			local res={val(ce,c)}
			table.insert(retval,table.unpack(res))
		else
			table.insert(retval,val)
		end
		local new_min_tribute = #retval>0 and retval[1] or 0
		local new_zone = #retval>1 and retval[2] or 0x1f
		if #retval>2 then
			if retval[3]<0 then
				releasable = 0xff00ff+retval[3]
			else
				releasable = retval[3]
			end
		end
		if new_min_tribute<1 then new_min_tribute=1 end
		new_zone = new_zone&0x1f
		arg1 = tp + (false << 8) + (new_min_tribute << 16) + (new_zone << 24)
	end
	if aux.GetValueType(proc)~="Effect" then
		local required=c:GetSetTributeCount()
		local min=required&0xffff
		local max=required>>16
		if min<1 then min=1 end
		local adv=Duel.IsPlayerCanMSet(tp,SUMMON_TYPE_ADVANCE,c)
		if max==0 or not adv then
			result2=0
		else
			release_cards:KeepAlive()
			release_cards_ex:KeepAlive()
			release_cards_ex_oneof:KeepAlive()
			rcount,release_cards,release_cards_ex,release_cards_ex_oneof,release_param_list=Duel.GetSummonTributeList(c,release_cards,release_cards_ex,release_cards_ex_oneof,nil,0,releasable,POS_FACEDOWN_DEFENSE,true)
			if rcount==0 then
				result2=0
				skip3=true
			else
				local ct=Duel.GetToFieldCount(c,tp,tp,LOCATION_REASON_TOFIELD,0x1f)
				local fcount=Duel.GetMZoneLimit(tp,tp,LOCATION_REASON_TOFIELD)
				if min<(1-fcount) then min=1-fcount end
				tributes=Duel.GlitchySelectTribute(c,tp,min,max,tp,release_cards,release_cards_ex,release_cards_ex_oneof,release_param_list)
				skip3=true
			end
		end
	else
		skip3=true
	end
	
	--Step 3
	if not skip3 then
		if result then
			result2=0
		else
			local max=arg2
			tributes=Duel.GlitchySelectTribute(c,tp,1,max,tp,release_cards,release_cards_ex,release_cards_ex_oneof,release_param_list)
		end
	end
	release_cards:DeleteGroup()
	release_cards_ex:DeleteGroup()
	release_cards_ex_oneof:DeleteGroup()
	
	--Step 4
	if aux.GetValueType(proc)~="Effect" then
		if result==-1 then return false end
		for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_MSET_COST)}) do
			if ce and ce.SetLabel then
				local op=ce:GetOperation()
				if op then
					op(ce,tp)
				end
			end
		end
	else
		skip5=true
	end
	
	--Step 5
	if not skip5 then
		local min
		local lv=c:GetLevel()
		if lv<5 then
			min=0
		elseif lv<7 then
			min=1
		else
			min=2
		end
		if tributes then min=min-#tributes end
		
		if min>0 then
			local dupe={}
			for _,ce in ipairs({c:IsHasEffect(EFFECT_DECREASE_TRIBUTE_SET)}) do
				if not ce:IsHasProperty(EFFECT_FLAG_COUNT_LIMIT) then
					local retval={}
					local val=ce:GetValue()
					if aux.GetValueType(val)=="function" then
						local res={val(ce,c)}
						table.insert(retval,table.unpack(res))
					else
						table.insert(retval,val)
					end
					local dec = #retval>0 and retval[1] or 0
					local code = #retval>1 and retval[2] or 0
					if code>0 then
						local check=true
						for _,it in ipairs(dupe) do
							if it==code then
								check=false
								break
							end
						end
						if check then
							table.insert(dupe,code)
						end
					end
					min = min-(dec&0xffff)
				end
			end
			
			if min>0 then
				for _,ce in ipairs({c:IsHasEffect(EFFECT_DECREASE_TRIBUTE_SET)}) do
					local tg=ce:GetTarget()
					if ce:IsHasProperty(EFFECT_FLAG_COUNT_LIMIT) and c:GetCountLimit()~=0 and tg then
						local retval={}
						local val=ce:GetValue()
						if aux.GetValueType(val)=="function" then
							local res={val(ce,c)}
							table.insert(retval,table.unpack(res))
						else
							table.insert(retval,val)
						end
						local dec = #retval>0 and retval[1] or 0
						local code = #retval>1 and retval[2] or 0
						if code>0 then
							local check=true
							for _,it in ipairs(dupe) do
								if it==code then
									check=false
									break
								end
							end
							if check then
								table.insert(dupe,code)
							end
						end
						min = min-(dec&0xffff)
						ce:UseCountLimit(tp)
					end
					if min<=0 then break end
				end
			end
			
			if min>0 then
				for _,ce in ipairs({c:IsHasEffect(EFFECT_DECREASE_TRIBUTE_SET)}) do
					local tg=ce:GetTarget()
					if ce:IsHasProperty(EFFECT_FLAG_COUNT_LIMIT) and c:GetCountLimit()~=0 and not tg then
						local retval={}
						local val=ce:GetValue()
						if aux.GetValueType(val)=="function" then
							local res={val(ce,c)}
							table.insert(retval,table.unpack(res))
						else
							table.insert(retval,val)
						end
						local dec = #retval>0 and retval[1] or 0
						local code = #retval>1 and retval[2] or 0
						if code>0 then
							local check=true
							for _,it in ipairs(dupe) do
								if it==code then
									check=false
									break
								end
							end
							if check then
								table.insert(dupe,code)
							end
						end
						min = min-(dec&0xffff)
						ce:UseCountLimit(tp)
					end
					if min<=0 then break end
				end
			end
		end
	
		local summon_info
		if tributes then
			c:SetMaterial(tributes)
			Duel.Release(tributes,REASON_SUMMON|REASON_MATERIAL)
			summon_info = SUMMON_TYPE_NORMAL | SUMMON_TYPE_ADVANCE | (LOCATION_HAND << 16)
			tributes:DeleteGroup()
			Duel.Readjust()
		else
			summon_info = SUMMON_TYPE_NORMAL | (LOCATION_HAND << 16)
		end
		skip6=true
	end
	
	--Step 6
	if not skip6 then
		if aux.GetValueType(proc)=="Effect" then
			local op=proc:GetOperation()
			if op then
				op(proc,tp,nil,tp,0,nil,0,tp,c)
			end
			proc:UseCountLimit(tp)
		end
	end
	
	--Step 7
	Duel.BreakEffect()
	if aux.GetValueType(pextra)~="Effect" then
		Duel.IncreaseSummonedCount()
	else
		Duel.Hint(HINT_CARD,tp,pextra:GetHandler():GetOriginalCode())
		local op=pextra:GetOperation()
		if op then
			op(pextra,tpnil,tp,0,nil,0,tp,c)
		end
	end
	
	--Step 8
	Duel.MoveToField(c,tp,tp,LOCATION_MZONE,POS_FACEDOWN_DEFENSE,false,0x1f)
	
	--Step 9
	c:SetStatus(STATUS_SUMMON_TURN,true)
	Duel.AdjustInstantly()
	local proc = aux.GetValueType(proc)=="Effect" and proc or nil
	Duel.RaiseEvent(c,EVENT_MSET,proc,0,tp,tp,0)
	
	return true
end

function Duel.GlitchySelectTribute(c,tp,min,max,toplayer,release_cards,release_cards_ex,release_cards_ex_oneof,release_param_list)
	local skip=0
	local temp_var={0}
	local peffect
	
	local selection
	local select_cards=Group.CreateGroup()
	local operated_set = Group.CreateGroup()
	--Step 0
	local result
	local ct=Duel.GetToFieldCount(c,toplayer,tp,LOCATION_REASON_TOFIELD,0x1f)
	if ct>0 then
		result=true
		skip=1
	else
		local rmax=0
		for pcard in aux.Next(release_cards) do
			if pcard:IsLocation(LOCATION_MZONE) and pcard:IsControler(toplayer) and (0x1f>>pcard:GetSequence())&1>0 then
				select_cards:AddCard(pcard)
			else
				local release_param=release_param_list[pcard]
				if aux.GetValueType(release_param)=="number" then
					rmax = rmax+release_param
				end
			end
		end
		
		if #release_cards_ex==0 and #release_cards_ex_oneof==0 and min>rmax then
			if rmax>0 then
				select_cards:Clear()
				for pcard in aux.Next(release_cards) do
					select_cards:AddCard(pcard)
				end
			end
			return Duel.SelectTribute(tp,c,min,max,select_cards,toplayer)
		end
		
		selection=select_cards:Select(tp,1,1,nil)
	end
	
	--Step 1
	if skip<1 then
		if not selection then return false end
		local pcard=selection:GetFirst()
		operated_set:AddCard(pcard)
		release_cards:RemoveCard(pcard)
		
		if min<=release_param_list[pcard] then
			if max>1 and #release_cards_ex==0 and (#release_cards>0 or #release_cards_ex_oneof>0) then
				result=Duel.SelectYesNo(tp,210)
			
			elseif max>1 and #release_cards_ex>0 then
				result=true
			
			else
				skip=8
			end
		else
			result=true
		end
	end
	
	--Step 2
	if skip<2 then
		if not result then
			skip=8
		else
			local fcount=Duel.GetMZoneLimit(toplayer,tp,LOCATION_REASON_TOFIELD)
			if #operated_set>0 then
				min = min - release_param_list[operated_set:GetFirst()]
				max = max-1
				fcount = fcount+1
			end
			
			if #release_cards_ex + #release_cards_ex_oneof==0 or fcount<=0 and min<2 then
				select_cards:Clear()
				for pcard in aux.Next(release_cards) do
					select_cards:AddCard(pcard)
				end
				selection=Duel.SelectTribute(tp,c,min,max,select_cards,toplayer)
				skip=7
			
			elseif #release_cards_ex >= max then
				select_cards:Clear()
				for pcard in aux.Next(release_cards_ex) do
					select_cards:AddCard(pcard)
				end
				selection=Duel.SelectTribute(tp,c,min,max,select_cards,toplayer)
				skip=7
			
			else
				local rmax=0
				for pcard in aux.Next(release_cards) do
					rmax = rmax + release_param_list[pcard]
				end
				for pcard in aux.Next(release_cards_ex) do
					rmax = rmax + release_param_list[pcard]
				end
				if rmax<min then
					result=true
					if rmax==0 and min==2 then
						temp_var[1]=1
					end
				
				elseif #release_cards_ex_oneof>0 then
					result=Duel.SelectYesNo(tp,92)
				
				else
					skip=4
				end
			end
		end
	end
	
	--Step 3
	if skip<3 then
		if not result then
			skip=4
		else
			select_cards:Clear()
			if temp_var[1]==0 then
				for pcard in aux.Next(release_cards_ex_oneof) do
					select_cards:AddCard(pcard)
				end
			else
				for pcard in aux.Next(release_cards_ex_oneof) do
					if release_param_list[pcard]==2 then
						select_cards:AddCard(pcard)
					end
				end
			end
			Duel.Hint(HINT_SELECTMSG,tp,500)
			selection=select_cards:Select(tp,1,1,nil)
		end
	end
	
	--Step 4
	if skip<4 then
		if not selection or #selection==0 then return false end
		local pcard=selection:GetFirst()
		operated_set:AddCard(pcard)
		peffect=c:IsHasEffect(EFFECT_EXTRA_RELEASE_SUM)
	end
	
	--Step 5
	if skip<5 then
		select_cards:Clear()
		for pcard in aux.Next(release_cards_ex) do
			select_cards:AddCard(pcard)
		end
		Duel.Hint(HINT_SELECTMSG,tp,500)
		selection=select_cards:Select(tp,#select_cards,#select_cards,nil)
	end
	
	--Step 6
	if skip<6 then
		if not selection or #selection==0 then return false end
		for tc in aux.Next(selection) do
			operated_set:AddCard(tc)
		end
		local rmin=#operated_set
		local rmax=0
		for pcard in aux.Next(operated_set) do
			rmax = rmax + release_param_list[pcard]
		end
		min = min - rmax
		max = max - rmin
		if min<0 then min=0 end
		if max<0 then max=0 end
		
		if min<=0 then
			if max>0 and #release_cards>0 then
				result=Duel.SelectYesNo(tp,210)
			else
				skip=8
			end
		else
			result=true
		end
	end
	
	--Step 7
	if skip<7 then
		if not result then
			skip=8
		else
			select_cards:Clear()
			for pcard in aux.Next(release_cards) do
				select_cards:AddCard(pcard)
			end
			Duel.Hint(HINT_SELECTMSG,tp,500)
			selection=Duel.SelectTribute(tp,c,min,max,select_cards,toplayer)
		end
	end
	
	--Step 8
	if skip<8 then
		if not selection or #selection==0 then return false end
		for tc in aux.Next(selection) do
			operated_set:AddCard(tc)
		end
	end
	
	--Step 9
	if peffect then
		peffect:UseCountLimit(tp)
	end
	
	return operated_set
end