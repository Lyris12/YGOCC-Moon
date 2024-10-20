--created by Meedogh, coded by Lyris
--Not yet finalized values
--Custom constants
EFFECT_PANDEMONIUM						=726
EFFECT_PANDEPEND_SCALE 					=727	--[[Allows to use a Pandemonium to complete a Pendulum Scale. The Pande must be located in the leftmost or rightmost S/T,
													and according to its position, it will use its left or right scale]]
EFFECT_KEEP_PANDEMONIUM_ON_FIELD 		=728	--[[The Pandemonium won't be sent to the ED after a successful Pande Summon. If an X value is set,
													the effect will wear off after the Xth Pande Summon with that Pandemonium]]
EFFECT_PANDEMONIUM_SUMMON_AFTERMATH 	=729	--Changes the operation that will be executed after a successful Pande Summon
EFFECT_ALLOW_EXTRA_PANDEMONIUM_ZONE 	=730	--[[(DUEL EFFECT) Allows to have multiple Pandemonium Cards as scales at the same time. By setting a target to the effect,
													you can choose which kind of cards can be face-up]]
EFFECT_EXTRA_PANDEMONIUM_SUMMON 		=731	--(DUEL EFFECT) Allows to execute multiple Pandemonium Summons during a turn. Works in the same way as EXTRA_PENDULUM_SUMMON
EFFECT_PANDEMONIUM_LEVEL				=732	--A monster with this effect can be treated as having this effect's value as Level for a Pandemonium Summon
EFFECT_DISABLE_PANDEMONIUM_SUMMON		=733	--A Pandemonium Scale with this effect won't be able to Pandemonium Summon monsters
EFFECT_EXTRA_PANDEMONIUM_SUMMON_LOCATION=734	--Allows to choose extra locations from which the user can Pandemonium Summon

TYPE_PANDEMONIUM						=0x200000000
TYPE_CUSTOM								=TYPE_CUSTOM|TYPE_PANDEMONIUM

CTYPE_PANDEMONIUM						=0x2
CTYPE_CUSTOM							=CTYPE_CUSTOM|CTYPE_PANDEMONIUM

LOCATION_PANDEZONE						=0x1000

SUMMON_TYPE_PANDEMONIUM					=SUMMON_TYPE_SPECIAL+726

--Custom Type Table
Auxiliary.Pandemoniums={} --number as index = card, card as index = function() is_pendulum

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_left_scale, get_right_scale, get_fusion_type, get_synchro_type, get_xyz_type, get_link_type, get_ritual_type = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetLeftScale, Card.GetRightScale, Card.GetFusionType, Card.GetSynchroType, Card.GetXyzType, Card.GetLinkType, Card.GetRitualType

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Pandemoniums[c] then
		tpe=tpe|TYPE_PANDEMONIUM
		local ispen,isspell=Auxiliary.Pandemoniums[c]()
		if not ispen then
			tpe=tpe&~TYPE_PENDULUM
		end
		if c:IsLocation(LOCATION_PZONE) and not isspell then
			tpe=tpe&~TYPE_SPELL
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Pandemoniums[c] then
		local typ=c:GetFlagEffectLabel(1074)
		tpe=tpe|TYPE_PANDEMONIUM|typ
		if not Auxiliary.Pandemoniums[c]() then
			tpe=tpe&~TYPE_PENDULUM
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Pandemoniums[c] then
		tpe=tpe|TYPE_PANDEMONIUM
		local ispen,isspell=Auxiliary.Pandemoniums[c]()
		if not ispen then
			tpe=tpe&~TYPE_PENDULUM
		end
		if c:IsPreviousLocation(LOCATION_PZONE) and not isspell then
			tpe=tpe&~TYPE_SPELL
		end
	end
	return tpe
end
Card.GetLeftScale=function(c)
	local scale=get_left_scale(c)
	if Auxiliary.Pandemoniums[c] then
		if c:IsHasEffect(EFFECT_CHANGE_LSCALE) then
			local tot=scale
			local egroup={c:IsHasEffect(EFFECT_CHANGE_LSCALE)}
			for _,te in ipairs(egroup) do
				local val=te:GetValue()
				if type(val)=='function' then
					tot=val(te,c)
				else
					tot=val
				end
			end
			return tot
		end
	end
	return scale
end
Card.GetRightScale=function(c)
	local scale=get_right_scale(c)
	if Auxiliary.Pandemoniums[c] then
		if c:IsHasEffect(EFFECT_CHANGE_RSCALE) then
			local tot=scale
			local egroup={c:IsHasEffect(EFFECT_CHANGE_RSCALE)}
			for _,te in ipairs(egroup) do
				local val=te:GetValue()
				if type(val)=='function' then
					tot=val(te,c)
				else
					tot=val
				end
			end
			return tot
		end
	end
	return scale
end
Card.GetFusionType=function(c)
	local tpe=get_fusion_type(c)
	if Auxiliary.Pandemoniums[c] then
		tpe=tpe|TYPE_PANDEMONIUM
		if not Auxiliary.Pandemoniums[c]() then
			tpe=tpe&~TYPE_PENDULUM
		end
	end
	return tpe
end
Card.GetSynchroType=function(c)
	local tpe=get_synchro_type(c)
	if Auxiliary.Pandemoniums[c] then
		tpe=tpe|TYPE_PANDEMONIUM
		if not Auxiliary.Pandemoniums[c]() then
			tpe=tpe&~TYPE_PENDULUM
		end
	end
	return tpe
end
Card.GetXyzType=function(c)
	local tpe=get_xyz_type(c)
	if Auxiliary.Pandemoniums[c] then
		tpe=tpe|TYPE_PANDEMONIUM
		if not Auxiliary.Pandemoniums[c]() then
			tpe=tpe&~TYPE_PENDULUM
		end
	end
	return tpe
end
Card.GetLinkType=function(c)
	local tpe=get_link_type(c)
	if Auxiliary.Pandemoniums[c] then
		tpe=tpe|TYPE_PANDEMONIUM
		if not Auxiliary.Pandemoniums[c]() then
			tpe=tpe&~TYPE_PENDULUM
		end
	end
	return tpe
