--created by Kyrie, coded by Lyris & Glitchy
--Not yet finalized values
--Custom constants
EFFECT_GRADE					=654
EFFECT_CANNOT_BE_XROS_MATERIAL	=655
EFFECT_EXTRA_XROS_MATERIAL		=656
EFFECT_MUST_BE_XROS_MATERIAL	=657
TYPE_XROS						=0x10000000000000
TYPE_CUSTOM						=TYPE_CUSTOM|TYPE_XROS
CTYPE_XROS						=0x100000
CTYPE_CUSTOM					=CTYPE_CUSTOM|CTYPE_XROS

SUMMON_TYPE_XROS				=98

REASON_XROS						=0x20000000000

--overwrite constants
TYPE_EXTRA						=TYPE_EXTRA|TYPE_XROS

--Custom Tables
Auxiliary.Xroses={} --number as index	= card, card as index	= function() is_synchro
Auxiliary.HasLoad=false
table.insert(aux.CannotBeEDMatCodes,EFFECT_CANNOT_BE_XROS_MATERIAL)
--Track
g_Reserve={0}
g_Reserve[0]=0

--overwrite functions
local get_rank, get_orig_rank, prev_rank_field, is_rank, is_rank_below, is_rank_above, get_type, get_orig_type, get_prev_type_field, get_level, is_level, is_level_above, is_level_below, get_stage, is_stage, is_stage_above, is_stage_below, get_stability, is_stability, is_stability_above, is_stability_below, get_dimension, is_dimension, is_dimension_above, is_dimension_below, get_future, is_future, is_future_above, is_future_below, get_cell, is_cell, is_cell_above, is_cell_below, card_overlay_group, card_overlay_count, duel_overlay_group, duel_overlay_count = 
	Card.GetRank, Card.GetOriginalRank, Card.GetPreviousRankOnField, Card.IsRank, Card.IsRankBelow, Card.IsRankAbove, Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetLevel, Card.IsLevel, Card.IsLevelAbove, Card.IsLevelBelow, Card.GetStage, Card.IsStage, Card.IsStageAbove, Card.IsStageBelow, Card.GetStability, Card.IsStability, Card.IsStabilityAbove, Card.IsStabilityBelow, Card.GetDimensionNo, Card.IsDimensionNo, Card.IsDimensionNoAbove, Card.IsDimensionNoBelow, Card.GetFuture, Card.IsFuture, Card.IsFutureAbove, Card.IsFutureBelow, Card.GetCell, Card.IsCell, Card.IsCellAbove, Card.IsCellBelow,
		Card.GetOverlayGroup, Card.GetOverlayCount, Duel.GetOverlayGroup, Duel.GetOverlayCount

Card.GetRank=function(c)
	if Auxiliary.Xroses[c] then return c:GetCoreGroup():IsExists(Card.IsRankAbove,1,nil,1) and c:GetGrade() or 0 end
	return get_rank(c)
end
Card.GetOriginalRank=function(c)
	if Auxiliary.Xroses[c] and not Auxiliary.Xroses[c]() then return 0 end
	return get_orig_rank(c)
end
Card.GetPreviousRankOnField=function(c)
	if Auxiliary.Xroses[c] and not Auxiliary.Xroses[c]() then return 0 end
	if c:GetCoreGroup():IsExists(Card.IsRankAbove,1,nil,1) then return c:GetGrade() end
	return prev_rank_field(c)
end
Card.IsRank=function(c,...)
	if Auxiliary.Xroses[c] and not (Auxiliary.Xroses[c]() or (c:GetCoreGroup():IsExists(Card.IsRankAbove,1,nil,1) and c:IsGradeBelow(rk))) then return false end
	local funs={...}
	for key,value in pairs(funs) do
		if c:GetCoreGroup():IsExists(Card.IsRankAbove,1,nil,1) and c:GetGrade()==value or c:GetRank()==value then return true end
	end
	return false
end
Card.IsRankBelow=function(c,rk)
	if Auxiliary.Xroses[c] and not (Auxiliary.Xroses[c]() or (c:GetCoreGroup():IsExists(Card.IsRankAbove,1,nil,1) and c:IsGradeBelow(rk))) then return false end
	return is_rank_below(c,rk)
