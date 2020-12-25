--created by Swag, coded by Lyris
--Not yet finalized values
--Custom constants
EFFECT_CANNOT_BE_TIMELEAP_MATERIAL	=825
EFFECT_MUST_BE_TIMELEAP_MATERIAL	=826
EFFECT_FUTURE						=827
EFFECT_EXTRA_TIMELEAP_MATERIAL		=828
EFFECT_EXTRA_TIMELEAP_SUMMON		=829
EFFECT_IGNORE_TIMELEAP_HOPT			=830
TYPE_TIMELEAP						=0x10000000000
TYPE_CUSTOM							=TYPE_CUSTOM|TYPE_TIMELEAP
CTYPE_TIMELEAP						=0x100
CTYPE_CUSTOM						=CTYPE_CUSTOM|CTYPE_TIMELEAP

SUMMON_TYPE_TIMELEAP				=SUMMON_TYPE_SPECIAL+825

REASON_TIMELEAP	=0x10000000000

--Custom Type Table
Auxiliary.Timeleaps={} --number as index = card, card as index = function() is_synchro
table.insert(aux.CannotBeEDMatCodes,EFFECT_CANNOT_BE_TIMELEAP_MATERIAL)

--overwrite constants
TYPE_EXTRA							=TYPE_EXTRA|TYPE_TIMELEAP

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_level, get_syn_level, get_rit_level, get_orig_level, is_xyz_level, 
	get_prev_level_field, is_level, is_level_below, is_level_above, get_reason, syn_target = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetLevel, 
	Card.GetSynchroLevel, Card.GetRitualLevel, Card.GetOriginalLevel, Card.IsXyzLevel, Card.GetPreviousLevelOnField, Card.IsLevel, Card.IsLevelBelow, Card.IsLevelAbove, Card.GetReason, Auxiliary.SynTarget

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