end
Card.GetRitualType=function(c)
	local res=get_ritual_type(c)
	if Auxiliary.Pandemoniums[c] then
		tpe=tpe|TYPE_PANDEMONIUM
		if not Auxiliary.Pandemoniums[c]() then
			tpe=tpe&~TYPE_PENDULUM
		end
	end
	return tpe
end

--Location function
local _IsLocation, _GetLocation = Card.IsLocation, Card.GetLocation

Card.IsLocation = function(c,loc)
	if loc&LOCATION_PANDEZONE>0 and c:IsInPandemoniumZone() then
		return true
	end
	return _IsLocation(c,loc)
end
Card.GetLocation = function(c)
	local loc=_GetLocation(c)
	if c:IsInPandemoniumZone() then
		loc=loc|LOCATION_PANDEZONE
	end
	return loc
end

--Custom Functions
function Auxiliary.AddOrigPandemoniumType(c,ispendulum,is_spell)
	table.insert(Auxiliary.Pandemoniums,c)
	Auxiliary.Customs[c]=true
	local ispendulum=ispendulum==nil and false or ispendulum
	local is_spell=is_spell==nil and false or is_spell
	Auxiliary.Pandemoniums[c]=function() return ispendulum, is_spell end
end
function Auxiliary.EnablePandemoniumAttribute(c,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local t={...}
	local tclone={}
	local regfield,typ,actcon,actcost,hoptnum,acthopt,forced=nil,get_orig_type(c),nil,nil,1,nil,false
	for tt=1,#t do
		if type(t[tt])~='userdata' then
			table.insert(tclone,t[tt])
		end
	end
	if #tclone>=7 and type(t[#t])=='boolean' then
		forced=t[#t]
		table.remove(t)
	end
	if #tclone>=6 and type(t[#t])=='number' then
		acthopt=t[#t]
		table.remove(t)
	elseif #tclone>=6 and type(t[#t])=='boolean' then
		table.remove(t)
	end
	if #tclone>=5 and type(t[#t])=='number' then
		hoptnum=t[#t]
		table.remove(t)
	end
	if #tclone>=4 and type(t[#t])=='function' then
		actcost=t[#t]
		table.remove(t)
	elseif #tclone>=4 and type(t[#t])=='boolean' then
		table.remove(t)
	end
	if #tclone>=3 and type(t[#t])=='function' then
		actcon=t[#t]
		table.remove(t)
	elseif #tclone>=3 and type(t[#t])=='boolean' then
		table.remove(t)
	end
	if #tclone>=2 and type(t[#t])=='number' then
		typ=t[#t]&(~TYPE_PANDEMONIUM)
		table.remove(t)
	end
	if type(t[#t])=='boolean' then
		regfield=t[#t]
		table.remove(t)
	end
	if not PANDEMONIUM_CHECKLIST then
		PANDEMONIUM_CHECKLIST=0
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(Auxiliary.PandeReset)
		Duel.RegisterEffect(ge1,0)
	end
	--register og type
	c:RegisterFlagEffect(1074,0,EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE,0,typ)
	--summon
	local ge6=Effect.CreateEffect(c)
	ge6:SetType(EFFECT_TYPE_FIELD)
	ge6:SetDescription(1074)
	ge6:SetCode(EFFECT_SPSUMMON_PROC_G)
	ge6:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	ge6:SetRange(LOCATION_SZONE)
	ge6:SetCondition(Auxiliary.PandCondition)
	ge6:SetOperation(Auxiliary.PandOperation)
	ge6:SetValue(726)
	c:RegisterEffect(ge6)
	--add Pendulum-like redirect property
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetOperation(Auxiliary.PandEnConFUInED(typ))
	c:RegisterEffect(e0)
	--reset Pendulum-like redirect property
	local sp=Effect.CreateEffect(c)
	sp:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	sp:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	sp:SetCode(EVENT_SPSUMMON_SUCCESS)
	sp:SetCondition(Auxiliary.PandDisConFUInED)
	sp:SetOperation(Auxiliary.PandDisableFUInED(c,typ))
	c:RegisterEffect(sp)
	local th=Effect.CreateEffect(c)
	th:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	th:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	th:SetCode(EVENT_TO_HAND)
	th:SetCondition(Auxiliary.PandDisConFUInED)
	th:SetOperation(Auxiliary.PandDisableFUInED(c,typ))
	c:RegisterEffect(th)
	local td=th:Clone()
	td:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(td)
	local rem=th:Clone()
	rem:SetCode(EVENT_REMOVE)
	c:RegisterEffect(rem)
	local tg=th:Clone()
	tg:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(tg)
	--keep on field
	local kp=Effect.CreateEffect(c)
	kp:SetType(EFFECT_TYPE_SINGLE)
	kp:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(kp)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(Auxiliary.PandActCon(actcon))
	if actcost then
		e1:SetCost(actcost)
	end
	if acthopt then
		e1:SetCountLimit(hoptnum,acthopt)
	end
	if #t>0 then
		local flags=0
		for _,xe in ipairs(t) do
			if type(xe)=='userdata' and xe:GetProperty() then flags=flags|xe:GetProperty() end
		end
		e1:SetProperty(flags)
		e1:SetHintTiming(TIMING_DAMAGE_CAL+TIMING_DAMAGE_STEP)
	end
	e1:SetTarget(Auxiliary.PandActTarget(forced,table.unpack(t)))
	e1:SetOperation(Auxiliary.PandActOperation(table.unpack(t)))
	c:RegisterEffect(e1)
	--register by default
	if regfield==nil or regfield then
		--set
		local set=Effect.CreateEffect(c)
		set:SetDescription(1159)
		set:SetType(EFFECT_TYPE_FIELD)
		set:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		set:SetCode(EFFECT_SPSUMMON_PROC_G)
		set:SetRange(LOCATION_HAND)
		set:SetCondition(Auxiliary.PandSSetCon(c,-1))
		set:SetOperation(Auxiliary.PandSSet(c,REASON_RULE,typ))
		c:RegisterEffect(set)
	end
	Duel.AddCustomActivityCounter(10000000,ACTIVITY_SPSUMMON,Auxiliary.PaCheck)
	
	return e1
end
function Auxiliary.PaCheck(c)
	return not c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function Auxiliary.PandeReset(e,tp,eg,ep,ev,re,r,rp)
	PANDEMONIUM_CHECKLIST=0
end
function Auxiliary.PandePendSwitch(e,c,tp,sumtp,sumpos)
	return sumtp&SUMMON_TYPE_PENDULUM==SUMMON_TYPE_PENDULUM
end
function Auxiliary.PaConditionExtraFilterSpecific(c,e,tp,lscale,rscale,te)
	if not te then return true end
	local f=te:GetValue()
	return not f or f(te,c,e,tp,lscale,rscale)
end
function Auxiliary.PaConditionExtraFilter(c,e,tp,lscale,rscale,eset)
	for _,te in ipairs(eset) do
		if Auxiliary.PaConditionExtraFilterSpecific(c,e,tp,lscale,rscale,te) then return true end
	end
	return false
end
function Auxiliary.PaConditionFilter(c,e,tp,lscale,rscale,eset)
	local lv,lcheck,extraloc_check=0,false,false
	if c.pandemonium_level then
		lv=c.pandemonium_level
	else
		lv=c:GetLevel()
	end
	if c:IsHasEffect(EFFECT_PANDEMONIUM_LEVEL) then
		local egroup={c:IsHasEffect(EFFECT_PANDEMONIUM_LEVEL)}
		for _,te in ipairs(egroup) do
			local lval=te:GetValue()
			if type(lval)=='function' then
				if (lval(te,c)>lscale and lval(te,c)<rscale) then
					lcheck=true
				end
			else
				if (lval>lscale and lval<rscale) then
					lcheck=true
				end
			end
		end
	end
	local locgroup={e:GetHandler():IsHasEffect(EFFECT_EXTRA_PANDEMONIUM_SUMMON_LOCATION)}
	for _,lte in ipairs(locgroup) do
		local ltg=lte:GetValue()
		if ltg and ltg(1,c,e,tp,lscale,rscale,eset) then
			extraloc_check=true
		end
	end
	return ((c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM))) or extraloc_check)
		and ((lv>lscale and lv<rscale) or lcheck) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL+726,tp,false,false)
		and not c:IsForbidden()
		and (PANDEMONIUM_CHECKLIST&(0x1<<tp)==0 or Auxiliary.PaConditionExtraFilter(c,e,tp,lscale,rscale,eset))
end
function Auxiliary.PandCondition(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PANDEMONIUM_SUMMON)}
	if (PANDEMONIUM_CHECKLIST&(0x1<<tp)~=0 and #eset==0) or Duel.GetCustomActivityCount(10000000,tp,ACTIVITY_SPSUMMON)~=0 then return false end
	local lscale=c:GetLeftScale()
	local rscale=c:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local loc=0
	if c:IsHasEffect(EFFECT_EXTRA_PANDEMONIUM_SUMMON_LOCATION) then
		local egroup={c:IsHasEffect(EFFECT_EXTRA_PANDEMONIUM_SUMMON_LOCATION)}
		for _,te in ipairs(egroup) do
			local locval=te:GetValue()
			if locval and type(locval)=='function' then
				local func=locval(0,c,te,tp,lscale,rscale,eset)
				loc=loc|func
			else
				loc=loc
			end
		end
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_HAND end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc|LOCATION_EXTRA end
	if loc==0 then return false end
	local g=nil
	if og then
		g=og:Filter(Card.IsLocation,nil,loc)
	else
		g=Duel.GetFieldGroup(tp,loc,0)
	end
	return aux.PandActCheck(e) and g:IsExists(Auxiliary.PaConditionFilter,1,nil,e,tp,lscale,rscale,eset) and not c:IsHasEffect(EFFECT_DISABLE_PANDEMONIUM_SUMMON)
end
function Auxiliary.PandOperation(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	local lscale=c:GetLeftScale()
	local rscale=c:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PANDEMONIUM_SUMMON)}
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp)
	local ft=Duel.GetUsableMZoneCount(tp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		ft=1
	end
	local loc=0
	local loclimit,max_eloc,locfilter,excfilter=nil,99,nil,nil
	if c:IsHasEffect(EFFECT_EXTRA_PANDEMONIUM_SUMMON_LOCATION) then
		local egroup={c:IsHasEffect(EFFECT_EXTRA_PANDEMONIUM_SUMMON_LOCATION)}
		for _,te in ipairs(egroup) do
			local locval=te:GetValue()
			if locval and type(locval)=='function' then
				local func=locval(0,c,te,tp,lscale,rscale,eset)
				loc=loc|func
				loclimit=locval(2,c,te,tp,lscale,rscale,eset)
				locfilter=locval(3,c,te,tp,lscale,rscale,eset)
				excfilter=locval(4,c,te,tp,lscale,rscale,eset)
			else
				loc=loc
			end
		end
	end
	if ft1>0 then loc=loc|LOCATION_HAND end
	if ft2>0 then loc=loc|LOCATION_EXTRA end
	local tg=nil
	if og then
		tg=og:Filter(Card.IsLocation,nil,loc):Filter(Auxiliary.PaConditionFilter,nil,e,tp,lscale,rscale,eset)
	else
		tg=Duel.GetMatchingGroup(Auxiliary.PaConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
	end 
	ft1=math.min(ft1,tg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA))
	ft2=math.min(ft2,tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect and ect<ft2 then ft2=ect end
	local ce=nil
	local b1=PANDEMONIUM_CHECKLIST&(0x1<<tp)==0
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
		tg=tg:Filter(Auxiliary.PaConditionExtraFilterSpecific,nil,e,tp,lscale,rscale,ce)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Auxiliary.GCheckAdditional=aux.PendOperationCheck(ft1,ft2,ft)
	if type(loclimit)=='table' then
		for loclim,maxct in pairs(loclimit) do
			if Duel.SelectYesNo(tp,aux.Stringid(8017339,2)) then
				local exg=tg:FilterSelect(tp,Auxiliary.ExtraPandeLocationFilter,1,maxct,nil,loclim,locfilter,e,tp,lscale,rscale,eset,tg)
				exg:KeepAlive()
				if #exg>0 then
					local exclude=tg:Filter(Auxiliary.ExtraPandeLocationFilter,exg,loclim,locfilter,e,tp,lscale,rscale,eset,tg)
					if excfilter~=nil then
						local prv=tg:FilterSelect(tp,Auxiliary.ExtraPandeLocationFilterPreserveFromExclusion,1,1,exg,excfilter,e,tp,lscale,rscale,eset,tg)
						exg:Merge(prv)
						local excg=tg:Filter(Auxiliary.ExtraPandeLocationFilterPreserveFromExclusion,exg,excfilter,e,tp,lscale,rscale,eset,tg)
						exclude:Merge(excg)
					end
					tg:Sub(exclude)
				end
			else
				local exclude=tg:Filter(Auxiliary.ExtraPandeLocationFilter,nil,loclim,locfilter,e,tp,lscale,rscale,eset,tg)
				tg:Sub(exclude)
			end
		end
	end
	local g=tg:SelectSubGroup(tp,aux.TRUE,true,1,math.min(#tg,ft))
	Auxiliary.GCheckAdditional=nil
	if not g then return end
	if ce then
		Duel.Hint(HINT_CARD,0,ce:GetOwner():GetOriginalCode())
		ce:Reset()
	else
		PANDEMONIUM_CHECKLIST=PANDEMONIUM_CHECKLIST|(0x1<<tp)
	end
	sg:Merge(g)
	if #sg>0 then
		Duel.HintSelection(Group.FromCards(c))
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e0:SetReset(RESET_PHASE+PHASE_END)
		e0:SetTargetRange(1,0)
		e0:SetTarget(Auxiliary.PandePendSwitch)
		Duel.RegisterEffect(e0,tp)
		local pcheck=true
		if c:IsHasEffect(EFFECT_KEEP_PANDEMONIUM_ON_FIELD) then
			local pgroup={c:IsHasEffect(EFFECT_KEEP_PANDEMONIUM_ON_FIELD)}
			for _,pte in ipairs(pgroup) do
				local pval=pte:GetValue()
				if not pval then
					pcheck=false
				elseif pval>0 then
					if c:GetFlagEffect(728)<=0 then
						c:RegisterFlagEffect(728,RESET_EVENT+RESETS_STANDARD,0,1)
					end
					c:SetFlagEffectLabel(728,pval-1)
					if c:GetFlagEffect(728)>0 then
						pcheck=false
					end
				else
					pcheck=true
				end
			end
		end
		if pcheck then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SPSUMMON)
			e1:SetRange(LOCATION_SZONE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_SPECIAL+726) end)
			e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
								local c=e:GetHandler()
								if c:IsHasEffect(EFFECT_PANDEMONIUM_SUMMON_AFTERMATH) then
									local pgroup={c:IsHasEffect(EFFECT_PANDEMONIUM_SUMMON_AFTERMATH)}
									local list,echeck={},{}
									for _,pte in ipairs(pgroup) do
										local desc=pte:GetDescription()
										table.insert(list,desc)
										table.insert(echeck,pte)
									end
									if #list>1 then
										local opt=Duel.SelectOption(tp,table.unpack(list))+1
										local effect=echeck[opt]
										local op=effect:GetOperation()
										if op then
											op(e,tp,eg,ep,ev,re,r,rp)
										end
									else
										local effect=echeck[1]
										local op=effect:GetOperation()
										if op then
											op(e,tp,eg,ep,ev,re,r,rp)
										end
									end
								else
									Duel.Destroy(e:GetHandler(),REASON_RULE)
								end
							end)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
function Auxiliary.ExtraPandeLocationFilter(c,loclim,efilter,e,tp,lscale,rscale,eset,tg)
	return c:IsLocation(loclim) and (not efilter or efilter(c,e,tp,lscale,rscale,eset,tg))
end
function Auxiliary.ExtraPandeLocationFilterPreserveFromExclusion(c,excfilter,e,tp,lscale,rscale,eset,tg)
	return not excfilter or excfilter(c,e,tp,lscale,rscale,eset,tg)
end
function Auxiliary.PaCheckFilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM) and c:GetFlagEffect(726)>0
end
function Card.IsInPandemoniumZone(c)
	return Auxiliary.PaCheckFilter(c)
end
function Auxiliary.PandActCon(actcon,card)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				if card then c=card end
				local check=false
				if c:IsHasEffect(EFFECT_ALLOW_EXTRA_PANDEMONIUM_ZONE) then
					check=true
				end
				return (check or not Duel.IsExistingMatchingCard(Auxiliary.PaCheckFilter,tp,LOCATION_SZONE,0,1,card))
					and (not actcon or actcon(e,tp,eg,ep,ev,re,r,rp))
			end
end
function Auxiliary.PandEnConFUInED(tpe)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				if (e:GetHandler():GetFlagEffect(706)>0 or e:GetHandler():GetFlagEffect(726)>0) and e:GetHandler():GetDestination()~=LOCATION_GRAVE then
					Auxiliary.PandDisableFUInED(e:GetHandler(),tpe)(e,tp,eg,ep,ev,re,r,rp)
				elseif e:GetHandler():GetDestination()==LOCATION_GRAVE then
					Auxiliary.PandEnableFUInED(e:GetHandler(),e:GetHandler():GetReason(),tpe)(e,tp,eg,ep,ev,re,r,rp)
				else
					return
				end
	end
end
function Auxiliary.PandEnableFUInED(tc,reason,tpe)
	if not tpe then tpe=TYPE_EFFECT|TYPE_PANDEMONIUM end
	return  function(e,tp,eg,ep,ev,re,r,rp)
				if pcall(Group.GetFirst,tc) then
					local tg=tc:Clone()
					for cc in aux.Next(tg) do
						cc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER|tpe|TYPE_PENDULUM)
						if not cc:IsOnField() or cc:GetDestination()==0 then
							if (cc:GetFlagEffect(706)>0 or cc:GetFlagEffect(726)>0) then
								cc:RegisterFlagEffect(716,RESET_EVENT+RESETS_STANDARD-RESET_TODECK,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
							end
							Duel.SendtoExtraP(cc,nil,reason)
						end
					end
				else
					tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER|tpe|TYPE_PENDULUM)
					if not tc:IsOnField() or tc:GetDestination()==0 then
						if (tc:GetFlagEffect(706)>0 or tc:GetFlagEffect(726)>0) then
							tc:RegisterFlagEffect(716,RESET_EVENT+RESETS_STANDARD-RESET_TODECK,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
						end
						Duel.SendtoExtraP(tc,nil,reason)
					end
				end
			end
end
function Auxiliary.PandDisConFUInED(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
function Auxiliary.PandDisableFUInED(tc,tpe)
	if not tpe then tpe=TYPE_EFFECT|TYPE_PANDEMONIUM end
	return  function(e,tp,eg,ep,ev,re,r,rp)
				tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER|tpe)
			end
end
function Auxiliary.PandSSetCon(tc,player,...)
	local params,loc1,loc2,neglect_zone={...},0xff,0xff,false
	if type(params[#params])=='boolean' then
		neglect_zone=params[#params]
		table.remove(params)
	end
	if type(params[#params])=='number' then
		loc1=params[#params]
		if #params-1>0 and type(params[#params-1])=='number' then
			loc2=loc1
			loc1=params[#params-1]
			table.remove(params)
		end
		table.remove(params)
	end
	if player==-1 then
		return	function(e,c,og)
					if c==nil then return true end
					local ttp=c:GetControler()
					local check=true
					local egroup={Duel.IsPlayerAffectedByEffect(ttp,EFFECT_CANNOT_SSET)}
					for _,te in ipairs(egroup) do
						local tg=te:GetTarget()
						if not tg then
							check=false
						elseif tc and aux.GetValueType(tc)=="Card" and tg(te,tc,ttp) then
							check=false
						elseif tc and type(tc)=="function" then
							local ct=0
							local sg=Duel.GetMatchingGroup(tc,ttp,loc1,loc2,nil,te,ttp)
							local tsg=sg:GetFirst()
							while tsg do
								if tg(te,tsg) then
									ct=ct+1
								end
								tsg=sg:GetNext()
							end
							if ct==#sg then check=false end
						else
							if not tc then
								check=false
							end
						end
					end
					return (neglect_zone or Duel.GetLocationCount(ttp,LOCATION_SZONE)>0) and check
				end
	else
		return	function()
					local ttp=player
					if not ttp or ttp<0 then
						ttp=tc:GetControler()
					end
					local check=true
					local egroup={Duel.IsPlayerAffectedByEffect(ttp,EFFECT_CANNOT_SSET)}
					for _,te in ipairs(egroup) do
						local tg=te:GetTarget()
						if not tg then
							check=false
						elseif tc and aux.GetValueType(tc)=="Card" and tg(te,tc,ttp) then
							check=false
						elseif tc and type(tc)=="function" then
							local ct=0
							local sg=Duel.GetMatchingGroup(tc,ttp,loc1,loc2,nil,te,ttp,e)
							local tsg=sg:GetFirst()
							while tsg do
								if tg(te,tsg) then
									ct=ct+1
								end
								tsg=sg:GetNext()
							end
							if ct==#sg then check=false end
						else
							if not tc then
								check=false
							end
						end
					end
					return (neglect_zone or Duel.GetLocationCount(ttp,LOCATION_SZONE)>0) and check
				end
	end
end	
function Auxiliary.PandSSetFilter(f,...)
	local params={...}
	return	function(c,...)
				return c:IsPandemoniumSSetable() and (not f or f(c,...))
			end
end
function Card.IsPandemoniumSSetable(c,ignore_zone_check,tp)
	if not c:IsType(TYPE_PANDEMONIUM) or c:IsForbidden() then return false end
	local tp=tp or c:GetControler()
	
	if not ignore_zone_check and Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
	if c:IsForbidden() then return false end
	if c:IsHasEffect(EFFECT_CANNOT_SSET) then return false end
	
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_SSET)}
	for _,e in ipairs(eset) do
		local tg=e:GetTarget()
		if not tg or tg(e,c,tp) then
			return false
		end
	end
	
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SSET_COST)}
	for _,e in ipairs(eset) do
		local cost=e:GetCost()
		if not cost(e,c,tp) then
			return false
		end
	end
	
	return true
end	


function Auxiliary.GetOriginalPandemoniumType(c)
	return c:GetFlagEffectLabel(1074)
end
function Card.GetOriginalPandemoniumType(c)
	return c:GetFlagEffectLabel(1074)
end
function Duel.PandSSet(tc,e,tp,reason,tpe)
	if not tpe then tpe=tc:GetOriginalPandemoniumType() end
	return aux.PandSSet(tc,reason,tpe)(e,tp)
end
function Auxiliary.PandSSet(tc,reason,tpe)
	return  function(e,tp,eg,ep,ev,re,r,rp,c)
				local res=0
				if not pcall(Group.GetFirst,tc) then tc=Group.CreateGroup(tc) end
				local mixedset=false
				local sg=Group.CreateGroup()
				sg:KeepAlive()
				local tg=tc:Clone()
				
				local effects_not_to_reset={}
				
				for cc in aux.Next(tg) do
					if not tpe then
						tpe=aux.GetOriginalPandemoniumType(cc)
					end
					if cc:IsType(TYPE_PANDEMONIUM) or cc:GetFlagEffect(706)>0 then
						local e1
						if cc:IsLocation(LOCATION_HAND) then
							for _,ce in ipairs({cc:IsHasEffect(EFFECT_CHANGE_TYPE)}) do
								if ce:GetType()==EFFECT_TYPE_SINGLE and ce:GetOwner()==cc then
									table.insert(effects_not_to_reset,ce)
								end
							end
							e1=Effect.CreateEffect(cc)
							e1:SetType(EFFECT_TYPE_SINGLE)
							e1:SetCode(EFFECT_MONSTER_SSET)
							e1:SetValue(TYPE_TRAP)
							e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
							cc:RegisterEffect(e1,true)
						else
							cc:SetCardData(CARDDATA_TYPE,TYPE_TRAP)
						end
						
						if cc:IsLocation(LOCATION_SZONE) then
							Duel.ChangePosition(cc,POS_FACEDOWN_ATTACK)
							Duel.RaiseEvent(cc,EVENT_SSET,e,reason,tp,tp,0)
							cc:RegisterFlagEffect(706,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1)
							if e1 then
								e1:Reset()
							end
						else								
							sg:AddCard(cc)
						end
						
					elseif cc:IsType(TYPE_SPELL+TYPE_TRAP) and cc:GetFlagEffect(706)<=0 then
						if not mixedset then mixedset=true end
						sg:AddCard(cc)
					end
				end
				if #sg>0 then
					res=Duel.SSet(tp,sg,tp,false)
					for cc in aux.Next(sg) do
						local tpe = tpe~=nil and tpe or aux.GetOriginalPandemoniumType(cc)
						if cc:IsType(TYPE_PANDEMONIUM) then
							if cc:GetOriginalType()&TYPE_TRAP==0 then
								cc:SetCardData(CARDDATA_TYPE,TYPE_TRAP)
							end
							cc:RegisterFlagEffect(706,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE,1)
							for _,ce in ipairs({cc:IsHasEffect(EFFECT_CHANGE_TYPE)}) do
								if ce:GetType()==EFFECT_TYPE_SINGLE and ce:GetOwner()==cc and not aux.FindInTable(effects_not_to_reset,ce) then
									local val=ce:GetValue()
									if val==TYPE_TRAP then
										ce:Reset()
									end
								end
							end
							if not cc:IsLocation(LOCATION_SZONE) then
								local edcheck=0
								if cc:IsLocation(LOCATION_EXTRA) then edcheck=TYPE_PENDULUM end
								cc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER|tpe|edcheck)
							end
						end
					end
				end
				if reason&REASON_RULE==0 then
					Duel.ConfirmCards(1-tp,sg)
				end
				return res
			end
end
function Auxiliary.PandActCheck(e)
	local c=e:GetHandler()
	return e:IsHasType(EFFECT_TYPE_ACTIVATE) or c:GetFlagEffect(726)>0
end
function Auxiliary.PandActTarget(forced,...)
	local fx={...}
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					if not forced then
						return true
					else
						if #fx==0 then return true end
						for i,xe in ipairs(fx) do
							local tg=xe:GetTarget()
							if tg and tg(e,tp,eg,ep,ev,re,r,rp,0) then
								return true
							end
						end
						return false
					end
				end
				local c=e:GetHandler()
				c:RegisterFlagEffect(726,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE,1)
				if #fx==0 then
					e:SetCategory(0)
					e:SetProperty(0)
					e:SetLabel(0)
					return
				end
				local ops={}
				local t={}
				local cost=nil
				local tg=nil
				for i,xe in ipairs(fx) do
					local condition=xe:GetCondition()
					local code=xe:GetCode()
					local check_own_label=xe:GetLabelObject()
					if check_own_label then
						e:SetLabelObject(check_own_label)
					end
					cost=xe:GetCost()
					tg=xe:GetTarget()
					local tchk=(code==EVENT_FREE_CHAIN or Duel.CheckEvent(code))
					if code==EVENT_CHAINING then
						tchk=(tchk or Duel.GetCurrentChain()>1)
						ev=Duel.GetCurrentChain()-1
						re=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
						eg=re:GetHandler()
					end
					if tchk and xe:CheckCountLimit(tp) and (not condition or condition(e,tp,eg,ep,ev,re,r,rp))
						and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0))
						and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)) then
						table.insert(ops,xe:GetDescription())
					else table.insert(ops,1214) end
					table.insert(t,xe)
				end
				local op=0
				if #ops>1 then
					if forced then
						op=Duel.SelectOption(tp,table.unpack(ops))
					else
						op=Duel.SelectOption(tp,1214,table.unpack(ops))
					end
					if ops[op]==1214 then op=0 end
				elseif ops[1]~=1214 then
					if forced then 
						op=1
					else 
						if Duel.SelectYesNo(tp,94) then 
							op=1 
						end
					end
				end
				if op>0 then
					local xe=t[op]
					xe:UseCountLimit(tp)
					local confirm_own_label=xe:GetLabelObject()
					if confirm_own_label then
						e:SetLabelObject(confirm_own_label)
					end
					e:SetCategory(xe:GetCategory())
					cost=xe:GetCost()
					if cost then cost(e,tp,eg,ep,ev,re,r,rp,1) end
					tg=xe:GetTarget()
					if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
					c:RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,65)
				else
					e:SetCategory(0)
					e:SetLabel(0)
				end
				e:SetLabel(op)
			end
end
function Auxiliary.PandActOperation(...)
	local fx={...}
	return  function(e,tp,eg,ep,ev,re,r,rp)
				if e:GetLabel()==0 then return end
				local xe=fx[e:GetLabel()]
				if xe:GetCode()==EVENT_CHAINING then
					ev=Duel.GetCurrentChain()-1
					re=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
					eg=re:GetHandler()
				end
				local confirm_own_label=xe:GetLabelObject()
				if confirm_own_label then
					e:SetLabelObject(confirm_own_label)
				end
				local op=xe:GetOperation()
				if op then op(e,tp,eg,ep,ev,re,r,rp) end
			end
end
function Auxiliary.PandAct(tc,...)
	local funs={...}
	local player,zonechk=funs[1],funs[2]
	return  function(e,tp,eg,ep,ev,re,r,rp)
				local p,zone=tp,0xff
				if player then p=player end
				if zonechk then zone=zonechk end
				if not tc:IsLocation(LOCATION_SZONE) then
					Duel.MoveToField(tc,tp,p,LOCATION_SZONE,POS_FACEUP,true,zone)
					if not tc:IsLocation(LOCATION_SZONE) then
						local edcheck=0
						if tc:IsLocation(LOCATION_EXTRA) then edcheck=TYPE_PENDULUM end
						tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER|edcheck|aux.GetOriginalPandemoniumType(tc))
						return
					else
						tc:SetCardData(CARDDATA_TYPE,TYPE_TRAP)
					end
				end
				tc:RegisterFlagEffect(726,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE,1)
			end
end
function Duel.ActivatePandemonium(tc,tp,up,zone,fromfield)
	local up=up or tp
	local zone=zone or 0xff
	if not tc:IsLocation(LOCATION_SZONE) then
		Duel.MoveToField(tc,tp,p,LOCATION_SZONE,POS_FACEUP,true,zone)
		if not tc:IsLocation(LOCATION_SZONE) then
			local edcheck=0
			if tc:IsLocation(LOCATION_EXTRA) then edcheck=TYPE_PENDULUM end
			tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER|edcheck|aux.GetOriginalPandemoniumType(tc))
			return
		else
			tc:SetCardData(CARDDATA_TYPE,TYPE_TRAP)
		end
	end
	tc:RegisterFlagEffect(726,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE,1)