end
Card.IsRankAbove=function(c,rk)
	if Auxiliary.Xroses[c] and not (Auxiliary.Xroses[c]() or (c:GetCoreGroup():IsExists(is_rank_above,1,nil,1) and c:IsGradeAbove(rk))) then return false end
	return is_rank_above(c,rk)
end
Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Xroses[c] then
		tpe=tpe|TYPE_XROS
		if not Auxiliary.Xroses[c]() then
			tpe=tpe&~TYPE_XYZ
		end
		for tc in aux.Next(c:GetCoreGroup()) do
			tpe=tpe|c:GetType()&0x401e30
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Xroses[c] then
		tpe=tpe|TYPE_XROS
		if not Auxiliary.Xroses[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Xroses[c] then
		tpe=tpe|TYPE_XROS
		if not Auxiliary.Xroses[c]() then
			tpe=tpe&~TYPE_XYZ
		end
		for tc in aux.Next(c:GetCoreGroup()) do
			tpe=tpe|c:GetType()&0x401e30
		end
	end
	return tpe
end
Card.GetLevel=function(c)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsLevelAbove,1,nil,1) then return c:GetGrade() end
	return get_level(c)
end
Card.IsLevel=function(c,...)
	local funs={...}
	for key,value in pairs(funs) do
		if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsLevelAbove,1,nil,1) and c:GetGrade()==value or c:GetLevel()==value then return true end
	end
	return false
end
Card.IsLevelAbove=function(c,lv)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(is_level_above,1,nil,1) then return c:IsGradeAbove(lv) end
	return is_level_above(c,lv)
end
Card.IsLevelBelow=function(c,lv)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsLevelAbove,1,nil,1) then return c:IsGradeBelow(lv) end
	return is_level_below(c,lv)
end
Card.GetStage=function(c)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsStageAbove,1,nil,1) then return c:GetGrade() end
	return get_stage(c)
end
Card.IsStage=function(c,...)
	for key,value in pairs({...}) do
		if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsStageAbove,1,nil,1) and c:GetGrade()==value or c:GetStage()==value then return true end
	end
	return false
end
Card.IsStageAbove=function(c,val)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(is_stage_above,1,nil,1) then return c:IsGradeAbove(val) end
	return is_stage_above(c,val)
end
Card.IsStageBelow=function(c,val)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsStageAbove,1,nil,1) then return c:IsGradeBelow(val) end
	return is_stage_below(c,val)
end
Card.GetStability=function(c)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsStabilityAbove,1,nil,1) then return c:GetGrade() end
	return get_stability(c)
end
Card.IsStability=function(c,...)
	for key,value in pairs({...}) do
		if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsStabilityAbove,1,nil,1) and c:GetGrade()==value or c:GetStability()==value then return true end
	end
	return false
end
Card.IsStabilityAbove=function(c,val)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(is_stability_above,1,nil,1) then return c:IsGradeAbove(val) end
	return is_stability_above(c,val)
end
Card.IsStabilityBelow=function(c,val)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsStabilityAbove,1,nil,1) then return c:IsGradeBelow(val) end
	return is_stability_below(c,val)
end
Card.GetDimensionNo=function(c)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsDimensionNoAbove,1,nil,1) then return c:GetGrade() end
	return get_dimension(c)
end
Card.IsDimensionNo=function(c,...)
	for key,value in pairs({...}) do
		if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsDimensionNoAbove,1,nil,1) and c:GetGrade()==value or c:GetDimensionNo()==value then return true end
	end
	return false
end
Card.IsDimensionNoAbove=function(c,val)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(is_dimension_above,1,nil,1) then return c:IsGradeAbove(val) end
	return is_dimension_above(c,val)
end
Card.IsDimensionNoBelow=function(c,val)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsDimensionNoAbove,1,nil,1) then return c:IsGradeBelow(val) end
	return is_dimension_below(c,val)
end
Card.GetFuture=function(c)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsFutureAbove,1,nil,1) then return c:GetGrade() end
	return get_future(c)
end
Card.IsFuture=function(c,...)
	for key,value in pairs({...}) do
		if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsFutureAbove,1,nil,1) and c:GetGrade()==value or c:GetFuture()==value then return true end
	end
	return false
end
Card.IsFutureAbove=function(c,val)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(is_future_above,1,nil,1) then return c:IsGradeAbove(val) end
	return is_stability_above(c,val)