--Custom Functions
function Card.IsCanBeTimeleapMaterial(c,ec,...)
	local funs={...}
	local exctyp=funs[1]
	if not exctyp then
		if c:IsType(TYPE_LINK+TYPE_EVOLUTE+TYPE_XYZ) then return false end
	end
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
function Auxiliary.AddTimeleapProc(c,futureval,sumcon,filter,customop,...)
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
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Auxiliary.TimeleapCondition(sumcon,filter,table.unpack(list)))
	e1:SetTarget(Auxiliary.TimeleapTarget(filter,table.unpack(list)))
	e1:SetOperation(Auxiliary.TimeleapOperation(customop))
	e1:SetValue(SUMMON_TYPE_TIMELEAP)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_FUTURE)
	e2:SetValue(Auxiliary.FutureVal(futureval))
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function Auxiliary.TimeleapCondition(sumcon,filter,...)
	local funs={...}
	return  function(e,c)
				if c==nil then return true end
				if (c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_PANDEMONIUM)) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_TIMELEAP_SUMMON)}
				local exsumcheck=false
				for _,te in ipairs(eset) do
					if not te:GetValue() or type(te:GetValue())=="number" or te:GetValue()(e,c) then
						exsumcheck=true
					end
				end
				local mg=Duel.GetMatchingGroup(Card.IsCanBeTimeleapMaterial,tp,LOCATION_MZONE,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.TimeleapExtraFilter,tp,0xff,0xff,nil,f,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local fg=aux.GetMustMaterialGroup(tp,EFFECT_MUST_BE_TIMELEAP_MATERIAL)
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				Duel.SetSelectedCard(fg)
				return (not sumcon or sumcon(e,c))
					and (Duel.GetFlagEffect(tp,828)<=0 or (exsumcheck and Duel.GetFlagEffect(tp,830)<=0) or c:IsHasEffect(EFFECT_IGNORE_TIMELEAP_HOPT))
					and mg:IsExists(Auxiliary.TimeleapMaterialFilter,1,nil,filter,e,tp,Group.CreateGroup(),mg,c,0,table.unpack(funs))
			end
end
function Auxiliary.TimeleapExtraFilter(c,f,lc,tp,...)
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
		local con=te1:GetCondition()
		if (not con or con(c,ec,1)) then ValidSubstitute=true end
	end
	if not ValidSubstitute then return false end
	if c:IsLocation(LOCATION_ONFIELD) and not c:IsFaceup() then return false end
	return c:IsCanBeTimeleapMaterial(lc) and check
end
function Auxiliary.TimeleapMaterialFilter(c,filter,e,tp,sg,mg,bc,ct,...)
	sg:AddCard(c)
	ct=ct+1
	local funs,max,chk={...},1
	if (not filter or filter(c,e,mg)) and c:GetLevel()==bc:GetFuture()-1 then
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
	local res=chk and (Auxiliary.TimeleapCheckGoal(tp,sg,bc,ct,table.unpack(funs))
		or (ct<max and mg:IsExists(Auxiliary.TimeleapMaterialFilter,1,sg,filter,e,tp,sg,mg,bc,ct,table.unpack(funs))))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.TimeleapCheckGoal(tp,sg,bc,ct,...)
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
	return ct>=min and Duel.GetLocationCountFromEx(tp,tp,sg,bc)>0 and not sg:IsExists(Auxiliary.TimeleapUncompatibilityFilter,1,nil,sg,bc,tp)
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
function Auxiliary.TimeleapTarget(filter,...)
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
				local mg=Duel.GetMatchingGroup(Card.IsCanBeTimeleapMaterial,tp,LOCATION_MZONE,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.TimeleapExtraFilter,tp,0xff,0xff,nil,f,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_TIMELEAP_SUMMON)}
				local exsumcheck
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_TIMELEAP_MATERIAL)}
				for _,te in ipairs(ce) do
					local tc=te:GetHandler()
					if tc then bg:AddCard(tc) end
				end
				if #bg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					bg:Select(tp,#bg,#bg,nil)
				end
				local sg=Group.CreateGroup()
				sg:Merge(bg)
				local finish=false
				local options={}
				if #eset>0 then
					local cond=1
					if Duel.GetFlagEffect(tp,828)<=0 then
						table.insert(options,aux.Stringid(433005,15))
						cond=0
					end
					for _,te in ipairs(eset) do
						table.insert(options,te:GetDescription())
					end
					local op=Duel.SelectOption(tp,table.unpack(options))+cond
					if op>0 then
						exsumcheck=eset[op]
					end
				end
				while not (#sg>=max) do
					finish=Auxiliary.TimeleapCheckGoal(tp,sg,c,#sg,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.TimeleapMaterialFilter,sg,filter,e,tp,sg,mg,c,#sg,table.unpack(funs))
					if #cg==0 then break end
					local cancel=not finish
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
				end
				if finish then
					if exsumcheck~=nil then
						Duel.RegisterFlagEffect(tp,829,RESET_PHASE+PHASE_END,0,1)
						Duel.Hint(HINT_CARD,0,exsumcheck:GetOwner():GetOriginalCode())
						exsumcheck:Reset()
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
				if not customop then
					Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
					if Duel.GetFlagEffect(tp,829)<=0 then
						Duel.RegisterFlagEffect(tp,828,RESET_PHASE+PHASE_END,0,1)
					else
						Duel.ResetFlagEffect(tp,829)
						Duel.RegisterFlagEffect(tp,830,RESET_PHASE+PHASE_END,0,1)
					end
				else
					customop(e,tp,eg,ep,ev,re,r,rp,c,g)
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
	for future in pairs({...}) do
		if c:GetFuture()==future then return true end
	end
	return false
end
function Card.IsFutureAbove(c,future)
	return c:GetFuture()>=future
end
function Card.IsFutureBelow(c,future)
	local ft=c:GetFuture()
	return ft>0 and ft<=future
end
function Auxiliary.FutureVal(future)
	return  function(e,c)
				local future=future
				--insert modifications here
				return future
			end
end