end

function Card.IsPandemoniumActivatable(c,tp,fp,neglect_loc,neglect_cond,neglect_cost,neglect_targ,eg,ep,ev,re,r,rp,...)
	local x={...}
	local neglect_dstep = #x>0 and x[1]
	local neglect_dcal = #x>1 and x[2]
	
	if not fp then fp=tp end
	local e=c:GetActivateEffect()
	if not c:IsType(TYPE_PANDEMONIUM) then return false end
	
	c:AssumeProperty(ASSUME_TYPE,TYPE_TRAP)
	if c:IsForbidden() or c:IsHasEffect(EFFECT_CANNOT_TRIGGER) then return false end
	if not c:CheckUniqueOnField(fp) then return false end
	
	for _,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ACTIVATE)}) do
		local value=pe:GetValue()
		if not value or type(value)=="number" then
			return false
		elseif type(value)=="function" and value(pe,e,tp) then
			return false
		end
	end
	if not e:CheckCountLimit(tp) or e:GetHandlerPlayer()~=tp then return false end
	
	local ph=Duel.GetCurrentPhase()
	if not neglect_dstep and ph==PHASE_DAMAGE then
		if (e:GetCode()<EVENT_BATTLE_START or e:GetCode()>=EVENT_TOSS_DICE) and not e:IsHasProperty(EFFECT_FLAG_DAMAGE_STEP) then return false end
	elseif not neglect_dcal and ph==PHASE_DAMAGE_CAL then
		if (e:GetCode()<EVENT_PRE_DAMAGE_CALCULATE or e:GetCode()>EVENT_PRE_BATTLE_DAMAGE) and not e:IsHasProperty(EFFECT_FLAG_DAMAGE_CAL) then return false end
	end
	
	local zone=0xff
	local zonechk=true
	if e:IsHasProperty(EFFECT_FLAG_LIMIT_ZONE) then
		local zfun=e:GetValue()
		if type(zfun)=="function" then
			zone=zfun(e,tp,eg,ep,ev,re,r,rp)
		elseif type(zfun)=="number" then
			zone=zfun
		end
		if c:IsLocation(LOCATION_SZONE) then
			local z = (fp==self_reference_effect:GetHandlerPlayer()) and 0x1<<c:GetSequence() or 0x1<<(c:GetSequence()+16)
			zonechk = zone&z>0
		end
	end
	local ecode=0
	if c:IsLocation(LOCATION_SZONE) then
		if c:IsFaceup() or c:GetEquipTarget() or not zonechk then return false end
		if c:IsStatus(STATUS_SET_TURN) then
			ecode=EFFECT_TRAP_ACT_IN_SET_TURN
		end
	elseif c:IsLocation(LOCATION_HAND) and not neglect_loc then
		ecode=EFFECT_TRAP_ACT_IN_HAND
	end
	if ecode>0 then
		local available=false
		for _,ce in ipairs{c:IsHasEffect(ecode)} do
			if ce:CheckCountLimit(tp) and (not ce:GetCondition() or ce:GetCondition()(ce)) then
				available=true
				break
			end
		end
		if not available then
			return false
		end
	end
	
	for _,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_ACTIVATE_COST)}) do
		local acpcost,acptg=pe:GetCost(),pe:GetTarget()
		if not acptg or not acptg(pe,e,tp) then
			return false
		end
		if not acpcost or not acpcost(pe,e,tp) then
			return false
		end
	end
	
	local cond,cost,targ=e:GetCondition(),e:GetCost(),e:GetTarget()
	if not neglect_cond and cond and not cond(e,tp,eg,ep,ev,re,r,rp) then
		return false
	end
	if not neglect_cost and cost and not cost(e,tp,eg,ep,ev,re,r,rp,0) then
		return false
	end
	if not neglect_targ and targ and not targ(e,tp,eg,ep,ev,re,r,rp,0) then
		return false
	end
	
	return true
