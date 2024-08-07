--coded by Lyris
--スペーシュル召喚
--Not yet finalized values
--Custom constants
EFFECT_CANNOT_BE_SPACE_MATERIAL	=501
EFFECT_MUST_BE_SPACE_MATERIAL	=502
EFFECT_EXTRA_SPACE_MATERIAL		=503
TYPE_SPATIAL					=0x800000000
TYPE_CUSTOM						=TYPE_CUSTOM|TYPE_SPATIAL
CTYPE_SPATIAL					=0x8
CTYPE_CUSTOM					=CTYPE_CUSTOM|CTYPE_SPATIAL
SUMMON_TYPE_SPATIAL				=SUMMON_TYPE_SPECIAL+500
REASON_SPATIAL					=0x80000000

--Custom Type Table
Auxiliary.Spatials={} --number as index = card, card as index = function() is_xyz
table.insert(aux.CannotBeEDMatCodes,EFFECT_CANNOT_BE_SPACE_MATERIAL)

--overwrite constants
TYPE_EXTRA						=TYPE_EXTRA|TYPE_SPATIAL

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, change_position, get_fusion_type, get_synchro_type, get_xyz_type, get_link_type, get_ritual_type = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Duel.ChangePosition, Card.GetFusionType, Card.GetSynchroType, Card.GetXyzType, Card.GetLinkType, Card.GetRitualType

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Spatials[c] then
		tpe=tpe|TYPE_SPATIAL
		if not Auxiliary.Spatials[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Spatials[c] then
		tpe=tpe|TYPE_SPATIAL
		if not Auxiliary.Spatials[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Spatials[c] then
		tpe=tpe|TYPE_SPATIAL
		if not Auxiliary.Spatials[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Duel.ChangePosition=function(cc, au, ad, du, dd)
	if not ad then ad=au end if not du then du=au end if not dd then dd=au end
	local cc=Group.CreateGroup()+cc
	local tg=cc:Clone()
	local ct=0
	for c in aux.Next(tg) do
		if ((c:IsAttackPos() and bit.band(au,POS_FACEDOWN)>0)
			or (c:IsPosition(POS_FACEUP_DEFENSE) and bit.band(du,POS_FACEDOWN)>0))
			and c:SwitchSpace() then
			if c:IsAttackPos() then ct=ct+change_position(c,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,du,dd) end
			cc:RemoveCard(c)
		end
	end
	return change_position(cc,au,ad,du,dd)+ct
end
Card.GetFusionType=function(c)
	local tpe=get_fusion_type(c)
	if Auxiliary.Spatials[c] then
		tpe=tpe|TYPE_SPATIAL
		if not Auxiliary.Spatials[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetSynchroType=function(c)
	local tpe=get_synchro_type(c)
	if Auxiliary.Spatials[c] then
		tpe=tpe|TYPE_SPATIAL
		if not Auxiliary.Spatials[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetXyzType=function(c)
	local tpe=get_xyz_type(c)
	if Auxiliary.Spatials[c] then
		tpe=tpe|TYPE_SPATIAL
		if not Auxiliary.Spatials[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetLinkType=function(c)
	local tpe=get_link_type(c)
	if Auxiliary.Spatials[c] then
		tpe=tpe|TYPE_SPATIAL
		if not Auxiliary.Spatials[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetRitualType=function(c)
	local res=get_ritual_type(c)
	if Auxiliary.Spatials[c] then
		tpe=tpe|TYPE_SPATIAL
		if not Auxiliary.Spatials[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end

--Custom Functions
function Card.SwitchSpace(c)
	if not Auxiliary.Spatials[c] then return false end
	local ospc=c.spt_other_space
	if not ospc or ospc==0 then return false end
	c:SetEntityCode(ospc,true)
	Duel.CreateToken(0,ospc)
	Duel.SetMetatable(c,_G["c"..ospc])
	c:ReplaceEffect(ospc,0,0)
	c:ResetEffect(c:GetOriginalCode(),RESET_CARD)
	c:ResetEffect(c:GetOriginalCode(),RESET_CARD)
	_G["c"..ospc].initial_effect(c)
	return true
end
function Card.IsCanBeSpaceMaterial(c,sptc)
	if not (c:IsOnField() or c:IsFaceupEx()) then return false end
	local tef={c:IsHasEffect(EFFECT_CANNOT_BE_SPACE_MATERIAL)}
	for _,te in ipairs(tef) do
		if (type(te:GetValue())=="function" and te:GetValue()(te,sptc)) or te:GetValue()==1 then return false end
	end
	return true
end
function Auxiliary.AddOrigSpatialType(c,issynchro)
	table.insert(Auxiliary.Spatials,c)
	Auxiliary.Customs[c]=true
	local issynchro=issynchro==nil and false or issynchro
	Auxiliary.Spatials[c]=function() return issynchro end
end
function Auxiliary.AddSpatialProc(c,sptcheck,...)
	--sptcheck - extra check after everything is settled
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
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC)
	ge2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ge2:SetRange(LOCATION_EXTRA)
	ge2:SetCondition(Auxiliary.SpatialCondition(sptcheck,table.unpack(list)))
	ge2:SetTarget(Auxiliary.SpatialTarget(sptcheck,table.unpack(list)))
	ge2:SetOperation(Auxiliary.SpatialOperation)
	ge2:SetValue(SUMMON_TYPE_SPATIAL)
	c:RegisterEffect(ge2)
end
function Auxiliary.SpaceMatFilter(c,sptc,tp,...)
	if c:IsFacedown() or not c:IsCanBeSpaceMaterial(sptc) then return false end
	for _,f in ipairs({...}) do
		if f(c,sptc,tp) then return true end
	end
	return false
end
function Auxiliary.SptCheckRecursive(c,tp,sg,mg,fg,sptc,ct,djn,sptcheck,...)
	if not c:IsLevelAbove(1) and not c:IsRankAbove(1) then return false end
	sg:AddCard(c)
	ct=ct+1
	local funs,max,min,chk={...},0,0
	for i=1,#funs do
		min=min+funs[i][2]
		max=max+funs[i][3]
		if funs[i][1](c) then
			chk=true
		end
	end
	local res=chk and (Auxiliary.SptCheckGoal(tp,sg,fg,sptc,ct,sptcheck,...)
		or (ct<max and mg:IsExists(Auxiliary.SptCheckRecursive,1,sg,tp,sg,mg,fg,sptc,ct,djn,sptcheck,...)))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.SptCheckGoal(tp,sg,fg,sptc,ct,sptcheck,...)
	if fg and fg:IsExists(aux.NOT(Card.IsContained),1,nil,sg) then return false end
	local funs,min={...},0
	for i=1,#funs do
		if not sg:IsExists(funs[i][1],funs[i][2],nil) then return false end
		min=min+funs[i][2]
	end
	local djn=sptc:GetLevel()
	if min<djn then Duel.SetSelectedCard(sg) end
	return ct>=min and sg:CheckWithSumGreater(Auxiliary.SpatialValue,djn)
		and sg:IsExists(Auxiliary.SptMatCheck,#sg,nil,sg,sptc)
		and (not sptcheck or sptcheck(sg,sptc,tp)) and Duel.GetLocationCountFromEx(tp,tp,sg,sptc)>0
		and not sg:IsExists(Auxiliary.SpaceUncompatibilityFilter,1,nil,sg,sptc,tp)
end
function Auxiliary.SpaceUncompatibilityFilter(c,sg,sptc,tp)
	local mg=sg:Filter(aux.TRUE,c)
	return not Auxiliary.SpaceCheckOtherMaterial(c,mg,sptc,tp)
end
function Auxiliary.SpaceCheckOtherMaterial(c,mg,sptc,tp)
	local le={c:IsHasEffect(EFFECT_EXTRA_SPACE_MATERIAL,tp)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		if f and type(f)=="function" and not f(te,sptc,mg) then return false end
	end
	return true
end
function Auxiliary.SptMatCheck(c,sg,sptc)
	local djn=sptc:GetLevel()
	return sg:IsExists(function(tc)
		local adiff=math.abs(c:GetAttack()-tc:GetAttack())
		local ddiff=math.abs(c:GetDefense()-tc:GetDefense())
		local rdiff=100*djn
		return adiff<=rdiff or ddiff<=rdiff
	end,1,c)
end
function Auxiliary.SpatialValue(c)
	return c:IsRankAbove(1) and c:GetRank() or c:GetLevel()
end
function Auxiliary.SpaceExtraFilter(c,lc,tp,...)
	local flist={...}
	local check=false
	for i=1,#flist do
		if flist[i][1](c) then
			check=true
		end
	end
	local tef1={c:IsHasEffect(EFFECT_EXTRA_SPACE_MATERIAL,tp)}
	local ValidSubstitute=false
	for _,te1 in ipairs(tef1) do
		local con=te1:GetCondition()
		if (not con or con(c,lc,1)) then ValidSubstitute=true end
	end
	if not ValidSubstitute then return false end
	if c:IsLocation(LOCATION_ONFIELD) and not c:IsFaceup() then return false end
	return c:IsCanBeSpaceMaterial(lc) and (not flist or #flist<1 or check)
end
function Auxiliary.SpatialCondition(sptcheck,...)
	local funs={...}
	return  function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local djn=c:GetLevel()
				local mg=Duel.GetMatchingGroup(Card.IsCanBeSpaceMaterial,tp,LOCATION_MZONE,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.SpaceExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local fg=aux.GetMustMaterialGroup(tp,EFFECT_MUST_BE_SPACE_MATERIAL)
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				local sg=Group.CreateGroup()
				return mg:IsExists(Auxiliary.SptCheckRecursive,1,nil,tp,sg,mg,fg,c,0,djn,sptcheck,table.unpack(funs))
			end
end
function Auxiliary.SpatialTarget(sptcheck,...)
	local funs,min,max={...},0,0
	for i=1,#funs do min=min+funs[i][2] max=max+funs[i][3] end
	if max>99 then max=99 end
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetMatchingGroup(Card.IsCanBeSpaceMaterial,tp,LOCATION_MZONE,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.SpaceExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local ogmg=mg:Clone()
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_SPACE_MATERIAL)}
				for _,te in ipairs(ce) do
					local tc=te:GetHandler()
					if tc then bg:AddCard(tc) end
				end
				if #bg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					bg:Select(tp,#bg,#bg,nil)
				end
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_BIGBANG_MATERIAL)
				local sg=Group.CreateGroup()
				sg:Merge(bg)
				local finish=false
				local djn=c:GetLevel()
				while #sg<max do
					finish=Auxiliary.SptCheckGoal(tp,sg,fg,c,#sg,sptcheck,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.SptCheckRecursive,sg,tp,sg,mg,fg,c,#sg,djn,sptcheck,table.unpack(funs))
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
				end
				if finish then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function Auxiliary.SpatialOperation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	if Duel.SetSummonCancelable then Duel.SetSummonCancelable(true) end
	local ospc=Duel.CreateToken(tp,c.spt_other_space)
	if Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetOriginalCode(),nil,c:GetType(),ospc:GetAttack(),ospc:GetDefense(),c:GetLevel(),ospc:GetRace(),ospc:GetAttribute()) then
		Duel.ConfirmCards(tp,ospc)
		if not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPATIAL,tp,false,false)
				or Duel.SelectEffectYesNo(tp,c,aux.Stringid(c:GetOriginalCode(),15)) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_DECK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetOperation(function() c:SwitchSpace() e1:Reset() end)
			c:RegisterEffect(e1,true)
		end
	end
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	local rg=Group.CreateGroup()
	for tc in aux.Next(g) do
		if c:IsHasEffect(EFFECT_EXTRA_SPACE_MATERIAL) then
			local tef={tc:IsHasEffect(EFFECT_EXTRA_SPACE_MATERIAL)}
			for _,te in ipairs(tef) do
				local op=te:GetOperation()
				if op then op(tc,tp)
				else rg:AddCard(tc) end
			end
		else rg:AddCard(tc) end
	end
	Duel.SendtoGrave(rg,REASON_MATERIAL+REASON_SPATIAL)
	g:DeleteGroup()
end
