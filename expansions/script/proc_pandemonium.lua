--created by Meedogh, coded by Lyris
--Not yet finalized values
--Custom constants
EFFECT_PANDEMONIUM						=726
EFFECT_PANDEPEND_SCALE 					=727	--Allows to use a Pandemonium to complete a Pendulum Scale. The Pande must be located in the leftmost or rightmost S/T, and according to its position, it will use its left or right scale
EFFECT_KEEP_PANDEMONIUM_ON_FIELD 		=728	--The Pandemonium won't be sent to the ED after a successful Pande Summon. If an X value is set, the effect will wear off after the Xth Pande Summon with that Pandemonium
EFFECT_PANDEMONIUM_SUMMON_AFTERMATH 	=729	--Changes the operation that will be executed after a successful Pande Summon
EFFECT_ALLOW_EXTRA_PANDEMONIUM_ZONE 	=730	--(DUEL EFFECT) Allows to have multiple Pandemonium Cards as scales at the same time. By setting a target to the effect, you can choose which kind of cards can be face-up
EFFECT_EXTRA_PANDEMONIUM_SUMMON 		=731	--(DUEL EFFECT) Allows to execute multiple Pandemonium Summons during a turn. Works in the same way as EXTRA_PENDULUM_SUMMON
EFFECT_PANDEMONIUM_LEVEL				=732	--A monster with this effect can be treated as having this effect's value as Level for a Pandemonium Summon
EFFECT_DISABLE_PANDEMONIUM_SUMMON		=733	--A Pandemonium Scale with this effect won't be able to Pandemonium Summon monsters
EFFECT_EXTRA_PANDEMONIUM_SUMMON_LOCATION=734	--Allows to choose extra locations from which the user can Pandemonium Summon
TYPE_PANDEMONIUM						=0x200000000
TYPE_CUSTOM								=TYPE_CUSTOM|TYPE_PANDEMONIUM
CTYPE_PANDEMONIUM						=0x2
CTYPE_CUSTOM							=CTYPE_CUSTOM|CTYPE_PANDEMONIUM
SUMMON_TYPE_PANDEMONIUM					=SUMMON_TYPE_SPECIAL+726

--Custom Type Table
Auxiliary.Pandemoniums={} --number as index = card, card as index = function() is_pendulum

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_left_scale, get_right_scale = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetLeftScale, Card.GetRightScale

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
		tpe=tpe|TYPE_PANDEMONIUM
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
	local regfield,typ,actcon,actcost,hoptnum,acthopt,forced=nil,TYPE_PANDEMONIUM+TYPE_EFFECT,nil,nil,1,nil,false
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
		typ=t[#t]|TYPE_PANDEMONIUM
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
	c:RegisterFlagEffect(1074,0,0,0,typ)
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
function Auxiliary.PandActCon(actcon,card)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				if card then c=card end
				local check=false
				if c:IsHasEffect(EFFECT_ALLOW_EXTRA_PANDEMONIUM_ZONE) then
					check=true
				end
				return (not Duel.IsExistingMatchingCard(Auxiliary.PaCheckFilter,tp,LOCATION_SZONE,0,1,card) or check)
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
						cc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER+tpe+TYPE_PENDULUM)
						if not cc:IsOnField() or cc:GetDestination()==0 then
							if (cc:GetFlagEffect(706)>0 or cc:GetFlagEffect(726)>0) then
								cc:RegisterFlagEffect(716,RESET_EVENT+RESETS_STANDARD-RESET_TODECK,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
							end
							Duel.SendtoExtraP(cc,nil,reason)
						end
					end
				else
					tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER+tpe+TYPE_PENDULUM)
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
				tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER+tpe)
			end
