--created by NovaTsukimori, coded by Lyris
--Not yet finalized values
--Custom constants
EFFECT_NEGATIVE_LEVEL				=432
EFFECT_CANNOT_BE_IMPURE_MATERIAL	=433
EFFECT_EXTRA_IMPURE_MATERIAL		=434
EFFECT_MUST_BE_IMPURE_MATERIAL		=435
TYPE_IMPURE							=0x4000000000000
TYPE_CUSTOM							=TYPE_CUSTOM|TYPE_IMPURE
CTYPE_IMPURE						=0x40000
CTYPE_CUSTOM						=CTYPE_CUSTOM|CTYPE_IMPURE

SUMMON_TYPE_IMPURE					=35

REASON_IMPURE						=0x200000000

TYPE_EXTRA							=TYPE_EXTRA|TYPE_IMPURE

--Custom Type Table
Auxiliary.Impures={}

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_rank, get_orig_rank, prev_rank_field, is_rank, is_rank_below, is_rank_above, get_level, get_syn_level, get_rit_level, get_orig_level, is_xyz_level, get_prev_level_field, is_level, is_level_below, is_level_above =
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetRank, Card.GetOriginalRank, Card.GetPreviousRankOnField, Card.IsRank, Card.IsRankBelow, Card.IsRankAbove, Card.GetLevel,Card.GetSynchroLevel, Card.GetRitualLevel, Card.GetOriginalLevel, Card.IsXyzLevel, Card.GetPreviousLevelOnField, Card.IsLevel, Card.IsLevelBelow, Card.IsLevelAbove

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Impures[c] then
		tpe=tpe|TYPE_IMPURE
		if not Auxiliary.Impures[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Impures[c] then
		tpe=tpe|TYPE_IMPURE
		if not Auxiliary.Impures[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Impures[c] then
		tpe=tpe|TYPE_IMPURE
		if not Auxiliary.Impures[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetRank=function(c)
	if Auxiliary.Impures[c] then return 0 end
	return get_rank(c)
end
Card.GetOriginalRank=function(c)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return 0 end
	return get_orig_rank(c)
end
Card.GetPreviousRankOnField=function(c)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return 0 end
	return prev_rank_field(c)
end
Card.IsRank=function(c,...)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return false end
	local funs={...}
	for key,value in pairs(funs) do
		if c:GetRank()==value then return true end
	end
	return false
end
Card.IsRankBelow=function(c,rk)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return false end
	return is_rank_below(c,rk)
end
Card.IsRankAbove=function(c,rk)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return false end
	return is_rank_above(c,rk)
end
Card.GetLevel=function(c)
	local lv=get_level(c)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then
		local te=c:IsHasEffect(EFFECT_NEGATIVE_LEVEL)
		if type(te:GetValue())=='function' then
			lv=-te:GetValue()(te,c)
		else lv=-te:GetValue() end
	end
	return lv
end
Card.GetSynchroLevel=function(c,sc)
	local lv=get_syn_level(c,sc)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then
		local te=c:IsHasEffect(EFFECT_NEGATIVE_LEVEL)
		if type(te:GetValue())=='function' then
			lv=-te:GetValue()(te,c)
		else lv=-te:GetValue() end
	end
	return lv
end
Card.GetRitualLevel=function(c,rc)
	local lv=get_rit_level(c,rc)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then
		local te=c:IsHasEffect(EFFECT_NEGATIVE_LEVEL)
		if type(te:GetValue())=='function' then
			lv=-te:GetValue()(te,c)
		else lv=-te:GetValue() end
	end
	return lv
end
Card.GetOriginalLevel=function(c)
	local lv=get_orig_level(c)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then
		local te=c:IsHasEffect(EFFECT_NEGATIVE_LEVEL)
		if type(te:GetValue())=='function' then
			lv=-te:GetValue()(te,c)
		else lv=-te:GetValue() end
	end
	return lv
end
Card.IsXyzLevel=function(c,xyz,lv)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then
		if c:IsStatus(STATUS_NO_LEVEL) then return false end
		if lv==c:GetLevel() then return true end
		local xle={c:IsHasEffect(EFFECT_XYZ_LEVEL)}
		if #xle==0 then return false end
		local lev=xle[1]:GetValue()
		return lev&0xffff==lv or lev>>16==lv
	end
	return is_xyz_level(c,xyz,lv)
end
Card.GetPreviousLevelOnField=function(c)
	local lv=get_prev_level_field(c)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then
		local te=c:IsHasEffect(EFFECT_NEGATIVE_LEVEL)
		if type(te:GetValue())=='function' then
			lv=-te:GetValue()(te,c)
		else lv=-te:GetValue() end
	end
	return lv
end
Card.IsLevel=function(c,...)
	local funs={...}
	for key,value in pairs(funs) do
		if c:GetLevel()==value then return true end
	end
	return false
end
Card.IsLevelBelow=function(c,lv)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return c:GetLevel()<=lv end
	return is_level_below(c,lv)
end
Card.IsLevelAbove=function(c,lv)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return c:GetLevel()>=lv end
	return is_level_above(c,lv)
end
Card.GetRank=function(c)
	if Auxiliary.Impures[c] then return 0 end
	return get_rank(c)
end
Card.GetOriginalRank=function(c)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return 0 end
	return get_orig_rank(c)
end
Card.GetPreviousRankOnField=function(c)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return 0 end
	return prev_rank_field(c)
end
Card.IsRank=function(c,...)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return false end
	local funs={...}
	for key,value in pairs(funs) do
		if c:GetRank()==value then return true end
	end
	return false
end
Card.IsRankBelow=function(c,rk)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return false end
	return is_rank_below(c,rk)
end
Card.IsRankAbove=function(c,rk)
	if Auxiliary.Impures[c] and not Auxiliary.Impures[c]() then return false end
	return is_rank_above(c,rk)
end

--Custom functions
function Card.IsCanBeImpureMaterial(c,ec)
	if c:IsControler(1-ec:GetControler()) or not c:IsLocation(LOCATION_MZONE) then
		local tef1={c:IsHasEffect(EFFECT_EXTRA_IMPURE_MATERIAL,tp)}
		local ValidSubstitute=false
		for _,te1 in ipairs(tef1) do
			local con=te1:GetCondition()
			if (not con or con(c,ec,1)) then ValidSubstitute=true end
		end
		if not ValidSubstitute then return false end
	else
		if c:IsFacedown() then return false end
	end
	local tef2={c:IsHasEffect(EFFECT_CANNOT_BE_IMPURE_MATERIAL)}
	for _,te2 in ipairs(tef2) do
		local tev=te2:GetValue()
		if type(tev)=='function' then
			if tev(te2,ec) then return false end
		elseif tev~=0 then return false end
	end
	return true
end
function Auxiliary.AddOrigImpureType(c,isxyz)
	table.insert(Auxiliary.Impures,c)
	Auxiliary.Customs[c]=true
	local isxyz=isxyz==nil and false or isxyz
	Auxiliary.Impures[c]=function() return isxyz end
end
function Auxiliary.AddImpureProc(c,lv,...)
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
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_NEGATIVE_LEVEL)
	e1:SetValue(Auxiliary.NegLevelVal(lv))
	c:RegisterEffect(e1)
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC)
	ge2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ge2:SetRange(LOCATION_EXTRA)
	ge2:SetCondition(Auxiliary.ImpureCondition(min,max,table.unpack(list)))
	ge2:SetTarget(Auxiliary.ImpureTarget(min,max,table.unpack(list)))
	ge2:SetOperation(Auxiliary.ImpureOperation)
	ge2:SetValue(function() return SUMMON_TYPE_IMPURE,c:IsType(TYPE_EXTRA&~TYPE_IMPURE) and nil or 0x1f end)
	c:RegisterEffect(ge2)
	if not impure_check then
		impure_check=true
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
		e0:SetTargetRange(LOCATION_EXTRA,0)
		e0:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_IMPURE))
		e0:SetValue(1)
		Duel.RegisterEffect(e0,tp)
	end