end
Card.IsFutureBelow=function(c,val)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsFutureAbove,1,nil,1) then return c:IsGradeBelow(val) end
	return is_stability_below(c,val)
end
Card.GetCell=function(c)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsCellAbove,1,nil,1) then return c:GetGrade() end
	return get_cell(c)
end
Card.IsCell=function(c,...)
	for key,value in pairs({...}) do
		if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsCellAbove,1,nil,1) and c:GetGrade()==value or c:GetCell()==value then return true end
	end
	return false
end
Card.IsCellAbove=function(c,val)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(is_cell_above,1,nil,1) then return c:IsGradeAbove(val) end
	return is_cell_above(c,val)
end
Card.IsCellBelow=function(c,val)
	if Auxiliary.Xroses[c] and c:GetCoreGroup():IsExists(Card.IsCellAbove,1,nil,1) then return c:IsGradeBelow(val) end
	return is_cell_below(c,val)
end
Card.GetOverlayGroup=function(c)
	if Auxiliary.Xroses[c] then return Group.CreateGroup() end
	return card_overlay_group(c)
end
Card.GetOverlayCount=function(c)
	return #c:GetOverlayGroup()
end
Duel.GetOverlayGroup=function(tp,s,o)
	return duel_overlay_group(tp,s,o):Filter(function(c) return not Auxiliary.Xroses[c:GetOverlayTarget()] end,nil)
end
Duel.GetOverlayCount=function(tp,s,o)
	return #Duel.GetOverlayGroup(tp,s,o)
end

--Custom Functions
function Card.GetCoreGroup(c,typ)
	if not Auxiliary.Xroses[c] then return Group.CreateGroup() end
	local t={["Main"]=c:GetMaterial(),
	["Extra"]=card_overlay_group(c)-c:GetMaterial()}
	return not typ and card_overlay_group(c) or t[typ]
end
function Card.GetCoreCount(c,typ)
	return #c:GetCoreGroup(typ)
end
function Duel.GetCoreGroup(tp,s,o,typ)
	local g=duel_overlay_group(tp,s,o):Filter(function(c) return Auxiliary.Xroses[c:GetOverlayTarget()] end,nil)
	local t={["Main"]=g:Filter(function(c) return c:GetMaterial():IsContains(c) end,nil),
	["Extra"]=g:Filter(function(c) return not c:GetMaterial():IsContains(c) end,nil)}
	return not typ and g or t[typ]
end
function Duel.GetCoreCount(tp,s,o,typ)
	return #Duel.GetCoreGroup(tp,s,o,typ)
end
function Duel.ChangeReserve(tp,ct)
	g_Reserve[tp]=g_Reserve[tp]+ct
	Duel.CheckReserve(tp)
end
function Duel.CheckReserve(tp)
	Duel.AnnounceNumber(tp,g_Reserve[tp])
end
function Auxiliary.LoadCondition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if not Auxiliary.HasLoad then return false end
	return c:IsAbleToDeck() and c:IsLocation(LOCATION_HAND)
		or Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,0,1,c,TYPE_XROS)
end
function Auxiliary.LoadOperation(e,tp,eg,ep,ev,re,r,rp,c,sg)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,0,c,TYPE_XROS)
	if #g>0 and Duel.SelectOption(tp,1000,1007)~=0 then
		Duel.Overlay(g:Select(tp,1,1,nil):GetFirst(),c)
	else Duel.SendtoDeck(c,nil,1,REASON_RULE) end
	Duel.ChangeReserve(tp,5)
end

local ge2=Effect.GlobalEffect()
ge2:SetType(EFFECT_TYPE_FIELD)
ge2:SetCode(EFFECT_SPSUMMON_PROC_G)
ge2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
ge2:SetCountLimit(1,121514)
ge2:SetDescription(1348)
ge2:SetRange(LOCATION_MZONE+LOCATION_HAND)
ge2:SetCondition(Auxiliary.LoadCondition)
ge2:SetOperation(Auxiliary.LoadOperation)
local ge3=Effect.GlobalEffect()
ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
ge3:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,LOCATION_HAND+LOCATION_MZONE)
ge3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_MONSTER))
ge3:SetLabelObject(ge2)
Duel.RegisterEffect(ge3,0)
local ge4=Effect.GlobalEffect()
ge4:SetType(EFFECT_TYPE_FIELD)
ge4:SetCode(EFFECT_SPSUMMON_PROC_G)
ge4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
ge4:SetCountLimit(3,1215140)
ge4:SetDescription(202)
ge4:SetRange(LOCATION_DECK)
ge4:SetCondition(function() return Auxiliary.HasLoad end)
ge4:SetOperation(function(e,tp) Duel.CheckReserve(tp) end)
local ge1=Effect.GlobalEffect()
ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
ge1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
ge1:SetTarget(function(e,c) return c:GetSequence()==1 end)
ge1:SetLabelObject(ge4)
Duel.RegisterEffect(ge1,0)

