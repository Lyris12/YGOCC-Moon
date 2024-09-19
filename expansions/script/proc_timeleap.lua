--created by Swag, coded by Glitchy, edited by Lyris
--Not yet finalized values
--Custom constants
EFFECT_CANNOT_BE_TIMELEAP_MATERIAL			=825
EFFECT_MUST_BE_TIMELEAP_MATERIAL			=826
EFFECT_FUTURE								=827
EFFECT_EXTRA_TIMELEAP_MATERIAL				=828
EFFECT_EXTRA_TIMELEAP_SUMMON				=829
EFFECT_IGNORE_TIMELEAP_HOPT					=830
EFFECT_IGNORE_TIMELEAP_CONDITION			=100000136
EFFECT_IGNORE_TIMELEAP_MATERIAL_REQ			=100000137
EFFECT_IGNORE_TIMELEAP_FUTURE_REQ			=100000138
EFFECT_TIMELEAP_CUSTOM_MATERIAL_OPERATION	=100000139

TYPE_TIMELEAP						=0x10000000000
TYPE_CUSTOM							=TYPE_CUSTOM|TYPE_TIMELEAP
CTYPE_TIMELEAP						=0x100
CTYPE_CUSTOM						=CTYPE_CUSTOM|CTYPE_TIMELEAP

SUMMON_TYPE_TIMELEAP				=SUMMON_TYPE_SPECIAL+825

REASON_TIMELEAP	=0x10000000000

--flag for Cerulean Sea Siren
FLAG_CERULEAN_SEA_SIREN = 100000148

--Custom Type Table
Auxiliary.Timeleaps={} --number as index = card, card as index = function() is_synchro
table.insert(aux.CannotBeEDMatCodes,EFFECT_CANNOT_BE_TIMELEAP_MATERIAL)