end

--Cost handling
local _IsAbleToExtra, _IsAbleToGraveAsCost = Card.IsAbleToExtra, Card.IsAbleToGraveAsCost

Card.IsAbleToExtra = function(c)
	if c:GetOriginalType()&TYPE_PANDEMONIUM>0 then
		return not c:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(current_triggering_player,c)
	else
		return _IsAbleToExtra(c)
	end
end

Card.IsAbleToGraveAsCost = function(c)
	if c:GetOriginalType()&TYPE_PANDEMONIUM>0 and c:IsOnField() and c:IsAbleToExtra() then
		return false
	else
		return _IsAbleToGraveAsCost(c)
	end
end

----------EFFECT_PANDEPEND_SCALE-------------
-- function Auxiliary.PandePendScale(c,seq)
	-- return Auxiliary.PaCheckFilter(c) and c:IsHasEffect(EFFECT_PANDEPEND_SCALE) and c:GetSequence()==math.abs(4-seq)
-- end
-- Auxiliary.PendCondition=function()
	-- return	function(e,c,og)
				-- if c==nil then return true end
				-- local tp=c:GetControler()
				-- local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
				-- --if PENDULUM_CHECKLIST&(0x1<<tp)~=0 and #eset==0 then return false end
				-- if Auxiliary.PendulumChecklist&(0x1<<tp)~=0 and #eset==0 then return false end
				-- local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				-- if (rpz==nil or rpz:IsType(TYPE_PANDEMONIUM)) and Duel.IsExistingMatchingCard(Auxiliary.PandePendScale,tp,LOCATION_SZONE,0,1,c,c:GetSequence()) then
					-- rpz=Duel.GetMatchingGroup(Auxiliary.PandePendScale,tp,LOCATION_SZONE,0,c,c:GetSequence()):GetFirst()
				-- end
				-- if rpz==nil or c==rpz then return false end
				-- local lscale=c:GetLeftScale()
				-- local rscale=rpz:GetRightScale()
				-- if rpz:IsType(TYPE_PANDEMONIUM) and rpz:IsHasEffect(EFFECT_PANDEPEND_SCALE) then
					-- local val=0
					-- if rpz:GetSequence()==0 then val=rpz:GetLeftScale() else val=rpz:GetRightScale() end
					-- local pgroup={rpz:IsHasEffect(EFFECT_PANDEPEND_SCALE)}
					-- for _,te in ipairs(pgroup) do
						-- local pval=te:GetValue()
						-- if pval then
							-- if type(pval)=='function' then
								-- val=math.max(val,pval(te,tp))
							-- else
								-- val=math.max(val,pval)
							-- end
						-- end
					-- end
					-- rscale=val
				-- end			
				-- if lscale>rscale then lscale,rscale=rscale,lscale end
				-- local loc=0
				-- if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
				-- if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
				-- if loc==0 then return false end
				-- local g=nil
				-- if og then
					-- g=og:Filter(Card.IsLocation,nil,loc)
				-- else
					-- g=Duel.GetFieldGroup(tp,loc,0)
				-- end
				-- return g:IsExists(Auxiliary.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
			-- end
-- end
-- Auxiliary.PendOperation=function()
	-- return	function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
				-- local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				-- if (rpz==nil or rpz:IsType(TYPE_PANDEMONIUM)) and Duel.IsExistingMatchingCard(Auxiliary.PandePendScale,tp,LOCATION_SZONE,0,1,c,c:GetSequence()) then
					-- rpz=Duel.GetMatchingGroup(Auxiliary.PandePendScale,tp,LOCATION_SZONE,0,c,c:GetSequence()):GetFirst()
				-- end
				-- local lscale=c:GetLeftScale()
				-- local rscale=rpz:GetRightScale()
				-- if rpz:IsType(TYPE_PANDEMONIUM) and rpz:IsHasEffect(EFFECT_PANDEPEND_SCALE) then
					-- local val=0
					-- if rpz:GetSequence()==0 then val=rpz:GetLeftScale() else val=rpz:GetRightScale() end
					-- local pgroup={rpz:IsHasEffect(EFFECT_PANDEPEND_SCALE)}
					-- for _,te in ipairs(pgroup) do
						-- local pval=te:GetValue()
						-- if pval then
							-- if type(pval)=='function' then
								-- val=math.max(val,pval(te,tp))
							-- else
								-- val=math.max(val,pval)
							-- end
						-- end
					-- end
					-- rscale=val
				-- end			
				-- if lscale>rscale then lscale,rscale=rscale,lscale end
				-- local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
				-- local tg=nil
				-- local loc=0
				-- local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
				-- local ft2=Duel.GetLocationCountFromEx(tp)
				-- local ft=Duel.GetUsableMZoneCount(tp)
				-- local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
				-- if ect and ect<ft2 then ft2=ect end
				-- if Duel.IsPlayerAffectedByEffect(tp,59822133) then
					-- if ft1>0 then ft1=1 end
					-- if ft2>0 then ft2=1 end
					-- ft=1
				-- end
				-- if ft1>0 then loc=loc|LOCATION_HAND end
				-- if ft2>0 then loc=loc|LOCATION_EXTRA end
				-- if og then
					-- tg=og:Filter(Card.IsLocation,nil,loc):Filter(Auxiliary.PConditionFilter,nil,e,tp,lscale,rscale,eset)
				-- else
					-- tg=Duel.GetMatchingGroup(Auxiliary.PConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
				-- end
				-- local ce=nil
				-- --local b1=PENDULUM_CHECKLIST&(0x1<<tp)==0
				-- local b1=Auxiliary.PendulumChecklist&(0x1<<tp)==0
				-- local b2=#eset>0
				-- if b1 and b2 then
					-- local options={1163}
					-- for _,te in ipairs(eset) do
						-- table.insert(options,te:GetDescription())
					-- end
					-- local op=Duel.SelectOption(tp,table.unpack(options))
					-- if op>0 then
						-- ce=eset[op]
					-- end
				-- elseif b2 and not b1 then
					-- local options={}
					-- for _,te in ipairs(eset) do
						-- table.insert(options,te:GetDescription())
					-- end
					-- local op=Duel.SelectOption(tp,table.unpack(options))
					-- ce=eset[op+1]
				-- end
				-- if ce then
					-- tg=tg:Filter(Auxiliary.PConditionExtraFilterSpecific,nil,e,tp,lscale,rscale,ce)
				-- end
				-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				-- Auxiliary.GCheckAdditional=Auxiliary.PendOperationCheck(ft1,ft2,ft)
				-- local g=tg:SelectSubGroup(tp,aux.TRUE,true,1,math.min(#tg,ft))
				-- Auxiliary.GCheckAdditional=nil
				-- if not g then return end
				-- if ce then
					-- Duel.Hint(HINT_CARD,0,ce:GetOwner():GetOriginalCode())
					-- ce:Reset()
				-- else
					-- --PENDULUM_CHECKLIST=PENDULUM_CHECKLIST|(0x1<<tp)
					-- Auxiliary.PendulumChecklist=Auxiliary.PendulumChecklist|(0x1<<tp)
				-- end
				-- sg:Merge(g)
				-- Duel.HintSelection(Group.FromCards(c))
				-- Duel.HintSelection(Group.FromCards(rpz))
			-- end
-- end