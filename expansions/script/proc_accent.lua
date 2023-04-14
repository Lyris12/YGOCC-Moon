--coded by Lyris
--アクセント召喚
--Not yet finalized values
--Custom constants
EFFECT_CANNOT_BE_ACCENTED_MATERIAL	=562
EFFECT_MUST_BE_AMATERIAL			=563
EFFECT_ACCENT_SUBSTITUTE			=564
EFFECT_ADD_ACCENT_CODE				=565
TYPE_ACCENT							=0x100000000000
TYPE_CUSTOM							=TYPE_CUSTOM|TYPE_ACCENT
CTYPE_ACCENT						=0x1000
CTYPE_CUSTOM						=CTYPE_CUSTOM|CTYPE_ACCENT
SUMMON_TYPE_ACCENT					=SUMMON_TYPE_SPECIAL+0x1a

REASON_ACCENT						=0x4000000000

--Custom Type Table
Auxiliary.Accents={} --number as index = card, card as index = function() is_fusion
table.insert(aux.CannotBeEDMatCodes,EFFECT_CANNOT_BE_ACCENTED_MATERIAL)

--overwrite constants
TYPE_EXTRA							=TYPE_EXTRA|TYPE_ACCENT

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_prev_location, is_prev_location, get_reason =
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetPreviousLocation, Card.IsPreviousLocation, Card.GetReason

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Accents[c] then
		tpe=tpe|TYPE_ACCENT
		if not Auxiliary.Accents[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Accents[c] then
		tpe=tpe|TYPE_ACCENT
		if not Auxiliary.Accents[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Accents[c] then
		tpe=tpe|TYPE_ACCENT
		if not Auxiliary.Accents[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	return tpe
end
Card.GetPreviousLocation=function(c)
	local lc=get_prev_location(c)
	if lc==LOCATION_REMOVED and c:IsLocation(LOCATION_GRAVE) and c:GetFlagEffect(562)>0 then
		if c:IsType(TYPE_MONSTER) then lc=LOCATION_MZONE
		else lc=LOCATION_SZONE end
	end
	if lc==LOCATION_SZONE then
		if c:GetPreviousSequence()==5 then lc=lc|LOCATION_FZONE
		elseif c:IsType(TYPE_PENDULUM) and (c:GetPreviousSequence()==0 or c:GetPreviousSequence()==4 or c:GetPreviousSequence()>5) and not c:GetPreviousEquipTarget() then lc=lc|LOCATION_PZONE end
	end
	return lc
end
Card.IsPreviousLocation=function(c,loc)
	return c:GetPreviousLocation()&loc>0
end

--Custom Functions
function Card.IsCanBeAccentedMaterial(c,fc)
	if not c:IsAbleToRemove() then return false end
	local tef={c:IsHasEffect(EFFECT_CANNOT_BE_ACCENTED_MATERIAL)}
	for _,te in ipairs(tef) do
		if te:GetValue()(te,ec) then return false end
	end
	return true
end
function Card.GetAccentCode(c)
	local _,otcode,t=c:GetOriginalCodeRule(),{}
	local tef={c:IsHasEffect(EFFECT_ADD_ACCENT_CODE)}
	for _,te in ipairs(tef) do
		local tev=te:GetValue()
		if type(te)=='function' then tev=tev(te,c) end
		table.insert(t,tev)
	end
	return c:GetCode(),otcode,table.unpack(t)
end
function Card.IsAccentCode(c,...)
	for code in ipairs({...}) do
		if c:IsCode(code) then return true end
		for i,acode in ipairs({c:GetAccentCode()}) do
			if acode==code then return true end
		end
	end
	return false
end
function Auxiliary.AccentSummonCon(e,tp,eg,ep,ev,re,r,rp)
    for i=1,Duel.GetCurrentChain() do
        local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
        if te:IsActiveType(TYPE_MONSTER) then return true end
	end
	return false
end
function Auxiliary.AddOrigAccentType(c,isfusion)
	table.insert(Auxiliary.Accents,c)
	Auxiliary.Customs[c]=true
	local isfusion=isfusion==nil and false or isfusion
	Auxiliary.Accents[c]=function() return isfusion end
end
function Auxiliary.AddAccentProc(c,f,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	--f - method to check Accented Materials
	local f=f
	if type(f)=='string' then f=Auxiliary["AddAccentProc"..f] end
	f(c,table.unpack({...}))
	local ge0=Effect.CreateEffect(c)
	ge0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	ge0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ge0:SetCode(EVENT_SPSUMMON_SUCCESS)
	ge0:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_ACCENT) end)
	ge0:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(10003000,RESET_EVENT+0x1120000,0,1) end)
	c:RegisterEffect(ge0)
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	ge1:SetCode(EVENT_CHAIN_SOLVED)
	ge1:SetRange(0xff)
	ge1:SetOperation(Auxiliary.AccentReturnOp)
	Duel.RegisterEffect(ge1,0)
	local ge2=ge1:Clone()
	ge2:SetCode(EVENT_ADJUST)
	Duel.RegisterEffect(ge2,0)
end
function Auxiliary.AMaterialFilter(c,...)
	return c:IsFaceup() and c:IsCode(...)
end
function Auxiliary.AccentReturnOp(e,tp,eg,ep,ev,re,r,rp)
	local ag=Duel.GetMatchingGroup(Card.IsType,tp,0xff,0xff,nil,TYPE_ACCENT)
	local g=nil
	local sg=Group.CreateGroup()
	for c in aux.Next(ag) do if not c:IsOnField() and c:GetFlagEffect(10003000)~=0 then
		g=c:GetMaterial()
		for mc in aux.Next(g) do
			local tg=Duel.GetMatchingGroup(aux.AMaterialFilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,mc:GetCode())
			sg:Merge(tg)
		end
		c:ResetFlagEffect(10003000)
	end end
	for tc in aux.Next(sg) do
		tc:RegisterFlagEffect(562,RESET_EVENT+RESETS_STANDARD-RESET_TOGRAVE,0,1)
	end
	Duel.SendtoGrave(sg,0)
	for tc in aux.Next(sg) do
		Duel.RaiseSingleEvent(tc,EVENT_TO_GRAVE,e,r,rp,tp,ev)
	end
	Duel.RaiseEvent(sg,EVENT_TO_GRAVE,e,r,rp,tp,ev)
end
function Card.CheckAccentSubstitute(c,fc)
	local tef={c:IsHasEffect(EFFECT_ACCENT_SUBSTITUTE)}
	for _,ef in ipairs(tef) do
		local eval=ef:GetValue()
		if not eval then return true end
		return eval(fc)
	end
	return false
end
--material_count: number of different names in material list
--material: names in material list
--Accent monster, mixed materials
function Auxiliary.AddAccentProcMix(c,sub,insf,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local val={...}
	local fun={}
	local mat={}
	for i=1,#val do
		if type(val[i])=='function' then
			fun[i]=function(c,fc,sub,mg,sg) return val[i](c,fc,sub,mg,sg) end
		elseif type(val[i])=='table' then
			fun[i]=function(c,fc,sub,mg,sg)
				for _,fcode in ipairs(val[i]) do
					if type(fcode)=='function' then
						if fcode(c,fc,sub,mg,sg) then return true end
					else
						if c:IsAccentCode(fcode) or (sub and c:CheckAccentSubstitute(fc)) then return true end
					end
				end
				return false
			end
			for _,fcode in ipairs(val[i]) do
				if type(fcode)~='function' then mat[fcode]=true end
			end
		else
			fun[i]=function(c,fc,sub) return c:IsAccentCode(val[i]) or (sub and c:CheckAccentSubstitute(fc)) end
			mat[val[i]]=true
		end
	end
	local mt=getmetatable(c)
	if mt.material==nil then
		mt.material=mat
	end
	if mt.material_count==nil then
		mt.material_count={#fun,#fun}
	end
	for index,_ in pairs(mat) do
		Auxiliary.AddCodeList(c,index)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.AConditionMix(insf,sub,table.unpack(fun)))
	e1:SetOperation(Auxiliary.AOperationMix(insf,sub,table.unpack(fun)))
	c:RegisterEffect(e1)
end
function Auxiliary.AConditionMix(insf,sub,...)
	--g:Material group
	--gc:Material already used
	--chkf: check field, default:PLAYER_NONE
	--chkf&0x100: Not accent summon
	--chkf&0x200: Concat accent
	local funs={...}
	return	function(e,g,gc,chkfnf)
				if g==nil then return insf and Auxiliary.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_AMATERIAL) end
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notaccent=chkfnf&0x100>0
				local concat_accent=chkfnf&0x200>0
				local sub=(sub or notaccent) and not concat_accent
				local mg=g:Filter(Auxiliary.AConditionFilterMix,c,c,sub,concat_accent,table.unpack(funs))
				if gc then
					if not mg:IsContains(gc) then return false end
					Duel.SetSelectedCard(Group.FromCards(gc))
				end
				return mg:CheckSubGroup(Auxiliary.ACheckMixGoal,#funs,#funs,tp,c,sub,chkfnf,table.unpack(funs))
			end
end
function Auxiliary.AOperationMix(insf,sub,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notaccent=chkfnf&0x100>0
				local concat_accent=chkfnf&0x200>0
				local sub=(sub or notaccent) and not concat_accent
				local mg=eg:Filter(Auxiliary.AConditionFilterMix,c,c,sub,concat_accent,table.unpack(funs))
				if gc then Duel.SetSelectedCard(Group.FromCards(gc)) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
				local sg=mg:SelectSubGroup(tp,Auxiliary.ACheckMixGoal,true,#funs,#funs,tp,c,sub,chkfnf,table.unpack(funs))
				Duel.SetFusionMaterial(sg or Group.CreateGroup())
			end
end
function Auxiliary.AConditionFilterMix(c,fc,sub,concat_accent,...)
	local accent_type=concat_accent and SUMMON_TYPE_SPECIAL or SUMMON_TYPE_ACCENT
	if not c:IsCanBeAccentedMaterial(fc,accent_type) then return false end
	for i,f in ipairs({...}) do
		if f(c,fc,sub) then return true end
	end
	return false
end
--if sg1 is subset of sg2 then not Auxiliary.ACheckAdditional(tp,sg1,fc) -> not Auxiliary.ACheckAdditional(tp,sg2,fc)
Auxiliary.ACheckAdditional=nil
Auxiliary.AGoalCheckAdditional=nil
function Auxiliary.ACheckMixGoal(sg,tp,fc,sub,chkfnf,...)
	local chkf=chkfnf&0xff
	if not Auxiliary.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_AMATERIAL) then return false end
	local g=Group.CreateGroup()
	return sg:IsExists(Auxiliary.FCheckMix,1,nil,sg,g,fc,sub,...) and (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0)
		and (not Auxiliary.ACheckAdditional or Auxiliary.ACheckAdditional(tp,sg,fc))
		and (not Auxiliary.AGoalCheckAdditional or Auxiliary.AGoalCheckAdditional(tp,sg,fc))
		and aux.dncheck(sg)
end
--Accent monster, mixed material * minc to maxc + material + ...
function Auxiliary.AddAccentProcMixRep(c,sub,insf,fun1,minc,maxc,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local val={fun1,...}
	local fun={}
	local mat={}
	for i=1,#val do
		if type(val[i])=='function' then
			fun[i]=function(c,fc,sub,mg,sg) return val[i](c,fc,sub,mg,sg) end
		elseif type(val[i])=='table' then
			fun[i]=function(c,fc,sub,mg,sg)
					for _,fcode in ipairs(val[i]) do
						if type(fcode)=='function' then
							if fcode(c,fc,sub,mg,sg) then return true end
						else
							if c:IsAccentCode(fcode) or (sub and c:CheckAccentSubstitute(fc)) then return true end
						end
					end
					return false
			end
			for _,fcode in ipairs(val[i]) do
				if type(fcode)~='function' then mat[fcode]=true end
			end
		else
			fun[i]=function(c,fc,sub) return c:IsAccentCode(val[i]) or (sub and c:CheckAccentSubstitute(fc)) end
			mat[val[i]]=true
		end
	end
	local mt=getmetatable(c)
	if mt.material==nil then
		mt.material=mat
	end
	if mt.material_count==nil then
		mt.material_count={#fun+minc-1,#fun+maxc-1}
	end
	for index,_ in pairs(mat) do
		Auxiliary.AddCodeList(c,index)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.AConditionMixRep(insf,sub,fun[1],minc,maxc,table.unpack(fun,2)))
	e1:SetOperation(Auxiliary.AOperationMixRep(insf,sub,fun[1],minc,maxc,table.unpack(fun,2)))
	c:RegisterEffect(e1)
end
function Auxiliary.AConditionMixRep(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,g,gc,chkfnf)
				if g==nil then return insf and Auxiliary.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_AMATERIAL) end
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notaccent=chkfnf&0x100>0
				local concat_accent=chkfnf&0x200>0
				local sub=(sub or notaccent) and not concat_accent
				local mg=g:Filter(Auxiliary.FConditionFilterMix,c,c,sub,concat_accent,fun1,table.unpack(funs))
				if gc then
					if not mg:IsContains(gc) then return false end
					local sg=Group.CreateGroup()
					return Auxiliary.ASelectMixRep(gc,tp,mg,sg,c,sub,chkfnf,fun1,minc,maxc,table.unpack(funs))
				end
				local sg=Group.CreateGroup()
				return mg:IsExists(Auxiliary.ASelectMixRep,1,nil,tp,mg,sg,c,sub,chkfnf,fun1,minc,maxc,table.unpack(funs))
			end
end
function Auxiliary.AOperationMixRep(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notaccent=chkfnf&0x100>0
				local concat_accent=chkfnf&0x200>0
				local sub=(sub or notaccent) and not concat_accent
				local mg=eg:Filter(Auxiliary.FConditionFilterMix,c,c,sub,concat_accent,fun1,table.unpack(funs))
				local sg=Group.CreateGroup()
				if gc then sg:AddCard(gc) end
				while #sg<maxc+#funs do
					local cg=mg:Filter(Auxiliary.ASelectMixRep,sg,tp,mg,sg,c,sub,chkfnf,fun1,minc,maxc,table.unpack(funs))
					if #cg==0 then break end
					local finish=Auxiliary.ACheckMixRepGoal(tp,sg,c,sub,chkfnf,fun1,minc,maxc,table.unpack(funs))
					local cancel_group=sg:Clone()
					if gc then cancel_group:RemoveCard(gc) end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					local tc=cg:SelectUnselect(cancel_group,tp,finish,#sg==0,minc+#funs,maxc+#funs)
					if not tc then break end
					if sg:IsContains(tc) then
						sg:RemoveCard(tc)
					else
						sg:AddCard(tc)
					end
				end
				Duel.SetFusionMaterial(sg or Group.CreateGroup())
			end
end
function Auxiliary.ACheckMixRepGoalCheck(tp,sg,fc,chkfnf)
	if not Auxiliary.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_AMATERIAL) then return false end
	if Auxiliary.AGoalCheckAdditional and not Auxiliary.AGoalCheckAdditional(tp,sg,fc) then return false end
	return true
end
function Auxiliary.ACheckMixRepGoal(tp,sg,fc,sub,chkfnf,fun1,minc,maxc,...)
	local chkf=chkfnf&0xff
	if #sg<minc+#{...} or #sg>maxc+#{...} then return false end
	if not (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0) then return false end
	if Auxiliary.ACheckAdditional and not Auxiliary.ACheckAdditional(tp,sg,fc) then return false end
	if not Auxiliary.ACheckMixRepGoalCheck(tp,sg,fc,chkfnf) then return false end
	local g=Group.CreateGroup()
	return Auxiliary.ACheckMixRep(sg,g,fc,sub,chkf,fun1,minc,maxc,...)
		and aux.dncheck(sg)
end
function Auxiliary.ACheckSelectMixRep(tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,...)
	local chkf=chkfnf&0xff
	if Auxiliary.ACheckAdditional and not Auxiliary.ACheckAdditional(tp,g,fc) then return false end
	if chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,g,fc)>0 then
		if minc<=0 and #{...}==0 and Auxiliary.ACheckMixRepGoalCheck(tp,g,fc,chkfnf) then return true end
		return mg:IsExists(Auxiliary.FCheckSelectMixRepAll,1,g,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,...)
	else
		return mg:IsExists(Auxiliary.FCheckSelectMixRepM,1,g,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,...)
	end
end
function Auxiliary.ASelectMixRep(c,tp,mg,sg,fc,sub,chkfnf,...)
	sg:AddCard(c)
	local res=false
	if Auxiliary.ACheckAdditional and not Auxiliary.ACheckAdditional(tp,sg,fc) then
		res=false
	elseif Auxiliary.ACheckMixRepGoal(tp,sg,fc,sub,chkfnf,...) then
		res=true
	else
		local g=Group.CreateGroup()
		res=sg:IsExists(Auxiliary.ACheckMixRepSelected,1,nil,tp,mg,sg,g,fc,sub,chkfnf,...)
	end
	sg:RemoveCard(c)
	return res
end
--Accent monster, name + name
function Auxiliary.AddAccentProcCode2(c,code1,code2,sub,insf)
	Auxiliary.AddAccentProcMix(c,sub,insf,code1,code2)
end
--Accent monster, name + name + name
function Auxiliary.AddAccentProcCode3(c,code1,code2,code3,sub,insf)
	Auxiliary.AddAccentProcMix(c,sub,insf,code1,code2,code3)
end
--Accent monster, name + name + name + name
function Auxiliary.AddAccentProcCode4(c,code1,code2,code3,code4,sub,insf)
	Auxiliary.AddAccentProcMix(c,sub,insf,code1,code2,code3,code4)
end
--Accent monster, name * n
function Auxiliary.AddAccentProcCodeRep(c,code1,cc,sub,insf)
	local code={}
	for i=1,cc do
		code[i]=code1
	end
	Auxiliary.AddAccentProcMix(c,sub,insf,table.unpack(code))
end
--Accent monster, name * minc to maxc
function Auxiliary.AddAccentProcCodeRep2(c,code1,minc,maxc,sub,insf)
	Auxiliary.AddAccentProcMixRep(c,sub,insf,code1,minc,maxc)
end
--Accent monster, name + condition * n
function Auxiliary.AddAccentProcCodeFun(c,code1,f,cc,sub,insf)
	local fun={}
	for i=1,cc do
		fun[i]=f
	end
	Auxiliary.AddAccentProcMix(c,sub,insf,code1,table.unpack(fun))
end
--Accent monster, condition + condition
function Auxiliary.AddAccentProcFun2(c,f1,f2,insf)
	Auxiliary.AddAccentProcMix(c,false,insf,f1,f2)
end
--Accent monster, condition * n
function Auxiliary.AddAccentProcFunRep(c,f,cc,insf)
	local fun={}
	for i=1,cc do
		fun[i]=f
	end
	Auxiliary.AddAccentProcMix(c,false,insf,table.unpack(fun))
end
--Accent monster, condition * minc to maxc
function Auxiliary.AddAccentProcFunRep2(c,f,minc,maxc,insf)
	Auxiliary.AddAccentProcMixRep(c,false,insf,f,minc,maxc)
end
--Accent monster, condition1 + condition2 * n
function Auxiliary.AddAccentProcFunFun(c,f1,f2,cc,insf)
	local fun={}
	for i=1,cc do
		fun[i]=f2
	end
	Auxiliary.AddAccentProcMix(c,false,insf,f1,table.unpack(fun))
end
--Accent monster, condition1 + condition2 * minc to maxc
function Auxiliary.AddAccentProcFunFunRep(c,f1,f2,minc,maxc,insf)
	Auxiliary.AddAccentProcMixRep(c,false,insf,f2,minc,maxc,f1)
end
--Accent monster, name + condition * minc to maxc
function Auxiliary.AddAccentProcCodeFunRep(c,code1,f,minc,maxc,sub,insf)
	Auxiliary.AddAccentProcMixRep(c,sub,insf,f,minc,maxc,code1)
end
--Accent monster, name + name + condition * minc to maxc
function Auxiliary.AddAccentProcCode2FunRep(c,code1,code2,f,minc,maxc,sub,insf)
	Auxiliary.AddAccentProcMixRep(c,sub,insf,f,minc,maxc,code1,code2)
end
function Auxiliary.AddContactAccentProcedure(c,filter,self_location,opponent_location,mat_operation,...)
	local self_location=self_location or 0
	local opponent_location=opponent_location or 0
	local operation_params={...}
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(Auxiliary.ContactAccentCondition(filter,self_location,opponent_location))
	e2:SetOperation(Auxiliary.ContactAccentOperation(filter,self_location,opponent_location,mat_operation,operation_params))
	c:RegisterEffect(e2)
	return e2
end
function Auxiliary.ContactAccentedMaterialFilter(c,fc,filter)
	return c:IsCanBeAccentedMaterial(fc,SUMMON_TYPE_SPECIAL) and (not filter or filter(c,fc))
end
function Auxiliary.ContactAccentCondition(filter,self_location,opponent_location)
	return	function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=Duel.GetMatchingGroup(Auxiliary.ContactAccentedMaterialFilter,tp,self_location,opponent_location,c,c,filter)
				return c:CheckAccentMaterial(mg,nil,tp|0x200)
			end
end
function Auxiliary.ContactAccentOperation(filter,self_location,opponent_location,mat_operation,operation_params)
	return	function(e,tp,eg,ep,ev,re,r,rp,c)
				local mg=Duel.GetMatchingGroup(Auxiliary.ContactAccentedMaterialFilter,tp,self_location,opponent_location,c,c,filter)
				local g=Duel.SelectFusionMaterial(tp,c,mg,nil,tp|0x200)
				c:SetMaterial(g)
				mat_operation(g,table.unpack(operation_params))
			end
end