--overwrite constants
TYPE_EXTRA							=TYPE_EXTRA|TYPE_TIMELEAP

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_level, get_syn_level, get_rit_level, get_orig_level, is_xyz_level, 
	get_prev_level_field, is_level, is_level_below, is_level_above, get_reason, syn_target, get_fusion_type, get_synchro_type, get_xyz_type, get_link_type, get_ritual_type = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetLevel, 
	Card.GetSynchroLevel, Card.GetRitualLevel, Card.GetOriginalLevel, Card.IsXyzLevel, Card.GetPreviousLevelOnField, Card.IsLevel, Card.IsLevelBelow, Card.IsLevelAbove, Card.GetReason, Auxiliary.SynTarget,
	Card.GetFusionType, Card.GetSynchroType, Card.GetXyzType, Card.GetLinkType, Card.GetRitualType

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Timeleaps[c] then
		tpe=tpe|TYPE_TIMELEAP
		if not Auxiliary.Timeleaps[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Timeleaps[c] then
		tpe=tpe|TYPE_TIMELEAP
		if not Auxiliary.Timeleaps[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Timeleaps[c] then
		tpe=tpe|TYPE_TIMELEAP
		if not Auxiliary.Timeleaps[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetLevel=function(c)
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return 0 end
	return get_level(c)
end
Card.GetRitualLevel=function(c,rc)
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return 0 end
	return get_rit_level(c,rc)
end
Card.GetSynchroLevel=function(c,sc)
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return 0 end
	return get_syn_level(c,sc)
end
Card.GetOriginalLevel=function(c)
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return 0 end
	return get_orig_level(c)
end
Card.IsXyzLevel=function(c,xyz,lv)
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return false end
	return is_xyz_level(c,xyz,lv)
end
Card.GetPreviousLevelOnField=function(c)
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return 0 end
	return get_prev_level_field(c)
end
Card.IsLevel=function(c,...)
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return false end
	local funs={...}
	for key,value in pairs(funs) do
		if c:GetLevel()==value then return true end
	end
	return false
end
Card.IsLevelBelow=function(c,lv)
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return false end
	return is_level_below(c,lv)
end
Card.IsLevelAbove=function(c,lv)
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return false end
	return is_level_above(c,lv)
end
Card.GetReason=function(c)
	local rs=get_reason(c)
	local rc=c:GetReasonCard()
	if rc and Auxiliary.Timeleaps[rc] then
		rs=rs|REASON_TIMELEAP
	end
	return rs
end
Auxiliary.SynTarget=function(f1,f2,minc,maxc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
				local res=syn_target(f1,f2,minc,maxc)(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
				local g=e:GetLabelObject()
				if g and g:IsExists(function(tc) return Auxiliary.Timeleaps[tc] and not Auxiliary.Timeleaps[tc]() end,1,nil) then
					g:DeleteGroup()
					res=false
				end
				return res
	end
end
Card.GetFusionType=function(c)
	local tpe=get_fusion_type(c)
	if Auxiliary.Timeleaps[c] then
		tpe=tpe|TYPE_TIMELEAP
		if not Auxiliary.Timeleaps[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetSynchroType=function(c)
	local tpe=get_synchro_type(c)
	if Auxiliary.Timeleaps[c] then
		tpe=tpe|TYPE_TIMELEAP
		if not Auxiliary.Timeleaps[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetXyzType=function(c)
	local tpe=get_xyz_type(c)
	if Auxiliary.Timeleaps[c] then
		tpe=tpe|TYPE_TIMELEAP
		if not Auxiliary.Timeleaps[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetLinkType=function(c)
	local tpe=get_link_type(c)
	if Auxiliary.Timeleaps[c] then
		tpe=tpe|TYPE_TIMELEAP
		if not Auxiliary.Timeleaps[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetRitualType=function(c)
	local res=get_ritual_type(c)
	if Auxiliary.Timeleaps[c] then
		tpe=tpe|TYPE_TIMELEAP
		if not Auxiliary.Timeleaps[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end

--Custom Functions
function Card.CheckTimeleapMaterialLevel(c,tl)
	local ft=tl:GetFuture()
	return c:IsLevel(ft-1)
end
function Card.IsCanBeTimeleapMaterial(c,ec,...)
	local x={...}
	-- local exctyp=#x>0 and x[1] or nil
	-- --if not c:IsAbleToRemove() then return false end
	-- if not exctyp then
		-- if c:IsType(TYPE_LINK|TYPE_XYZ) then return false end
	-- end
	local tef={c:IsHasEffect(EFFECT_CANNOT_BE_TIMELEAP_MATERIAL)}
	for _,te in ipairs(tef) do
		if (type(te:GetValue())=="function" and te:GetValue()(te,ec)) or te:GetValue()==1 then return false end
	end
	return true
end
function Auxiliary.AddOrigTimeleapType(c,issynchro)
	table.insert(Auxiliary.Timeleaps,c)
	Auxiliary.Customs[c]=true
	local issynchro=issynchro==nil and false or issynchro
	Auxiliary.Timeleaps[c]=function() return issynchro end
end
function Auxiliary.AddTimeleapProc(c,futureval,sumcon,filter,custom_matop,customop,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	
	local t={...}
	local list={}
	local min,max=1,1
	if #t>0 then
		for i=1,#t do
			if type(t[#t])=='number' then
				max=t[#t]
				table.remove(t)
				if type(t[#t])=='number' then
					min=t[#t]
					table.remove(t)
				else
					min=max
					max=99
				end
				table.insert(list,{t[#t],min,max})
				table.remove(t)
			end
		end
	else
		table.insert(list,{999,min,max})
	end
	if sumcon then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_REGULAR_TIMELEAP_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_EXTRA)
		e1:SetCondition(Auxiliary.TimeleapCondition(sumcon,filter,customop,table.unpack(list)))
		e1:SetTarget(Auxiliary.TimeleapTarget(sumcon,filter,customop,table.unpack(list)))
		e1:SetOperation(Auxiliary.TimeleapOperation(customop))
		e1:SetValue(SUMMON_TYPE_TIMELEAP)
		c:RegisterEffect(e1)
        local mt=getmetatable(c)
        mt.timeleap_proc=e1
        mt.timeleap_condition=sumcon
        mt.timeleap_filter=filter
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_FUTURE)
	e2:SetValue(futureval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--remember previous Future on field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE)
	e4:SetOperation(aux.UpdateLastFutureOnField)
	c:RegisterEffect(e4)
	if custom_matop then
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
		e5:SetCode(EFFECT_TIMELEAP_CUSTOM_MATERIAL_OPERATION)
		e5:SetOperation(custom_matop[1])
		e5:SetValue(custom_matop[2])
		c:RegisterEffect(e5)
	end
end
function Auxiliary.TimeleapCondition(sumcon,filter,customop,...)
	local funs={...}
	return  function(e,c,matg)
				if c==nil then return true end
				if (c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_PANDEMONIUM)) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				
				local f
				local custom_matop=c:IsHasEffect(EFFECT_TIMELEAP_CUSTOM_MATERIAL_OPERATION)
				if custom_matop then
					f=custom_matop:GetValue()
				else
					f=Card.IsAbleToRemove
				end
				
				local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_TIMELEAP_SUMMON)}
				local exsumcheck=false
				for _,te in ipairs(eset) do
					if not te:GetValue() or type(te:GetValue())=="number" or te:GetValue()(e,c) then
						exsumcheck=true
					end
				end
				
				eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_IGNORE_TIMELEAP_HOPT)}
				local ignsumcheck=false
				for _,te in ipairs(eset) do
					if te:CheckCountLimit(tp) then
						ignsumcheck=true
						break
					end
				end
				
				local mg,mg2
				if matg and aux.GetValueType(matg)=="Group" then
					mg=matg:Filter(Card.IsCanBeTimeleapMaterial,nil,c):Filter(aux.Faceup(f),nil,e,tp)
					mg2=matg:Filter(Auxiliary.TimeleapExtraFilter,nil,nil,c,tp,table.unpack(funs))			
				else
					mg=Duel.GetMatchingGroup(Card.IsCanBeTimeleapMaterial,tp,LOCATION_MZONE,0,nil,c):Filter(aux.Faceup(f),nil,e,tp)
					mg2=Duel.GetMatchingGroup(Auxiliary.TimeleapExtraFilter,tp,0xff,0xff,nil,nil,c,tp,table.unpack(funs))
				end
				if #mg2>0 then mg:Merge(mg2) end
				local fg=aux.GetMustMaterialGroup(tp,EFFECT_MUST_BE_TIMELEAP_MATERIAL)
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				--Duel.SetSelectedCard(fg)
				return (not sumcon or sumcon(e,c,tp) or mg:IsExists(aux.IgnoreTimeleapCondFilter,1,nil,c,e,tp))
					and (Duel.GetFlagEffect(tp,828)<=0 or (exsumcheck and Duel.GetFlagEffect(tp,830)<=0) or c:IsHasEffect(EFFECT_IGNORE_TIMELEAP_HOPT) or ignsumcheck)
					and mg:IsExists(Auxiliary.TimeleapMaterialFilter,1,nil,filter,e,tp,Group.CreateGroup(),mg,fg,c,0,sumcon,table.unpack(funs))
			end
end
function Auxiliary.IgnoreTimeleapCondFilter(c,tl,e,tp,sg)
	local eset={c:IsHasEffect(EFFECT_IGNORE_TIMELEAP_CONDITION)}
	for _,ce in ipairs(eset) do
		local val=ce:GetValue()
		if not val or type(val)=="number" or (type(val)=="function" and val(ce,c,tl,e,tp,sg)) then
			return true
		end
	end
	return false
end
function Auxiliary.IgnoreTimeleapMatReqFilter(c,tl,e,tp,sg)
	local eset={c:IsHasEffect(EFFECT_IGNORE_TIMELEAP_MATERIAL_REQ)}
	for _,ce in ipairs(eset) do
		local val=ce:GetValue()
		if not val or type(val)=="number" or (type(val)=="function" and val(ce,c,tl,e,tp,sg)) then
			return true
		end
	end
	return false
end
function Auxiliary.IgnoreTimeleapFutReqFilter(c,tl,e,tp,sg)
	local eset={c:IsHasEffect(EFFECT_IGNORE_TIMELEAP_FUTURE_REQ)}
	for _,ce in ipairs(eset) do
		local val=ce:GetValue()
		if not val or type(val)=="number" or (type(val)=="function" and val(ce,c,tl,e,tp,sg)) then
			return true
		end
	end
	return false
end
function Auxiliary.TimeleapExtraFilter(c,f,lc,tp,...)
	if c:IsLocation(LOCATION_ONFIELD) and not c:IsFaceup() then return false end
	local flist={...}
	local check=false
	if (not f or f(c)) then check=true end
	for i=1,#flist do
		if flist[i][1]~=999 and flist[i][1](c) then
			check=true
		end
	end
	local tef1={c:IsHasEffect(EFFECT_EXTRA_TIMELEAP_MATERIAL,tp)}
	local ValidSubstitute=false
	for _,te1 in ipairs(tef1) do
		local val=te1:GetValue()
		if (not val or val(te1,c,ec,1)) then ValidSubstitute=true end
	end
	if not ValidSubstitute then return false end
	return c:IsCanBeTimeleapMaterial(lc) and check
end
function Auxiliary.TimeleapMaterialFutureRequirement(c,tl)
	return c:HasLevel() and c:GetLevel()==tl:GetFuture()-1
end
function Auxiliary.TimeleapMaterialFilter(c,filter,e,tp,sg,mg,fg,tl,ct,sumcon,...)
	sg:AddCard(c)
	ct=ct+1
	local funs,max,chk={...},1
	local override_future_check=false
	if type(filter)=="table" then
		override_future_check=filter[2]
		filter=filter[1]
	end
	if (not filter or filter(c,e,mg,tl,tp) or aux.IgnoreTimeleapMatReqFilter(c,tl,e,tp,sg))
	and (override_future_check or aux.TimeleapMaterialFutureRequirement(c,tl) or aux.IgnoreTimeleapFutReqFilter(c,tl,e,tp,sg)) then
		chk=true
	end
	if #funs>0 then
		for i=1,#funs do
			if funs[i][1]~=999 then 
				max=max+funs[i][3]
			else
				max=funs[i][3]
			end
			if funs[i][1]~=999 and funs[i][1](c,e,mg) then
				chk=true
			end
		end
	end
	if max>99 then max=99 end
	local res=chk and (Auxiliary.TimeleapCheckGoal(filter,e,tp,sg,fg,tl,ct,sumcon,table.unpack(funs))
		or (ct<max and mg:IsExists(Auxiliary.TimeleapMaterialFilter,1,sg,filter,e,tp,sg,mg,fg,tl,ct,sumcon,table.unpack(funs))))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.TimeleapCheckGoal(filter,e,tp,sg,fg,tl,ct,sumcon,...)
	local funs,min={...},1
	if #funs>0 then
		for i=1,#funs do
			if funs[i][1]~=999 and not sg:IsExists(funs[i][1],funs[i][2],nil) then return false end
			if funs[i][1]~=999 then 
				min=min+funs[i][2]
			else
				min=funs[i][2]
			end
		end
	end
	tl:RegisterFlagEffect(FLAG_CERULEAN_SEA_SIREN,0,0,1)
	local res = ct>=min and (not fg or not fg:IsExists(aux.MustMaterialCounterFilter,1,nil,sg))
		and (not sumcon or sumcon(e,tl,tp,sg) or sg:IsExists(aux.IgnoreTimeleapCondFilter,1,nil,c,e,tp,sg))
		and Duel.GetLocationCountFromEx(tp,tp,sg,tl)>0
		and not sg:IsExists(Auxiliary.TimeleapUncompatibilityFilter,1,nil,sg,tl,tp)
	tl:ResetFlagEffect(FLAG_CERULEAN_SEA_SIREN)
	return res
end
function Auxiliary.TimeleapUncompatibilityFilter(c,sg,lc,tp)
	local mg=sg:Filter(aux.TRUE,c)
	return not Auxiliary.TimeleapCheckOtherMaterial(c,mg,lc,tp)
end
function Auxiliary.TimeleapCheckOtherMaterial(c,mg,lc,tp)
	local le={c:IsHasEffect(EFFECT_EXTRA_TIMELEAP_MATERIAL,tp)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		if f and type(f)=="function" and not f(te,lc,mg) then return false end
	end
	return true
end
function Auxiliary.TimeleapTarget(sumcon,filter,customop,...)
	local funs,min,max={...},1,1
	for i=1,#funs do
		if funs[i][1]~=999 then
			min=min+funs[i][2] 
			max=max+funs[i][3]
		else
			min=funs[i][2] 
			max=funs[i][3]
		end
	end
	if max>99 then max=99 end
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				if customop and not customop(e,tp,eg,ep,ev,re,r,rp,c,g,0) then return false end
				local f
				local custom_matop=c:IsHasEffect(EFFECT_TIMELEAP_CUSTOM_MATERIAL_OPERATION)
				if custom_matop then
					f=custom_matop:GetValue()
				else
					f=Card.IsAbleToRemove
				end
				
				local mg=Duel.GetMatchingGroup(Card.IsCanBeTimeleapMaterial,tp,LOCATION_MZONE,0,nil,c):Filter(aux.Faceup(f),nil,e,tp)
				local mg2=Duel.GetMatchingGroup(Auxiliary.TimeleapExtraFilter,tp,0xff,0xff,nil,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_TIMELEAP_MATERIAL)}
				for _,te in ipairs(ce) do
					local tc=te:GetHandler()
					if tc then bg:AddCard(tc) end
				end
				if #bg>0 then
					if bg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					bg:Select(tp,#bg,#bg,nil)
				end
				
				local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_TIMELEAP_SUMMON)}
				local igneset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_IGNORE_TIMELEAP_HOPT)}
				local exsumeff,ignsumeff
				--EFFECT_EXTRA_TIMELEAP_SUMMON
				local options={}
				if (#eset>0 and Duel.GetFlagEffect(tp,830)<=0) or #igneset>0 then
					local cond=1
					if Duel.GetFlagEffect(tp,828)<=0 then
						table.insert(options,aux.Stringid(433005,15))
						cond=0
					end
					
					for _,te in ipairs(eset) do
						table.insert(options,te:GetDescription())
					end
					for _,te in ipairs(igneset) do
						if te:CheckCountLimit(tp) then
							table.insert(options,te:GetDescription())
						end
					end
					
					local op=Duel.SelectOption(tp,table.unpack(options))+cond
					if op>0 then
						if op<=#eset then
							exsumeff=eset[op]
						else
							ignsumeff=igneset[op-#eset]
						end
					end
				end
				
				local sg=Group.CreateGroup()
				sg:Merge(bg)
				local finish=false
				while #sg<=max do
					finish=Auxiliary.TimeleapCheckGoal(filter,e,tp,sg,bg,c,#sg,sumcon,table.unpack(funs))
					if #sg<max then
						local cg=mg:Filter(Auxiliary.TimeleapMaterialFilter,sg,filter,e,tp,sg,mg,bg,c,#sg,sumcon,table.unpack(funs))
						if #cg==0 then break end
						local cancel=Duel.IsSummonCancelable() and not finish
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
						local tc=cg:SelectUnselect(sg,tp,finish,cancel,min,max)
						if not tc then break end
						if not bg:IsContains(tc) then
							if not sg:IsContains(tc) then
								sg:AddCard(tc)
								if (#sg>=max) then finish=true end
							else
								sg:RemoveCard(tc)
							end
						elseif #bg>0 and #sg<=#bg then
							return false
						end
					else
						break
					end
				end
				
				if finish then
					if exsumeff~=nil then
						Duel.RegisterFlagEffect(tp,829,RESET_PHASE+PHASE_END,0,1)
						Duel.Hint(HINT_CARD,0,exsumeff:GetHandler():GetOriginalCode())
					elseif ignsumeff~=nil then
						Duel.Hint(HINT_CARD,0,ignsumeff:GetHandler():GetOriginalCode())
						ignsumeff:UseCountLimit(tp)
					end
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function Auxiliary.TimeleapOperation(customop)
	return  function(e,tp,eg,ep,ev,re,r,rp,c)
				if Duel.SetSummonCancelable then Duel.SetSummonCancelable(true) end
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				c:RegisterFlagEffect(FLAG_CERULEAN_SEA_SIREN,RESET_EVENT|RESETS_STANDARD,0,1)
				
				local custom_matop=c:IsHasEffect(EFFECT_TIMELEAP_CUSTOM_MATERIAL_OPERATION)
				if custom_matop then
					custom_matop:GetOperation()(e,tp,eg,ep,ev,re,r,rp,c,g)
				else
					Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
				end
				
				if not customop then
					if Duel.GetFlagEffect(tp,829)<=0 then
						Duel.RegisterFlagEffect(tp,828,RESET_PHASE+PHASE_END,0,1)
					else
						Duel.ResetFlagEffect(tp,829)
						Duel.RegisterFlagEffect(tp,830,RESET_PHASE+PHASE_END,0,1)
					end
				else
					customop(e,tp,eg,ep,ev,re,r,rp,c,g,1)
				end
				g:DeleteGroup()
			end
end

function Auxiliary.TimeleapHOPT(tp)
	if Duel.GetFlagEffect(tp,829)<=0 then
		Duel.RegisterFlagEffect(tp,828,RESET_PHASE+PHASE_END,0,1)
	else
		Duel.ResetFlagEffect(tp,829)
		Duel.RegisterFlagEffect(tp,830,RESET_PHASE+PHASE_END,0,1)
	end
end
function Duel.IgnoreTimeleapHOPT(c,tp,f)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_IGNORE_TIMELEAP_HOPT)
	e1:SetTargetRange(LOCATION_EXTRA,LOCATION_EXTRA)
	if f then
		e1:SetTarget(f)
	end
	Duel.RegisterEffect(e1,tp)
	return e1
end

function Card.GetFuture(c)
	if not Auxiliary.Timeleaps[c] then return 0 end
	local te=c:IsHasEffect(EFFECT_FUTURE)
	if type(te:GetValue())=='function' then
		return te:GetValue()(te,c)
	else
		return te:GetValue()
	end
end
function Card.IsFuture(c,...)
	if not Auxiliary.Timeleaps[c] then return false end
	for _,future in ipairs({...}) do
		if c:GetFuture()==future then return true end
	end
	return false
end
function Card.IsFutureAbove(c,future)
	if not Auxiliary.Timeleaps[c] then return false end
	return c:GetFuture()>=future
end
function Card.IsFutureBelow(c,future)
	if not Auxiliary.Timeleaps[c] then return false end
	local ft=c:GetFuture()
	return ft>0 and ft<=future
end

function Auxiliary.UpdateLastFutureOnField(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local s=getmetatable(c)
	s.PreviousFutureOnField=c:GetFuture()
end
function Card.GetPreviousFutureOnField(c)
	local val=c.PreviousFutureOnField
	if not val then return false end
	return val
end

--Special Timeleap Material Operations
function Auxiliary.TimeleapMaterialBanishFacedown()
	return {
		function(e,tp,eg,ep,ev,re,r,rp,c,g)
			Duel.Remove(g,POS_FACEDOWN,REASON_MATERIAL|REASON_TIMELEAP)
		end,
		function(c,e,tp)
			return c:IsAbleToRemove(tp,POS_FACEDOWN)
		end
	}
end