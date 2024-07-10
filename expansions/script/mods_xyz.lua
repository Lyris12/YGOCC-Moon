EFFECT_ALLOW_EXTRA_XYZ_MATERIAL = 100000253

local add_xyz_proc, add_xyz_proc_nlv, duel_overlay, card_is_xyz_level, duel_check_xyz_mat, duel_select_xyz_mat, _XyzLevelFreeGoal =
Auxiliary.AddXyzProcedure, Auxiliary.AddXyzProcedureLevelFree, Duel.Overlay, Card.IsXyzLevel, Duel.CheckXyzMaterial, Duel.SelectXyzMaterial, Auxiliary.XyzLevelFreeGoal

Auxiliary.AddXyzProcedure=function(tc,f,lv,ct,alterf,desc,maxct,op)
	add_xyz_proc(tc,f,lv,ct,alterf,desc,maxct,op)
	local mt=getmetatable(tc)
	mt.material_filter=f
	mt.material_minct=ct
	mt.material_maxct=maxct~=nil and maxct or ct
end
Auxiliary.AddXyzProcedureLevelFree=function(tc,f,gf,minc,maxc,alterf,desc,op)
	add_xyz_proc_nlv(tc,f,gf,minc,maxc,alterf,desc,op)
	local mt=getmetatable(tc)
	mt.material_filter=f
	mt.material_minct=minc
	mt.material_maxct=maxc
end
Duel.Overlay=function(xyz,mat)
	local og,oct
	if xyz:IsLocation(LOCATION_MZONE) then
		og=xyz:GetOverlayGroup()
		oct=#og
	end
	duel_overlay(xyz,mat)
	if oct and xyz:GetOverlayCount()>oct then
		Duel.RaiseEvent(mat,EVENT_XYZATTACH,nil,0,0,xyz:GetControler(),xyz:GetOverlayCount()-oct)
	end
	local mg=Group.CreateGroup()
	if aux.GetValueType(mat)=="Card" then
		mg:AddCard(mat)
	else
		mg:Merge(mat)
	end
	for mc in aux.Next(mg) do
		if not mc:IsHasEffect(EFFECT_REMEMBER_XYZ_HOLDER) then
			local e1=Effect.CreateEffect(mc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_REMEMBER_XYZ_HOLDER)
			e1:SetLabelObject(xyz)
			mc:RegisterEffect(e1)
		else
			local ef={mc:IsHasEffect(EFFECT_REMEMBER_XYZ_HOLDER)}
			local e1=ef[1]
			e1:SetLabelObject(xyz)
		end
	end
end

function Auxiliary.XyzMaterialComplete(c,sc,lv,tp)
	if not c:IsCanBeXyzMaterial(sc) then return false end
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsFaceup() and (c:IsControler(tp) or c:IsHasEffect(EFFECT_XYZ_MATERIAL))
	else
		for _,ce in ipairs({sc:IsHasEffect(EFFECT_ALLOW_EXTRA_XYZ_MATERIAL)}) do
			local val=ce:Evaluate(c,sc)
			if val then
				return true
			end
		end
		for _,ce in ipairs({c:IsHasEffect(EFFECT_EXTRA_XYZ_MATERIAL)}) do
			local val=ce:Evaluate(c,sc)
			if val then
				return true
			end
		end
		return false
	end
end
Duel.CheckXyzMaterial=function(sc,f,lv,min,max,mg)
	local res=duel_check_xyz_mat(sc,f,lv,min,max,mg)
	if mg~=nil then return res end
	if res then
		return true
	elseif self_reference_effect then
		local extramats=Duel.GetMatchingGroup(Auxiliary.XyzMaterialComplete,0,0xff,0xff,nil,sc,lv,self_reference_effect:GetHandlerPlayer())
		return duel_check_xyz_mat(sc,f,lv,min,max,extramats)
	end
	return res
end
Duel.SelectXyzMaterial=function(p,sc,f,lv,min,max,mg)
	if mg~=nil then
		return duel_select_xyz_mat(p,sc,f,lv,min,max,mg)
	else
		local extramats=Duel.GetMatchingGroup(Auxiliary.XyzMaterialComplete,0,0xff,0xff,nil,sc,lv,p)
		return duel_select_xyz_mat(p,sc,f,lv,min,max,extramats)
	end
end