function Card.GetGrade(c)
	if not Auxiliary.Xroses[c] then return 0 end
	local te=c:IsHasEffect(EFFECT_GRADE)
	if type(te:GetValue())=='function' then
		return te:GetValue()(te,c)
	else
		return te:GetValue()
	end
end
function Card.IsGrade(c,...)
	for gd in pairs({...}) do
		if c:GetGrade()==gd then return true end
	end
	return false
end
function Card.IsGradeAbove(c,gd)
	return c:GetGrade()>=gd
end
function Card.IsGradeBelow(c,gd)
	local grade=c:GetGrade()
	return grade>0 and grade<=gd
end
function Card.IsCanBeXrosMaterial(c,xsc)
	if c:IsOnField() and c:IsFacedown() or not c:IsCanOverlay(xsc:GetControler()) then return false end
	local tef={c:IsHasEffect(EFFECT_CANNOT_BE_XROS_MATERIAL)}
	for _,te in ipairs(tef) do
		if (type(te:GetValue())=="function" and te:GetValue()(te,xsc)) or te:GetValue()==1 then return false end
	end
	return true
end
function Auxiliary.AddOrigXrosType(c,isxyz)
	table.insert(Auxiliary.Xroses,c)
	Auxiliary.Customs[c]=true
	local isxyz=isxyz==nil and false or isxyz
	Auxiliary.Xroses[c]=function() return isxyz end
end
function Auxiliary.AddXrosProc(c,xscheck,gd,...)
	--xscheck - extra check after everything is settled, djn - Xros "level"
	--... format - material filter, minimum-of, maximum-of; use aux.TRUE for generic materials
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local t={...}
	local list={}
	local min,max
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
		if #t<2 then break end
	end
	Auxiliary.HasLoad=true
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_SINGLE)
	ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ge1:SetCode(EFFECT_GRADE)
	ge1:SetValue(Auxiliary.GradeVal(gd))
	c:RegisterEffect(ge1)
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC)
	ge2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ge2:SetRange(LOCATION_EXTRA)
	ge2:SetCondition(Auxiliary.XrosCondition(xscheck,table.unpack(list)))
	ge2:SetTarget(Auxiliary.XrosTarget(xscheck,table.unpack(list)))
	ge2:SetOperation(Auxiliary.XrosOperation)
	ge2:SetValue(SUMMON_TYPE_XROS)
	c:RegisterEffect(ge2)
	local ge3=Effect.CreateEffect(c)
	ge3:SetType(EFFECT_TYPE_SINGLE)
	ge3:SetCode(EFFECT_ADD_RACE)
	ge3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ge3:SetValue(function(e,c)
		local rc=0
		for tc in aux.Next(c:GetCoreGroup()) do rc=rc|tc:GetRace() end
		return rc
	end)
	c:RegisterEffect(ge3)
end
function Auxiliary.XrosEffectCon(f,...)
	local ext_params={...}
	return	function(e)
				local c=e:GetHandler()
				local g=c:GetCoreGroup()
				return f and (g-c:GetMaterial()):IsExists(f,1,nil,table.unpack(ext_params)) or g:IsExists(Card.IsType,1,nil,TYPE_EFFECT)
			end
end
function Auxiliary.GradeVal(gd)
	return	function(e,c)
				local gd=gd
				--insert modifications here
				return gd
			end
end
function Auxiliary.XrosMatFilter(c,xsc,tp,...)
	if c:IsFacedown() or not c:IsCanBeXrosMaterial(xsc) then return false end
	for _,f in ipairs({...}) do
		if f(c,xsc,tp) then return true end
	end
	return false
