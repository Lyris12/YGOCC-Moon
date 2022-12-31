--Groundhoard Burrown
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--summon proc
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabelObject(c)
	e2:SetCondition(s.nscon)
	e2:SetOperation(s.nsop)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.mattg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--grant effect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
--SUMMON PROC
function s.nscon(e,tp)
	local c=e:GetHandler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsBurrownSummonable()
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Summon(tp,c,false,nil)
	if c:IsLocation(LOCATION_MZONE) then
		local e1=Effect.CreateEffect(e:GetLabelObject())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST))
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	return false
end
function s.mattg(e,c)
	return c:GetType()&0x20004==0x20004 and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:GetOriginalRace()&RACE_BEAST==RACE_BEAST
end

--GRANT EFFECT
function s.filter(c)
	return c:IsFaceup() and s.mattg(nil,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.efilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	if not c:IsRelateToChain(0) or not tc or not tc:IsFaceup() or not tc:IsRelateToChain(0) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.zntg)
	e1:SetOperation(s.znop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
function s.zntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_COUNT)<=0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_COUNT)<=0 then return false end
		local check=false
		for i=0,4 do
			if Duel.CheckLocation(tp,LOCATION_MZONE,i) and Duel.CheckLocation(1-tp,LOCATION_MZONE,4-i) then
				check=true
				break
			end
		end
		return check
	end
	local zone=0
	for i=0,4 do
		if Duel.CheckLocation(tp,LOCATION_MZONE,i) and Duel.CheckLocation(1-tp,LOCATION_MZONE,4-i) then
			zone=zone|(0x1<<i)
		end
	end
	local dis1=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,EXTRA_MONSTER_ZONE|(~zone),false)
	local czone=0x1<<(math.log(dis1,2)*-1+20)
	local dis2=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,EXTRA_MONSTER_ZONE|(~czone),false)
	Duel.Hint(HINT_ZONE,tp,dis1|dis2)
	e:SetLabel(dis1|dis2)
end
function s.znop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.disop(e,tp)
	return e:GetLabel()
end

function Card.IsBurrownSummonable(c)
	local tp=c:GetControler()
	if not c:IsSummonableCard() or c:IsForbidden() then return false end
	if not c:IsHasEffect(EFFECT_EXTRA_SUMMON_COUNT) and not Duel.CheckSummonedCount(c) then return false end
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
	local res=c:BurrownFilterSummonProc(tp,peset)
	if #peset==0 and (aux.GetValueType(res)=="boolean" and not res or aux.GetValueType(res)=="number" and res==-2) then
		return false
	end
	
	return true				
end	
function Card.BurrownFilterSummonProc(c,tp,peset)
	if c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC) then
		for _,ce in ipairs({c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC)}) do
			if ce and ce.SetLabel then
				if c:CheckBurrownSummonProc(ce,tp) then
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
			if c:CheckBurrownSummonProc(ce,tp) then
				table.insert(peset,ce)
			end
		end
	end
	if not Duel.IsPlayerCanSummon(tp,SUMMON_TYPE_NORMAL,c) or not c:CheckUniqueOnField(tp,LOCATION_MZONE) then return false end
	
	local rcount=c:GetBurrownSummonTributeCount()
	local min=rcount&0xffff
	local max=(rcount>>16)&0xffff
	if not Duel.IsPlayerCanSummon(tp,SUMMON_TYPE_ADVANCE,c) then max=0 end
	if min<0 then min=0 end
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
			if Duel.BurrownCheckTribute(c,new_min_tribute,max,nil,tp,new_zone,releasable,0) then
				return true
			end
		end
	
	else
		return Duel.BurrownCheckTribute(c,min,max,nil,tp,0x1f,0xff00ff,0)
	end
	
	return false
end
function Card.CheckBurrownSummonProc(c,ce,tp)
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
			if new_min_tribute<0 then new_min_tribute=0 end
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
function Card.GetBurrownSummonTributeCount(c)
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
function Duel.BurrownCheckTribute(c,min,max,mg,toplayer,zone,releasable,pos)
	local ex=false
	local sump=c:GetControler()
	if toplayer==1-sump then ex=true end
	local release_list,ex_list=Group.CreateGroup(),Group.CreateGroup()
	release_list:KeepAlive()
	ex_list:KeepAlive()
	local m,release_list,ex_list=Duel.GetBurrownSummonTributeList(c,release_list,ex_list,nil,mg,ex,releasable,pos)
	if max>m then
		max=m
	end
	if min>max then
		return false
	end
	
	zone = zone & 0x1f
	local s=0
	local ct=Duel.GetBurrownToFieldCount(c,toplayer,sump,LOCATION_REASON_TOFIELD,zone)
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
	local fcount=Duel.GetBurrownMZoneLimit(toplayer,sump,LOCATION_REASON_TOFIELD)
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
function Duel.GetBurrownSummonTributeList(c,release_list,ex_list,ex_list_oneof,mg,ex,releasable,pos,getparams)
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
				ex_set=ce:BurrownFilterInRangeCards(ex_set)
			end
		end
	end
	
	local rcount=0
	local release_param_list={}
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	for tc in aux.Next(g) do
		if (releasable>>tc:GetSequence())&1>0 and tc:IsBurrownReleasableBySummon(tp,c) then
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
		if (releasable>>(tc:GetSequence()+16))&1>0 and tc:IsBurrownReleasableBySummon(tp,c) then
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
		if not tc:IsLocation(LOCATION_MZONE) and tc:IsBurrownReleasableBySummon(tp,c) then
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
function Effect.BurrownFilterInRangeCards(e,set)
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
function Duel.BurrownFilterMustUseMZone(tp,up,r,c,flag)
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
function Card.IsBurrownReleasableBySummon(c,tp,tc)
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
function Duel.GetBurrownToFieldCount(c,tp,up,r,zone)
	local _,flag=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD)
	flag = ~flag
	flag=Duel.BurrownFilterMustUseMZone(tp,up,r,c,flag)
	flag = (flag|~zone)&0x1f
	
	local field_used_count = {0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5}
	return 5-field_used_count[flag+1]
end
function Duel.GetBurrownMZoneLimit(tp,up,r)
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