Auxiliary.XyzLevelFreeGoal = function(g,tp,xyzc,gf)
	return (not gf or gf(g,tp,xyzc)) and Duel.GetLocationCountFromEx(tp,tp,g,xyzc)>0
end

--LevelFree Procedure Mods
local _XyzLevelFreeCondition, _XyzLevelFreeTarget = Auxiliary.XyzLevelFreeCondition, Auxiliary.XyzLevelFreeTarget

function Auxiliary.ExtraXyzMaterialFilter(c,xyzc,tp)
	if not c:IsCanBeXyzMaterial(xyzc) then return false end
	for _,ce in ipairs({xyzc:IsHasEffect(EFFECT_ALLOW_EXTRA_XYZ_MATERIAL)}) do
		local val=ce:Evaluate(c,xyzc,tp)
		if val then
			return true
		end
	end
	return false
end

function Auxiliary.XyzLevelFreeCondition(f,gf,minct,maxct)
	if not aux.EnableXyzLevelFreeMods then
		return _XyzLevelFreeCondition(f,gf,minct,maxct)
	else
		return	function(e,c,og,min,max)
					if c==nil then return true end
					if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
					local tp=c:GetControler()
					local minc=minct
					local maxc=maxct
					if min then
						minc=math.max(minc,min)
						maxc=math.min(maxc,max)
					end
					if maxc<minc then return false end
					local mg=nil
					if og then
						mg=og:Filter(Auxiliary.XyzLevelFreeFilter,nil,c,f)
					else
						mg=Duel.GetMatchingGroup(Auxiliary.XyzLevelFreeFilter,tp,LOCATION_MZONE,0,nil,c,f)
					end
					
					--Handle extra Xyz Materials
					local exg
					if c:IsHasEffect(EFFECT_EXTRA_XYZ_MATERIAL) then
						exg=Duel.GetMatchingGroup(aux.ExtraXyzMaterialFilter,tp,LOCATION_ALL,LOCATION_ALL,nil,c,tp)
						if #exg>0 then
							mg:Merge(exg)
						end
					end
					--
					
					local sg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_XMATERIAL)
					if sg:IsExists(Auxiliary.MustMaterialCounterFilter,1,nil,mg) then return false end
					Duel.SetSelectedCard(sg)
					Auxiliary.GCheckAdditional=Auxiliary.TuneMagicianCheckAdditionalX(EFFECT_TUNE_MAGICIAN_X)
					local res=mg:CheckSubGroup(Auxiliary.XyzLevelFreeGoal,minc,maxc,tp,c,gf)
					Auxiliary.GCheckAdditional=nil
					return res
				end
	end
end
function Auxiliary.XyzLevelFreeTarget(f,gf,minct,maxct)
	if not aux.EnableXyzLevelFreeMods then
		return _XyzLevelFreeTarget(f,gf,minct,maxct)
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
					if og and not min then
						return true
					end
					local minc=minct
					local maxc=maxct
					if min then
						if min>minc then minc=min end
						if max<maxc then maxc=max end
					end
					local mg=nil
					if og then
						mg=og:Filter(Auxiliary.XyzLevelFreeFilter,nil,c,f)
					else
						mg=Duel.GetMatchingGroup(Auxiliary.XyzLevelFreeFilter,tp,LOCATION_MZONE,0,nil,c,f)
					end
					
					--Handle extra Xyz Materials
					local exg
					if c:IsHasEffect(EFFECT_EXTRA_XYZ_MATERIAL) then
						exg=Duel.GetMatchingGroup(aux.ExtraXyzMaterialFilter,tp,LOCATION_ALL,LOCATION_ALL,nil,c,tp)
						if #exg>0 then
							mg:Merge(exg)
						end
					end
					--
					
					local sg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_XMATERIAL)
					Duel.SetSelectedCard(sg)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					local cancel=Duel.IsSummonCancelable()
					Auxiliary.GCheckAdditional=Auxiliary.TuneMagicianCheckAdditionalX(EFFECT_TUNE_MAGICIAN_X)
					local g=mg:SelectSubGroup(tp,Auxiliary.XyzLevelFreeGoal,cancel,minc,maxc,tp,c,gf)
					Auxiliary.GCheckAdditional=nil
					if g and g:GetCount()>0 then
						g:KeepAlive()
						e:SetLabelObject(g)
						return true
					else return false end
				end
	end
end