end
function Auxiliary.NegLevelVal(lv)
	return  function(e,c)
				local lv=lv
				--insert modifications here
				return lv
			end
end
function Auxiliary.ImpureRecursiveFilter(c,tp,sg,mg,ec,ct,minc,maxc,...)
	sg:AddCard(c)
	ct=ct+1
	local res=Auxiliary.ImpureCheckGoal(tp,sg,ec,minc,ct,...)
		or (ct<maxc and mg:IsExists(Auxiliary.ImpureRecursiveFilter,1,sg,tp,sg,mg,ec,ct,minc,maxc,...))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.ImpureCheckGoal(tp,sg,ec,minc,ct,...)
	local funs={...}
	for _,f in pairs(funs) do
		if not sg:IsExists(f[1],f[2],nil) then return false end
	end
	return ct>=minc and sg:CheckWithSumEqual(Card.GetLevel,-ec:GetLevel(),ct,ct,ec) and Duel.GetLocationCountFromEx(tp,tp,sg,ec)>0
end
function Auxiliary.ImpureCondition(min,max,...)
	local funs={...}
	return  function(e,c)
				if c==nil then return true end
				if (c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_PANDEMONIUM)) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=Duel.GetMatchingGroup(Card.IsCanBeImpureMaterial,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE+LOCATION_FZONE,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE+LOCATION_FZONE,nil,c)
				local fg=aux.GetMustMaterialGroup(tp,EFFECT_MUST_BE_IMPURE_MATERIAL)
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				Duel.SetSelectedCard(fg)
				return mg:IsExists(Auxiliary.ImpureRecursiveFilter,1,nil,tp,Group.CreateGroup(),mg,c,0,min,max,table.unpack(funs))
			end
end
function Auxiliary.ImpureTarget(minc,maxc,...)
	local funs={...}
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetMatchingGroup(Card.IsCanBeImpureMaterial,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE+LOCATION_FZONE,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE+LOCATION_FZONE,nil,c)
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_IMPURE_MATERIAL)}
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
				while not (#sg>=maxc) do
					finish=Auxiliary.ImpureCheckGoal(tp,sg,c,minc,#sg,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.ImpureRecursiveFilter,sg,tp,sg,mg,c,#sg,minc,maxc,table.unpack(funs))
					if #cg==0 then break end
					local cancel=not finish
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					local tc=cg:SelectUnselect(sg,tp,finish,cancel,minc,maxc)
					if not tc then break end
					if not bg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
							if #sg>=maxc then finish=true end
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
function Auxiliary.ImpureOperation(e,tp,eg,ep,ev,re,r,rp,c)
	if Duel.SetSummonCancelable then Duel.SetSummonCancelable(true) end
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	for tc in aux.Next(g) do
		if not tc:IsLocation(LOCATION_MZONE) then
			local tef={tc:IsHasEffect(EFFECT_EXTRA_IMPURE_MATERIAL)}
			for _,te in ipairs(tef) do
				te:GetOperation()(tc,tp)
			end
			g:RemoveCard(tc)
		end
	end
	Duel.Overlay(c,g)
	g:DeleteGroup()
end
