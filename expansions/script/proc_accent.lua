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
	if lc==LOCATION_REMOVED and c:IsLocation(LOCATION_DECK) and c:IsReason(REASON_ACCENT) then
		if c:IsType(TYPE_MONSTER) then lc=LOCATION_MZONE
		else lc=LOCATION_SZONE end
	end
	if lc==LOCATION_SZONE then
		if c:GetPreviousSequence()==5 then lc=lc|LOCATION_FZONE
		elseif c:IsType(TYPE_PENDULUM) and (c:GetPreviousSequence()==0 or c:GetPreviousSequence()==4) and not c:GetPreviousEquipTarget() then lc=lc|LOCATION_PZONE end
	end
	return lc
end
Card.IsPreviousLocation=function(c,loc)
	return c:GetPreviousLocation()&loc>0
end
Card.GetReason=function(c)
	local rs=get_reason(c)
	local rc=c:GetReasonCard() or nil
	if rc and Auxiliary.Accents[rc] then
		rs=rs|REASON_ACCENT
	end
	return rs
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
	ge0:SetCondition(function(e) return e:GetHandler():IsSummonType(0x1a) end)
	ge0:SetOperation(function(e) local c=e:GetHandler() c:CompleteProcedure() c:RegisterFlagEffect(10003000,RESET_EVENT+0x1120000,0,1) end)
	c:RegisterEffect(ge0)
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	ge1:SetCode(EVENT_CHAIN_SOLVED)
	ge1:SetRange(0xff)
	ge1:SetOperation(Auxiliary.AccentShuffleOp)
	Duel.RegisterEffect(ge1,0)
	local ge2=ge1:Clone()
	ge2:SetCode(EVENT_ADJUST)
	Duel.RegisterEffect(ge2,0)
end
function Auxiliary.MaterialFilter(c,atc)
	return not c:IsLocation(LOCATION_REMOVED) or c:GetReason()&REASON_MATERIAL+REASON_ACCENT~=REASON_MATERIAL+REASON_ACCENT or c:GetReasonCard()~=atc or c:IsFacedown()