end
function Auxiliary.XsCheckRecursive(c,tp,sg,mg,xsc,ct,djn,xscheck,...)
	if not c:IsLevelAbove(1) and not c:IsRankAbove(1) then return false end
	sg:AddCard(c)
	ct=ct+1
	local funs,max,chk={...},0
	for i=1,#funs do
		max=max+funs[i][3]
		if funs[i][1](c) then
			chk=true
		end
	end
	if max>99 then max=99 end
	local res=chk and (Auxiliary.XsCheckGoal(tp,sg,xsc,ct,xscheck,...)
		or (ct<max and mg:IsExists(Auxiliary.XsCheckRecursive,1,sg,tp,sg,mg,xsc,ct,djn,xscheck,...)))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.XsCheckGoal(tp,sg,xsc,ct,xscheck,...)
	local funs,min={...},0
	for i=1,#funs do
		if not sg:IsExists(funs[i][1],funs[i][2],nil) then return false end
		min=min+funs[i][2]
	end
	return ct>=min and (not xscheck or xscheck(sg,xsc,tp))
		and Duel.GetLocationCountFromEx(tp,tp,sg,xsc)>0
		and not sg:IsExists(Auxiliary.XrosUncompatibilityFilter,1,nil,sg,xsc,tp)
end
function Auxiliary.XrosUncompatibilityFilter(c,sg,xsc,tp)
	local mg=sg:Filter(aux.TRUE,c)
	return not Auxiliary.XrosCheckOtherMaterial(c,mg,xsc,tp)
end
function Auxiliary.XrosCheckOtherMaterial(c,mg,xsc,tp)
	local le={c:IsHasEffect(EFFECT_EXTRA_XROS_MATERIAL,tp)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		if f and type(f)=="function" and not f(te,xsc,mg) then return false end
	end
	return true
end
function Auxiliary.XrosExtraFilter(c,xc,tp,...)
	local flist={...}
	local check=false
	for i=1,#flist do
		if flist[i][1](c) then
			check=true
		end
	end
	local tef1={c:IsHasEffect(EFFECT_EXTRA_XROS_MATERIAL,tp)}
	local ValidSubstitute=false
	for _,te1 in ipairs(tef1) do
		local con=te1:GetCondition()
		if (not con or con(c,xc,1)) then ValidSubstitute=true end
	end
	if not ValidSubstitute or c:IsLocation(LOCATION_ONFIELD) and not c:IsFaceup() then return false end
	return c:IsCanBeXrosMaterial(xc) and (not flist or #flist<=0 or check)
end
function Auxiliary.XrosCondition(xscheck,...)
	local funs={...}
	return	function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local gd=c:GetGrade()
				local mg=Duel.GetMatchingGroup(Card.IsCanBeXrosMaterial,tp,LOCATION_MZONE,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.XrosExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local fg=aux.GetMustMaterialGroup(tp,EFFECT_MUST_BE_XROS_MATERIAL)
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				Duel.SetSelectedCard(fg)
				local sg=Group.CreateGroup()
				return g_Reserve[tp]>=gd and mg:IsExists(Auxiliary.XsCheckRecursive,1,nil,tp,sg,mg,c,0,gd,xscheck,table.unpack(funs))
			end
end
function Auxiliary.XrosTarget(xscheck,...)
	local funs,min,max={...},0,0
	for i=1,#funs do min=min+funs[i][2] max=max+funs[i][3] end
	if max>99 then max=99 end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetMatchingGroup(Card.IsCanBeXrosMaterial,tp,LOCATION_MZONE,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.XrosExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local ogmg=mg:Clone()
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_XROS_MATERIAL)}
				for _,te in ipairs(ce) do
					local tc=te:GetHandler()
					if tc then bg:AddCard(tc) end
				end
				if #bg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					bg:Select(tp,#bg,#bg,nil)
				end
				local sg=Group.CreateGroup()
				sg:Merge(bg)
				local finish=false
				local gd=c:GetGrade()
				while #sg<max do
					finish=Auxiliary.XsCheckGoal(tp,sg,c,#sg,xscheck,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.XsCheckRecursive,sg,tp,sg,mg,c,#sg,gd,xscheck,table.unpack(funs))
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
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function Auxiliary.XrosOperation(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.Overlay(c,g)
	Duel.ChangeReserve(tp,-c:GetGrade())
	g:DeleteGroup()
end