end
function Auxiliary.PandSSetCon(tc,player,...)
	local params,loc1,loc2={...},0xff,0xff
	if type(params[#params])=='number' then
		loc1=params[#params]
		if #params-1>0 and type(params[#params-1])=='number' then
			loc2=loc1
			loc1=params[#params-1]
			table.remove(params)
		end
		table.remove(params)
	end
	return	function(c,e,tp,eg,ep,ev,re,r,rp)
				local eparams={}
				local ttp
				if (player==nil or not player) then ttp=tp else if player<0 then ttp=tc:GetControler() end end
				if #params>0 then
					for pc=1,#params do
						if params[pc]=="e" then eparams[pc]=e
						elseif params[pc]=="tp" then eparams[pc]=ttp
						elseif params[pc]=="eg" then eparams[pc]=eg
						elseif params[pc]=="ep" then eparams[pc]=ep
						elseif params[pc]=="ev" then eparams[pc]=ev
						elseif params[pc]=="re" then eparams[pc]=re
						elseif params[pc]=="r" then eparams[pc]=r
						elseif params[pc]=="rp" then eparams[pc]=rp
						else eparams[pc]=params[pc]
						end
					end
				end
				local check=true
				local egroup={Duel.IsPlayerAffectedByEffect(ttp,EFFECT_CANNOT_SSET)}
				for _,te in ipairs(egroup) do
					local tg=te:GetTarget()
					if not tg then
						check=false
					elseif tc and type(tc)=="function" then
						local ct=0
						local sg=Duel.GetMatchingGroup(tc,ttp,loc1,loc2,nil,table.unpack(eparams))
						local tsg=sg:GetFirst()
						while tsg do
							if tg(te,tsg) then
								ct=ct+1
							end
							tsg=sg:GetNext()
						end
						if ct==#sg then check=false end
					elseif tc and tg(te,tc) then
						check=false
					else
						if not tc then
							check=false
						end
					end
				end
				return Duel.GetLocationCount(ttp,LOCATION_SZONE)>0 and check
			end
end	
function Auxiliary.PandSSetFilter(tc,...)
	local params={...}
	return	function(c,e,tp,eg,ep,ev,re,r,rp)
				local eparams={}
				if #params>0 then
					for pc=1,#params do
						if params[pc]=="e" then eparams[pc]=e
						elseif params[pc]=="tp" then eparams[pc]=tp
						elseif params[pc]=="eg" then eparams[pc]=eg
						elseif params[pc]=="ep" then eparams[pc]=ep
						elseif params[pc]=="ev" then eparams[pc]=ev
						elseif params[pc]=="re" then eparams[pc]=re
						elseif params[pc]=="r" then eparams[pc]=r
						elseif params[pc]=="rp" then eparams[pc]=rp
						else eparams[pc]=params[pc]
						end
					end
				end
				return (not tc or tc(c,e,tp,eg,ep,ev,re,r,rp)) and Auxiliary.PandSSetCon(c,nil,table.unpack(eparams))(nil,e,tp,eg,ep,ev,re,r,rp)
			end
end
function Auxiliary.PandSSet(tc,reason,tpe)
	if not tpe then tpe=TYPE_EFFECT end
	return  function(e,tp,eg,ep,ev,re,r,rp,c)
				if pcall(Group.GetFirst,tc) then
					local tg=tc:Clone()
					for cc in aux.Next(tg) do
						local hand_chk=true
						if not cc:IsLocation(LOCATION_HAND) then
							hand_chk=false
							cc:SetCardData(CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
						end
						local e1=Effect.CreateEffect(cc)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_MONSTER_SSET)
						e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
						cc:RegisterEffect(e1,true)
						if cc:IsLocation(LOCATION_SZONE) then
							--if cc:IsCanTurnSet() then
								Duel.ChangePosition(cc,POS_FACEDOWN_ATTACK)
								Duel.RaiseEvent(cc,EVENT_SSET,e,reason,cc:GetControler(),cc:GetControler(),0)
								cc:RegisterFlagEffect(706,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1)
							--end
						else Duel.SSet(cc:GetControler(),cc,cc:GetControler(),false) cc:RegisterFlagEffect(706,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1) end
						e1:Reset()
						if hand_chk then
							cc:SetCardData(CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
						end
						if not cc:IsLocation(LOCATION_SZONE) then
							local edcheck=0
							if cc:IsLocation(LOCATION_EXTRA) then edcheck=TYPE_PENDULUM end
							cc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER+tpe+edcheck)
						end
					end
				else
					local hand_chk=true
					if not tc:IsLocation(LOCATION_HAND) then
						hand_chk=false
						tc:SetCardData(CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
					end
					local e1=Effect.CreateEffect(tc)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_MONSTER_SSET)
					e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
					tc:RegisterEffect(e1,true)
					if tc:IsLocation(LOCATION_SZONE) then
						if tc:IsCanTurnSet() then
							Duel.ChangePosition(tc,POS_FACEDOWN_ATTACK)
							Duel.RaiseEvent(tc,EVENT_SSET,e,reason,tc:GetControler(),tc:GetControler(),0)
							tc:RegisterFlagEffect(706,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1)
						end
					else Duel.SSet(tc:GetControler(),tc,tc:GetControler(),false) tc:RegisterFlagEffect(706,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1) end
					e1:Reset()
					if hand_chk then
						tc:SetCardData(CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
					end
					if not tc:IsLocation(LOCATION_SZONE) then
						local edcheck=0
						if tc:IsLocation(LOCATION_EXTRA) then edcheck=TYPE_PENDULUM end
						tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER+tpe+edcheck)
					end
				end
			end
end
function Auxiliary.PandActCheck(e)
	local c=e:GetHandler()
	return e:IsHasType(EFFECT_TYPE_ACTIVATE) or c:GetFlagEffect(726)>0
end
function Auxiliary.PandActTarget(forced,...)
	local fx={...}
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return true end
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
	local player,zonechk,fromfield=funs[1],funs[2],funs[3]
	return  function(e,tp,eg,ep,ev,re,r,rp)
				local p,zone=tp,0xff
				if player then p=player end
				if zonechk then zone=zonechk end
				tc:SetCardData(CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
				if not tc:IsOnField() or fromfield then
					Duel.MoveToField(tc,tp,p,LOCATION_SZONE,POS_FACEUP,true,zone)
					if not tc:IsLocation(LOCATION_SZONE) then
						local edcheck=0
						if tc:IsLocation(LOCATION_EXTRA) then edcheck=TYPE_PENDULUM end
						tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER+TYPE_EFFECT+edcheck+aux.GetOriginalPandemoniumType(tc))
						return
					end
				end
				tc:RegisterFlagEffect(726,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE,1)
			end
end
function Auxiliary.GetOriginalPandemoniumType(c)
	return c:GetFlagEffectLabel(1074)
end

----------EFFECT_PANDEPEND_SCALE-------------
function Auxiliary.PandePendScale(c,seq)
	return Auxiliary.PaCheckFilter(c) and c:IsHasEffect(EFFECT_PANDEPEND_SCALE) and c:GetSequence()==math.abs(4-seq)
end
Auxiliary.PendCondition=function()
	return	function(e,c,og)
				if c==nil then return true end
				local tp=c:GetControler()
				local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
				--if PENDULUM_CHECKLIST&(0x1<<tp)~=0 and #eset==0 then return false end
				if Auxiliary.PendulumChecklist&(0x1<<tp)~=0 and #eset==0 then return false end
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				if (rpz==nil or rpz:IsType(TYPE_PANDEMONIUM)) and Duel.IsExistingMatchingCard(Auxiliary.PandePendScale,tp,LOCATION_SZONE,0,1,c,c:GetSequence()) then
					rpz=Duel.GetMatchingGroup(Auxiliary.PandePendScale,tp,LOCATION_SZONE,0,c,c:GetSequence()):GetFirst()
				end
				if rpz==nil or c==rpz then return false end
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				if rpz:IsType(TYPE_PANDEMONIUM) and rpz:IsHasEffect(EFFECT_PANDEPEND_SCALE) then
					local val=0
					if rpz:GetSequence()==0 then val=rpz:GetLeftScale() else val=rpz:GetRightScale() end
					local pgroup={rpz:IsHasEffect(EFFECT_PANDEPEND_SCALE)}
					for _,te in ipairs(pgroup) do
						local pval=te:GetValue()
						if pval then
							if type(pval)=='function' then
								val=math.max(val,pval(te,tp))
							else
								val=math.max(val,pval)
							end
						end
					end
					rscale=val
				end			
				if lscale>rscale then lscale,rscale=rscale,lscale end
				local loc=0
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
				if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
				if loc==0 then return false end
				local g=nil
				if og then
					g=og:Filter(Card.IsLocation,nil,loc)
				else
					g=Duel.GetFieldGroup(tp,loc,0)
				end
				return g:IsExists(Auxiliary.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
			end
end
Auxiliary.PendOperation=function()
	return	function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				if (rpz==nil or rpz:IsType(TYPE_PANDEMONIUM)) and Duel.IsExistingMatchingCard(Auxiliary.PandePendScale,tp,LOCATION_SZONE,0,1,c,c:GetSequence()) then
					rpz=Duel.GetMatchingGroup(Auxiliary.PandePendScale,tp,LOCATION_SZONE,0,c,c:GetSequence()):GetFirst()
				end
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				if rpz:IsType(TYPE_PANDEMONIUM) and rpz:IsHasEffect(EFFECT_PANDEPEND_SCALE) then
					local val=0
					if rpz:GetSequence()==0 then val=rpz:GetLeftScale() else val=rpz:GetRightScale() end
					local pgroup={rpz:IsHasEffect(EFFECT_PANDEPEND_SCALE)}
					for _,te in ipairs(pgroup) do
						local pval=te:GetValue()
						if pval then
							if type(pval)=='function' then
								val=math.max(val,pval(te,tp))
							else
								val=math.max(val,pval)
							end
						end
					end
					rscale=val
				end			
				if lscale>rscale then lscale,rscale=rscale,lscale end
				local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
				local tg=nil
				local loc=0
				local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
				local ft2=Duel.GetLocationCountFromEx(tp)
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
					tg=og:Filter(Card.IsLocation,nil,loc):Filter(Auxiliary.PConditionFilter,nil,e,tp,lscale,rscale,eset)
				else
					tg=Duel.GetMatchingGroup(Auxiliary.PConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
				end
				local ce=nil
				--local b1=PENDULUM_CHECKLIST&(0x1<<tp)==0
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
					ce:Reset()
				else
					--PENDULUM_CHECKLIST=PENDULUM_CHECKLIST|(0x1<<tp)
					Auxiliary.PendulumChecklist=Auxiliary.PendulumChecklist|(0x1<<tp)
				end
				sg:Merge(g)
				Duel.HintSelection(Group.FromCards(c))
				Duel.HintSelection(Group.FromCards(rpz))
			end
end