end
function Auxiliary.AccentShuffleOp(e,tp,eg,ep,ev,re,r,rp)
	local ag=Duel.GetMatchingGroup(Card.IsType,tp,0xff,0xff,nil,TYPE_ACCENT)
	local g=nil
	local c=ag:GetFirst()
	local sumable
	while c do
		sumable=true
		if not c:IsOnField() and c:GetFlagEffect(10003000)~=0 then
			g=c:GetMaterial()
			if g:IsExists(Auxiliary.MaterialFilter,1,nil,c) then sumable=false end
			if sumable then
				Duel.SendtoDeck(g,nil,2,REASON_ACCENT)
			end
			c:ResetFlagEffect(10003000)
		end
		c=ag:GetNext()
	end
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
		else
			fun[i]=function(c,fc,sub) return c:IsAccentCode(val[i]) or (sub and c:CheckAccentSubstitute(fc)) end
			table.insert(mat,val[i])
		end
	end
	if #mat>0 and c.material_count==nil then
		local mt=getmetatable(c)
		mt.material_count=#mat
		mt.material=mat
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
	local funs={...}
	return	function(e,g,gc,chkfnf)
				if g==nil then return insf and Auxiliary.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_AMATERIAL) end
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notaccent=chkfnf>>8~=0
				local sub=sub or notaccent
				local mg=g:Filter(Auxiliary.AConditionFilterMix,c,c,sub,table.unpack(funs))
				if gc then
					if not mg:IsContains(gc) then return false end
					Duel.SetSelectedCard(Group.FromCards(gc))
				end
				return mg:CheckSubGroup(Auxiliary.ACheckMixGoal,#funs,#funs,tp,c,sub,chkf,table.unpack(funs))
			end
end
function Auxiliary.AOperationMix(insf,sub,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notaccent=chkfnf>>8~=0
				local sub=sub or notaccent
				local mg=eg:Filter(Auxiliary.AConditionFilterMix,c,c,sub,table.unpack(funs))
				if gc then Duel.SetSelectedCard(Group.FromCards(gc)) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
				local sg=mg:SelectSubGroup(tp,Auxiliary.ACheckMixGoal,false,#funs,#funs,tp,c,sub,chkf,table.unpack(funs))
				Duel.SetFusionMaterial(sg)
			end
end
function Auxiliary.AConditionFilterMix(c,fc,sub,...)
	if not c:IsCanBeAccentedMaterial(fc) then return false end
	for i,f in ipairs({...}) do
		if f(c,fc,sub) then return true end
	end
	return false
end
function Auxiliary.ACheckMix(c,mg,sg,fc,sub,fun1,fun2,...)
	if fun2 then
		sg:AddCard(c)
		local res=false
		if fun1(c,fc,false,mg,sg) then
			res=mg:IsExists(Auxiliary.ACheckMix,1,sg,mg,sg,fc,sub,fun2,...)
		elseif sub and fun1(c,fc,true,mg,sg) then
			res=mg:IsExists(Auxiliary.ACheckMix,1,sg,mg,sg,fc,false,fun2,...)
		end
		sg:RemoveCard(c)
		return res
	else
		return fun1(c,fc,sub,mg,sg)
	end
end
--if sg1 is subset of sg2 then not Auxiliary.ACheckAdditional(tp,sg1,fc) -> not Auxiliary.ACheckAdditional(tp,sg2,fc)
Auxiliary.ACheckAdditional=nil
function Auxiliary.ACheckMixGoal(sg,tp,fc,sub,chkf,...)
	if not Auxiliary.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_AMATERIAL) then return false end
	local g=Group.CreateGroup()
	return sg:IsExists(Auxiliary.ACheckMix,1,nil,sg,g,fc,sub,...) and (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0)
		and (not Auxiliary.ACheckAdditional or Auxiliary.ACheckAdditional(tp,sg,fc))
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
		else
			fun[i]=function(c,fc,sub) return c:IsAccentCode(val[i]) or (sub and c:CheckAccentSubstitute(fc)) end
			table.insert(mat,val[i])
		end
	end
	if #mat>0 and c.material_count==nil then
		local mt=getmetatable(c)
		mt.material_count=#mat
		mt.material=mat
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
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notaccent=chkfnf>>8~=0
				local sub=sub or notaccent
				local mg=g:Filter(Auxiliary.AConditionFilterMix,c,c,sub,fun1,table.unpack(funs))
				if gc then
					if not mg:IsContains(gc) then return false end
					local sg=Group.CreateGroup()
					return Auxiliary.ASelectMixRep(gc,tp,mg,sg,c,sub,chkf,fun1,minc,maxc,table.unpack(funs))
				end
				local sg=Group.CreateGroup()
				return mg:IsExists(Auxiliary.ASelectMixRep,1,nil,tp,mg,sg,c,sub,chkf,fun1,minc,maxc,table.unpack(funs))
			end
end
function Auxiliary.AOperationMixRep(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local chkf=chkfnf&0xff
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notaccent=chkfnf>>8~=0
				local sub=sub or notaccent
				local mg=eg:Filter(Auxiliary.AConditionFilterMix,c,c,sub,fun1,table.unpack(funs))
				local sg=Group.CreateGroup()
				if gc then sg:AddCard(gc) end
				while #sg<maxc+#funs do
					local cg=mg:Filter(Auxiliary.ASelectMixRep,sg,tp,mg,sg,c,sub,chkf,fun1,minc,maxc,table.unpack(funs))
					if #cg==0 then break end
					local finish=Auxiliary.ACheckMixRepGoal(tp,sg,c,sub,chkf,fun1,minc,maxc,table.unpack(funs))
					local cancel_group=sg:Clone()
					if gc then cancel_group:RemoveCard(gc) end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					local tc=cg:SelectUnselect(cancel_group,tp,finish,false,minc+#funs,maxc+#funs)
					if not tc then break end
					if sg:IsContains(tc) then
						sg:RemoveCard(tc)
					else
						sg:AddCard(tc)
					end
				end
				Duel.SetFusionMaterial(sg)
			end
end
function Auxiliary.ACheckMixRep(sg,g,fc,sub,chkf,fun1,minc,maxc,fun2,...)
	if fun2 then
		return sg:IsExists(Auxiliary.ACheckMixRepFilter,1,g,sg,g,fc,sub,chkf,fun1,minc,maxc,fun2,...)
	else
		local ct1=sg:FilterCount(fun1,g,fc,sub,mg,sg)
		local ct2=sg:FilterCount(fun1,g,fc,false,mg,sg)
		return ct1==#sg-#g and ct1-ct2<=1
	end
end
function Auxiliary.ACheckMixRepFilter(c,sg,g,fc,sub,chkf,fun1,minc,maxc,fun2,...)
	if fun2(c,fc,sub,mg,sg) then
		g:AddCard(c)
		local sub=sub and fun2(c,fc,false,mg,sg)
		local res=Auxiliary.ACheckMixRep(sg,g,fc,sub,chkf,fun1,minc,maxc,...)
		g:RemoveCard(c)
		return res
	end
	return false
end
function Auxiliary.ACheckMixRepGoal(tp,sg,fc,sub,chkf,fun1,minc,maxc,...)
	if not Auxiliary.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_AMATERIAL) then return false end
	if #sg<minc+#{...} or #sg>maxc+#{...} then return false end
	local g=Group.CreateGroup()
	return Auxiliary.ACheckMixRep(sg,g,fc,sub,chkf,fun1,minc,maxc,...) and (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0)
		and (not Auxiliary.ACheckAdditional or Auxiliary.ACheckAdditional(tp,sg,fc))
end
function Auxiliary.ACheckMixRepTemplate(c,cond,tp,mg,sg,g,fc,sub,chkf,fun1,minc,maxc,...)
	for i,f in ipairs({...}) do
		if f(c,fc,sub,mg,sg) then
			g:AddCard(c)
			local sub=sub and f(c,fc,false,mg,sg)
			local t={...}
			table.remove(t,i)
			local res=cond(tp,mg,sg,g,fc,sub,chkf,fun1,minc,maxc,table.unpack(t))
			g:RemoveCard(c)
			if res then return true end
		end
	end
	if maxc>0 then
		if fun1(c,fc,sub,mg,sg) then
			g:AddCard(c)
			local sub=sub and fun1(c,fc,false,mg,sg)
			local res=cond(tp,mg,sg,g,fc,sub,chkf,fun1,minc-1,maxc-1,...)
			g:RemoveCard(c)
			if res then return true end
		end
	end
	return false
end
function Auxiliary.ACheckMixRepSelectedCond(tp,mg,sg,g,...)
	if #g<#sg then
		return sg:IsExists(Auxiliary.ACheckMixRepSelected,1,g,tp,mg,sg,g,...)
	else
		return Auxiliary.ACheckSelectMixRep(tp,mg,sg,g,...)
	end
end
function Auxiliary.ACheckMixRepSelected(c,...)
	return Auxiliary.ACheckMixRepTemplate(c,Auxiliary.ACheckMixRepSelectedCond,...)
end
function Auxiliary.ACheckSelectMixRep(tp,mg,sg,g,fc,sub,chkf,fun1,minc,maxc,...)
	if Auxiliary.ACheckAdditional and not Auxiliary.ACheckAdditional(tp,g,fc) then return false end
	if chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,g,fc)>0 then
		if minc<=0 and #{...}==0 then return true end
		return mg:IsExists(Auxiliary.ACheckSelectMixRepAll,1,g,tp,mg,sg,g,fc,sub,chkf,fun1,minc,maxc,...)
	else
		return mg:IsExists(Auxiliary.ACheckSelectMixRepM,1,g,tp,mg,sg,g,fc,sub,chkf,fun1,minc,maxc,...)
	end
end
function Auxiliary.ACheckSelectMixRepAll(c,tp,mg,sg,g,fc,sub,chkf,fun1,minc,maxc,fun2,...)
	if fun2 then
		if fun2(c,fc,sub,mg,sg) then
			g:AddCard(c)
			local sub=sub and fun2(c,fc,false,mg,sg)
			local res=Auxiliary.ACheckSelectMixRep(tp,mg,sg,g,fc,sub,chkf,fun1,minc,maxc,...)
			g:RemoveCard(c)
			return res
		end
	elseif maxc>0 and fun1(c,fc,sub,mg,sg) then
		g:AddCard(c)
		local sub=sub and fun1(c,fc,false,mg,sg)
		local res=Auxiliary.ACheckSelectMixRep(tp,mg,sg,g,fc,sub,chkf,fun1,minc-1,maxc-1)
		g:RemoveCard(c)
		return res
	end
	return false
end
function Auxiliary.ACheckSelectMixRepM(c,tp,...)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and Auxiliary.ACheckMixRepTemplate(c,Auxiliary.ACheckSelectMixRep,tp,...)
end
function Auxiliary.ASelectMixRep(c,tp,mg,sg,fc,sub,chkf,...)
	sg:AddCard(c)
	local res=false
	if Auxiliary.ACheckAdditional and not Auxiliary.aCheckAdditional(tp,sg,fc) then
		res=false
	elseif Auxiliary.ACheckMixRepGoal(tp,sg,fc,sub,chkf,...) then
		res=true
	else
		local g=Group.CreateGroup()
		res=sg:IsExists(Auxiliary.ACheckMixRepSelected,1,nil,tp,mg,sg,g,fc,sub,chkf,...)
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
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local code={}
	for i=1,cc do
		code[i]=code1
	end
	if c.material_count==nil then
		local mt=getmetatable(c)
		mt.material_count=1
		mt.material={code1}
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
