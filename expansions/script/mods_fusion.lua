EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL 			= 8004

STRING_DO_NOT_USE_AS_EXTRA_FUSION_MATERIAL		= 753

local _SendtoGrave, _Remove, _SendtoDeck, _Destroy, _SendtoHand, _AddFusionProcCode2, _AddFusionProcCodeRep, _AddFusionProcCode2FunRep =
Duel.SendtoGrave, Duel.Remove, Duel.SendtoDeck, Duel.Destroy, Duel.SendtoHand, Auxiliary.AddFusionProcCode2, Auxiliary.AddFusionProcCodeRep, Auxiliary.AddFusionProcCode2FunRep

Auxiliary.FGoalCheckGlitchy = nil
Auxiliary.EnableOnlyGlitchyFusionProcs = false
		
Auxiliary.AddFusionProcCode2 = function(c,code1,code2,sub,insf)
	local cm=getmetatable(c)
	if not cm.FusionMaterialMentions then
		cm.FusionMaterialMentions=2
	end
	_AddFusionProcCode2(c,code1,code2,sub,insf)
end
Auxiliary.AddFusionProcCodeRep = function(c,code1,cc,sub,insf)
	local cm=getmetatable(c)
	if not cm.FusionMaterialMentions then
		cm.FusionMaterialMentions=cc
	end
	_AddFusionProcCodeRep(c,code1,cc,sub,insf)
end
Auxiliary.AddFusionProcCode2FunRep = function(c,code1,code2,f,minc,maxc,sub,insf)
	local cm=getmetatable(c)
	if not cm.FusionMaterialMentions then
		cm.FusionMaterialMentions=2
	end
	_AddFusionProcCode2FunRep(c,code1,code2,f,minc,maxc,sub,insf)
end

--

function Auxiliary.AddFusionProcMixRep(c,sub,insf,fun1,minc,maxc,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local val={fun1,...}
	local fun={}
	local mat={}
	for i=1,#val do
		if type(val[i])=='function' then
			fun[i]=function(c,fc,sub,mg,sg) return val[i](c,fc,sub,mg,sg) and not c:IsHasEffect(6205579) end
		elseif type(val[i])=='table' then
			fun[i]=function(c,fc,sub,mg,sg)
					for _,fcode in ipairs(val[i]) do
						if type(fcode)=='function' then
							if fcode(c,fc,sub,mg,sg) and not c:IsHasEffect(6205579) then return true end
						else
							if c:IsFusionCode(fcode) or (sub and c:CheckFusionSubstitute(fc)) then return true end
						end
					end
					return false
			end
			for _,fcode in ipairs(val[i]) do
				if type(fcode)~='function' then mat[fcode]=true end
			end
		else
			fun[i]=function(c,fc,sub) return c:IsFusionCode(val[i]) or (sub and c:CheckFusionSubstitute(fc)) end
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
	if mt.material_funs==nil then
		mt.material_funs=fun
	end
	for index,_ in pairs(mat) do
		Auxiliary.AddCodeList(c,index)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.FConditionMixRep(insf,sub,fun[1],minc,maxc,table.unpack(fun,2)))
	e1:SetOperation(Auxiliary.FOperationMixRep(insf,sub,fun[1],minc,maxc,table.unpack(fun,2)))
	c:RegisterEffect(e1)
end

--
function Auxiliary.GlitchyFMaterialExFilter(c,ce,tg,tp,fc,sub,mg,sg,depth)
	return not c:IsImmuneToEffect(ce) and (not tg or tg(ce,c,tp,fc,sub,mg,sg,depth))
end
function Auxiliary.FMaterialFilterSelEx(c,exg,extramats_repetead)
	return exg:IsContains(c) and (not extramats_repetead[c] or extramats_repetead[c]<=0)
end
function Auxiliary.FCheckMixExGoal(sg,tp,fc,sub,chkfnf,original_mats,extra_mats,eset,extra_maxs,chk,...)
	local chkf=chkfnf&0xff
	local concat_fusion=chkfnf&0x200>0
	if not concat_fusion and sg:IsExists(Auxiliary.TuneMagicianCheckX,1,nil,sg,EFFECT_TUNE_MAGICIAN_F) then return false end
	if not Auxiliary.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	local g=Group.CreateGroup()
	
	
	local res=sg:IsExists(Auxiliary.FCheckMixEx,1,nil,tp,sg,g,fc,sub,original_mats,extra_mats,eset,extra_maxs,chk,...)
	if not res then return false end
	
	local res1=(chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0)
	if not res1 then return false end
	
	local res2=(not Auxiliary.FCheckAdditional or Auxiliary.FCheckAdditional(tp,sg,fc,original_mats,extra_mats,eset,extra_maxs,chk))
	if not res2 then return false end
	
	local res3=(not Auxiliary.FGoalCheckAdditional or Auxiliary.FGoalCheckAdditional(tp,sg,fc,original_mats,extra_mats,eset,extra_maxs,chk))
	if not res3 then return false end
	
	local res4=(not Auxiliary.FGoalCheckGlitchy or Auxiliary.FGoalCheckGlitchy(tp,sg,fc,sub,chkfnf))
	if not res4 then return false end
	
	----Debug.Message(res4)
	return true
end
Auxiliary.ValidExtraFusionMaterialEffects={}
function Auxiliary.FCheckMixEx(c,tp,mg,sg,fc,sub,original_mats,extra_mats,eset,extra_maxs,chk,fun1,fun2,...)
	local res=false
	local is_valid_mat=0
	--Debug.Message('---------')
	--Debug.Message(#sg)
	if fun2 then
		sg:AddCard(c)
		--Debug.Message(c:GetCode())
		--Check if the card complies with the regular material requirements
		
		if fun1(c,fc,false,mg,sg) then
			is_valid_mat=1
			if original_mats:IsContains(c) then
				res=mg:IsExists(Auxiliary.FCheckMixEx,1,sg,tp,mg,sg,fc,sub,original_mats,extra_mats,eset,extra_maxs,chk,fun2,...)
			end
		elseif sub and fun1(c,fc,sub,mg,sg) then
			is_valid_mat=2
			if original_mats:IsContains(c) then
				res=mg:IsExists(Auxiliary.FCheckMixEx,1,sg,tp,mg,sg,fc,false,original_mats,extra_mats,eset,extra_maxs,chk,fun2,...)
			end
		end
		
		-- if is_valid_mat>0 then
			-- Debug.Message("ORIGINAL CHECK = "..tostring(fun1(c,fc,false,mg,sg)))
		-- end
		
		--If it does not, check if it complies with the special material requirements set by EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL
		if is_valid_mat>0 and type(eset[c])=="table" and (chk==1 or not res) then
			for _,ce in ipairs(eset[c]) do
				local remaining_slots=extra_maxs[ce]
				if remaining_slots>0 then
					local sub2=sub
					if is_valid_mat==2 then
						sub2=false
					end
					extra_maxs[ce]=extra_maxs[ce]-1
					if aux.UsedExtraFusionMaterialGroup then
						aux.UsedExtraFusionMaterialGroup:AddCard(c)
					end
					local res2=mg:IsExists(Auxiliary.FCheckMixEx,1,sg,tp,mg,sg,fc,sub2,original_mats,extra_mats,eset,extra_maxs,chk,fun2,...)
					if aux.UsedExtraFusionMaterialGroup then
						aux.UsedExtraFusionMaterialGroup:RemoveCard(c)
					end
					extra_maxs[ce]=extra_maxs[ce]+1
					if res2 then
						res=true
						if chk==0 then
							break
						else
							if not aux.ValidExtraFusionMaterialEffects[c] then
								aux.ValidExtraFusionMaterialEffects[c]={}
							end
							if not aux.FindInTable(aux.ValidExtraFusionMaterialEffects[c],ce) then
								table.insert(aux.ValidExtraFusionMaterialEffects[c],ce)
							end
						end
					end
				end
			end
		end
		sg:RemoveCard(c)
		-- if res then
			-- Debug.Message("EXTRA CHECK = "..tostring(res))
		-- end
		return res
	else
		
		--Debug.Message(c:GetCode())
		if fun1(c,fc,sub,mg,sg) then
			is_valid_mat=1
			if original_mats:IsContains(c) then
				res=true
			end
		end
		
		-- if is_valid_mat==1 then
			-- Debug.Message("ORIGINAL CHECK 2= "..tostring(is_valid_mat))
		-- end
		if is_valid_mat>0 and type(eset[c])=="table" and (chk==1 or not res) then
			for _,ce in ipairs(eset[c]) do
				local remaining_slots=extra_maxs[ce]
				--Debug.Message("REMAINING SLOTS= "..tostring(remaining_slots))
				if remaining_slots>0 then
					res=true
					if chk==0 then
						break
					else
						if not aux.ValidExtraFusionMaterialEffects[c] then
							aux.ValidExtraFusionMaterialEffects[c]={}
						end
						if not aux.FindInTable(aux.ValidExtraFusionMaterialEffects[c],ce) then
							table.insert(aux.ValidExtraFusionMaterialEffects[c],ce)
						end
					end
				end
			end
		end
		-- if res then
			-- Debug.Message("EXTRA CHECK 2= "..tostring(res))
		-- end
		return res
	end
end

local _FConditionMix, _FOperationMix, _FConditionMixRep, _FOperationMixRep = Auxiliary.FConditionMix, Auxiliary.FOperationMix, Auxiliary.FConditionMixRep, Auxiliary.FOperationMixRep

Auxiliary.FConditionMix = function(insf,sub,...)
	local funs={...}
	return	function(e,g,gc,chkfnf)
				if not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
					return _FConditionMix(insf,sub,table.unpack(funs))(e,g,gc,chkfnf)
				end
				if g==nil then return insf and Auxiliary.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=chkfnf&0x100>0
				local concat_fusion=chkfnf&0x200>0
				local sub2=(sub or notfusion) and not concat_fusion
				local mg=g:Filter(Auxiliary.FConditionFilterMix,c,c,sub2,concat_fusion,table.unpack(funs))
				if gc then
					if not mg:IsContains(gc) then return false end
					Duel.SetSelectedCard(gc)
				end
				
				local eset,extra_maxs={},{}
				local original_mats=mg:Clone()
				local extra_mats=Group.CreateGroup()
				for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
					local res,max=true,999
					local val=ce:GetValue()
					if val then
						res,max=val(ce,c,tp)
					end
					if res then
						local tg=ce:GetTarget()
						local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,nil,ce,tg,tp,c)
						if #exg>0 then
							mg:Merge(exg)
							
							extra_mats:Merge(exg)
							
							for tc in aux.Next(exg) do
								if not eset[tc] then
									eset[tc]={}
								end
								table.insert(eset[tc],ce)
							end
							
							extra_maxs[ce]=max
						end
					end
				end
				
				return mg:CheckSubGroup(Auxiliary.FCheckMixExGoal,#funs,#funs,tp,c,sub2,chkfnf,original_mats,extra_mats,eset,extra_maxs,0,table.unpack(funs))
			end
end

function Auxiliary.FOperationMix(insf,sub,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local c=e:GetHandler()
				local tp=c:GetControler()
				
				if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
					return _FOperationMix(insf,sub,table.unpack(funs))(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				end
				
				local notfusion=chkfnf&0x100>0
				local concat_fusion=chkfnf&0x200>0
				local sub=(sub or notfusion) and not concat_fusion
				local mg=eg:Filter(Auxiliary.FConditionFilterMix,c,c,sub,concat_fusion,table.unpack(funs))
				if gc then Duel.SetSelectedCard(Group.FromCards(gc)) end
				--
				local eset,extra_maxs={},{}
				local original_mats=mg:Clone()
				local extra_mats=Group.CreateGroup()
				for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
					local res,max=true,999
					local val=ce:GetValue()
					if val then
						res,max=val(ce,c,tp)
					end
					if res then
						local tg=ce:GetTarget()
						local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,nil,ce,tg,tp,c)
						if #exg>0 then
							mg:Merge(exg)
							
							extra_mats:Merge(exg)
							
							for tc in aux.Next(exg) do
								if not eset[tc] then
									eset[tc]={}
								end
								table.insert(eset[tc],ce)
							end
							
							extra_maxs[ce]=max
						end
					end
				end
				
				aux.ValidExtraFusionMaterialEffects={}
				aux.UsedExtraFusionMaterialEffects={}
				
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
				local sg=mg:SelectSubGroup(tp,Auxiliary.FCheckMixExGoal,false,#funs,#funs,tp,c,sub,chkfnf,original_mats,extra_mats,eset,extra_maxs,1,table.unpack(funs))
				
				local exg=sg:Filter(Card.IsContained,nil,extra_mats)
				for tc in aux.Next(exg) do
					local hintg=Group.FromCards(tc):Select(tp,1,1,nil)
					local available_effs={}
					local extra_descs={}
					local is_original_mat=1
					
					if original_mats:IsContains(tc) then
						local check=true
						if aux.FCheckAdditional then
							extra_mats:RemoveCard(tc)
							check=aux.FCheckAdditional(tp,sg,c,original_mats,extra_mats,eset,extra_maxs,1)
							extra_mats:AddCard(tc)
						end
						if check then
							is_original_mat=0
							table.insert(extra_descs,STRING_DO_NOT_USE_AS_EXTRA_FUSION_MATERIAL)
						end
					end
					
					for _,eff in ipairs(aux.ValidExtraFusionMaterialEffects[tc]) do
						if extra_maxs[eff]>0 then
							table.insert(available_effs,eff)
							table.insert(extra_descs,eff:GetDescription())
						end
					end
					local opt=Duel.SelectOption(tp,table.unpack(extra_descs))+is_original_mat
					
					if opt~=0 then
						local eff=available_effs[opt]
						if aux.GetValueType(eff)=="Effect" then
							if not aux.FindInTable(aux.UsedExtraFusionMaterialEffects,eff) then
								table.insert(aux.UsedExtraFusionMaterialEffects,eff)
							end
							extra_maxs[eff]=extra_maxs[eff]-1
							local e1=Effect.CreateEffect(eff:GetOwner())
							e1:SetType(EFFECT_TYPE_FIELD)
							e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
							e1:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
							e1:SetLabelObject(eff)
							e1:SetOperation(eff:GetOperation())
							e1:SetReset(RESET_CHAIN)
							tc:RegisterEffect(e1)
						end
					end
				end
				
				Duel.SetFusionMaterial(sg)
				
				for _,ce in ipairs(aux.UsedExtraFusionMaterialEffects) do
					ce:UseCountLimit(tp)
				end
				
				aux.ValidExtraFusionMaterialEffects={}
				aux.UsedExtraFusionMaterialEffects={}
			end
end


function Auxiliary.FConditionMixRep(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,g,gc,chkfnf)
				if not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
					return _FConditionMixRep(insf,sub,fun1,minc,maxc,table.unpack(funs))(e,g,gc,chkfnf)
				end
				if g==nil then return insf and Auxiliary.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=chkfnf&0x100>0
				local concat_fusion=chkfnf&0x200>0
				local sub2=(sub or notfusion) and not concat_fusion
				local mg=g:Filter(Auxiliary.FConditionFilterMix,c,c,sub2,concat_fusion,fun1,table.unpack(funs))
				local sg=Group.CreateGroup()
				if gc then
					if not mg:IsContains(gc) then return false end
					return Auxiliary.FSelectMixRep(gc,tp,mg,sg,c,sub2,chkfnf,fun1,minc,maxc,table.unpack(funs))
				end
				local eset,extra_maxs={},{}
				local original_mats=mg:Clone()
				local extra_mats=Group.CreateGroup()
				for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
					local res,max=true,999
					local val=ce:GetValue()
					if val then
						res,max=val(ce,c,tp)
					end
					if res then
						local tg=ce:GetTarget()
						local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,nil,ce,tg,tp,c)
						if #exg>0 then
							mg:Merge(exg)
							
							extra_mats:Merge(exg)
							
							for tc in aux.Next(exg) do
								if not eset[tc] then
									eset[tc]={}
								end
								table.insert(eset[tc],ce)
							end
							
							extra_maxs[ce]=max
						end
					end
				end
				
				return mg:IsExists(Auxiliary.FSelectMixRepEx,1,nil,tp,mg,sg,c,sub2,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,0,table.unpack(funs))
			end
end

function Auxiliary.FOperationMixRep(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local c=e:GetHandler()
				local tp=c:GetControler()
				
				if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
					return _FOperationMixRep(insf,sub,fun1,minc,maxc,table.unpack(funs))(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				end
				
				local notfusion=chkfnf&0x100>0
				local concat_fusion=chkfnf&0x200>0
				local sub2=(sub or notfusion) and not concat_fusion
				local mg=eg:Filter(Auxiliary.FConditionFilterMix,c,c,sub2,concat_fusion,fun1,table.unpack(funs))
				local sg=Group.CreateGroup()
				if gc then sg:AddCard(gc) end
				
				local eset,extra_maxs={},{}
				local original_mats=mg:Clone()
				local extra_mats=Group.CreateGroup()
				for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
					local res,max=true,999
					local val=ce:GetValue()
					if val then
						res,max=val(ce,c,tp)
					end
					if res then
						local tg=ce:GetTarget()
						local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,nil,ce,tg,tp,c)
						if #exg>0 then
							mg:Merge(exg)
							
							extra_mats:Merge(exg)
							
							for tc in aux.Next(exg) do
								if not eset[tc] then
									eset[tc]={}
								end
								table.insert(eset[tc],ce)
							end
							
							extra_maxs[ce]=max
						end
					end
				end
				
				aux.ValidExtraFusionMaterialEffects={}
				aux.UsedExtraFusionMaterialEffects={}
				aux.UsedExtraFusionMaterialGroup=Group.CreateGroup()
				
				while sg:GetCount()<maxc+#funs do
					local cg=mg:Filter(Auxiliary.FSelectMixRepEx,sg,tp,mg,sg,c,sub2,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,1,table.unpack(funs))
					if cg:GetCount()==0 then break end
					
					local finish=Auxiliary.FCheckMixRepGoalEx(tp,sg,c,sub2,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,1,table.unpack(funs))
					local cancel_group=sg:Clone()
					if gc then
						cancel_group:RemoveCard(gc)
					end
					
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					local tc=cg:SelectUnselect(cancel_group,tp,finish,false,minc+#funs,maxc+#funs)
					if not tc then break end
					if sg:IsContains(tc) then
						sg:RemoveCard(tc)
						if aux.UsedExtraFusionMaterialGroup:IsContains(tc) then
							aux.UsedExtraFusionMaterialGroup:RemoveCard(tc)
						end
						local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
						if ce then
							local eff=e:GetLabelObject()
							extra_maxs[eff]=extra_maxs[eff]+1
							for pos,elem in ipairs(aux.UsedExtraFusionMaterialEffects) do
								if eff==elem then
									table.remove(aux.UsedExtraFusionMaterialEffects,pos)
									break
								end
							end
							ce:Reset()
						end
					else
						sg:AddCard(tc)
						if extra_mats:IsContains(tc) then
							local available_effs={}
							local extra_descs={}
							local is_original_mat=1
					
							if original_mats:IsContains(tc) then
								local check=true
								if aux.FCheckAdditional then
									extra_mats:RemoveCard(tc)
									check=aux.FCheckAdditional(tp,sg,c,original_mats,extra_mats,eset,extra_maxs,1)
									extra_mats:AddCard(tc)
								end
								if check then
									is_original_mat=0
									table.insert(extra_descs,STRING_DO_NOT_USE_AS_EXTRA_FUSION_MATERIAL)
								end
							end
							
							for _,eff in ipairs(aux.ValidExtraFusionMaterialEffects[tc]) do
								if extra_maxs[eff]>0 then
									table.insert(available_effs,eff)
									table.insert(extra_descs,eff:GetDescription())
								end
							end
							local opt=Duel.SelectOption(tp,table.unpack(extra_descs))+is_original_mat
							
							if opt~=0 then
								local eff=available_effs[opt]
								if aux.GetValueType(eff)=="Effect" then
									if not aux.FindInTable(aux.UsedExtraFusionMaterialEffects,eff) then
										table.insert(aux.UsedExtraFusionMaterialEffects,eff)
									end
									aux.UsedExtraFusionMaterialGroup:AddCard(tc)
									extra_maxs[eff]=extra_maxs[eff]-1
									local e1=Effect.CreateEffect(eff:GetOwner())
									e1:SetType(EFFECT_TYPE_SINGLE)
									e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
									e1:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
									e1:SetLabelObject(eff)
									e1:SetOperation(eff:GetOperation())
									e1:SetReset(RESET_CHAIN)
									tc:RegisterEffect(e1)
								end
							end
						end
					end
				end
				
				Duel.SetFusionMaterial(sg)
				
				for _,ce in ipairs(aux.UsedExtraFusionMaterialEffects) do
					ce:UseCountLimit(tp)
				end
				
				aux.ValidExtraFusionMaterialEffects={}
				aux.UsedExtraFusionMaterialEffects={}
				aux.UsedExtraFusionMaterialGroup:DeleteGroup()
				aux.UsedExtraFusionMaterialGroup=nil
			end
end

function Auxiliary.FSelectMixRepEx(c,tp,mg,sg,fc,sub,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
	--Debug.Message(c:GetCode())
	sg:AddCard(c)
	local res=false
	-- if Auxiliary.FCheckAdditional and not Auxiliary.FCheckAdditional(tp,sg,fc,original_mats,extra_mats,eset,extra_maxs,chk) then
		-- res=false
	-- end
	if Auxiliary.FCheckMixRepGoalEx(tp,sg,fc,sub,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...) then
		res=true
	else
		local g=Group.CreateGroup()
		res=sg:IsExists(Auxiliary.FCheckMixRepSelectedEx,1,nil,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
	end
	
	sg:RemoveCard(c)
	return res
end
function Auxiliary.FCheckMixRepGoalEx(tp,sg,fc,sub,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
	--Debug.Message(0)
	local funs={...}
	local chkf=chkfnf&0xff
	local res1 = (sg:GetCount()<minc+#funs or sg:GetCount()>maxc+#funs)
	-- Debug.Message('sg: '..tostring(#sg))
	-- Debug.Message('min: '..tostring(minc+#funs))
	-- Debug.Message('max: '..tostring(maxc+#funs))
	-- Debug.Message('res1: '..tostring(res1))
	if res1 then return false end
	
	local res2 = not (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0)
	--Debug.Message('res2: '..tostring(res2))
	if res2 then return false end
	
	local res4 = Auxiliary.FGoalCheckGlitchy and not Auxiliary.FGoalCheckGlitchy(tp,sg,fc,sub,chkfnf)
	--Debug.Message('res4: '..tostring(res4))
	if res4 then return false end
	
	local res5 = not Auxiliary.FCheckMixRepGoalCheck(tp,sg,fc,chkfnf)
	--Debug.Message('res5: '..tostring(res5))
	if res5 then return false end
	
	local g=Group.CreateGroup()
	local res6 = Auxiliary.FCheckMixRepEx(tp,sg,g,fc,sub,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
	if not res6 then return false end
	
	local res3 = Auxiliary.FCheckAdditional and not Auxiliary.FCheckAdditional(tp,sg,fc,original_mats,extra_mats,eset,extra_maxs,chk)
	--Debug.Message('res3: '..tostring(res3))
	if res3 then return false end
	
	return true
	--if not aux.NoDebug then Debug.Message('res6: '..tostring(res6)) end
end

function Auxiliary.FCheckMixRepEx(tp,sg,g,fc,sub,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,fun2,...)
	if fun2 then
		return sg:IsExists(Auxiliary.FCheckMixRepFilterEx,1,g,tp,sg,g,fc,sub,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,fun2,...)
	else
		local ct1=sg:FilterCount(fun1,g,fc,sub,nil,sg)
		local ct2=sg:FilterCount(fun1,g,fc,false,nil,sg)
		return ct1==sg:GetCount()-g:GetCount() and ct1-ct2<=1
			and sg:IsExists(Auxiliary.FCheckMixRepFun1,1,g,tp,sg,g,fc,sub,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,ct1)
	end
end

function Auxiliary.FCheckMixRepFilterEx(c,tp,sg,g,fc,sub,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,fun2,...)
	local res=false
	local is_valid_mat=0
	
	if fun2(c,fc,false,nil,sg) then
		g:AddCard(c)
		is_valid_mat=1
		if original_mats:IsContains(c) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c)) then
			res=Auxiliary.FCheckMixRepEx(tp,sg,g,fc,sub,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
		end
	elseif sub and fun2(c,fc,sub,nil,sg) then
		g:AddCard(c)
		is_valid_mat=2
		if original_mats:IsContains(c) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c)) then
			res=Auxiliary.FCheckMixRepEx(tp,sg,g,fc,false,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
		end
	end
		
	if is_valid_mat>0 and type(eset[c])=="table" and (chk==1 or not res) then
		for _,ce in ipairs(eset[c]) do
			local remaining_slots=extra_maxs[ce]
			if remaining_slots>0 then
				local sub2=sub
				if is_valid_mat==2 then
					sub2=false
				end
				extra_maxs[ce]=extra_maxs[ce]-1
				if aux.UsedExtraFusionMaterialGroup then
					aux.UsedExtraFusionMaterialGroup:AddCard(c)
				end
				local res2=Auxiliary.FCheckMixRepEx(tp,sg,g,fc,sub,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
				if aux.UsedExtraFusionMaterialGroup then
					aux.UsedExtraFusionMaterialGroup:RemoveCard(c)
				end
				extra_maxs[ce]=extra_maxs[ce]+1
				if res2 then
					res=true
					if chk==0 then
						break
					else
						if not aux.ValidExtraFusionMaterialEffects[c] then
							aux.ValidExtraFusionMaterialEffects[c]={}
						end
						if not aux.FindInTable(aux.ValidExtraFusionMaterialEffects[c],ce) then
							table.insert(aux.ValidExtraFusionMaterialEffects[c],ce)
						end
					end
				end
			end
		end
	end
	if g:IsContains(c) then
		g:RemoveCard(c)
	end
	
	return res
end

function Auxiliary.FCheckMixRepFun1(c,tp,sg,g,fc,sub,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,ct)
	local res=false
	local is_valid_mat=0
	if fun1(c,fc,false,nil,sg) then
		g:AddCard(c)
		is_valid_mat=1
		if original_mats:IsContains(c) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c)) then
			res=ct==1 or sg:IsExists(Auxiliary.FCheckMixRepFun1,1,g,tp,sg,g,fc,sub,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,ct-1)
		end
	elseif sub and fun1(c,fc,sub,nil,sg) then
		g:AddCard(c)
		is_valid_mat=2
		if original_mats:IsContains(c) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c)) then
			res=ct==1 or sg:IsExists(Auxiliary.FCheckMixRepFun1,1,g,tp,sg,g,fc,false,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,ct-1)
		end
	end
	
	if is_valid_mat>0 and type(eset[c])=="table" and (chk==1 or not res) then
		for _,ce in ipairs(eset[c]) do
			local remaining_slots=extra_maxs[ce]
			if remaining_slots>0 then
				local sub2=sub
				if is_valid_mat==2 then
					sub2=false
				end
				extra_maxs[ce]=extra_maxs[ce]-1
				if aux.UsedExtraFusionMaterialGroup then
					aux.UsedExtraFusionMaterialGroup:AddCard(c)
				end
				local res2=ct==1 or sg:IsExists(Auxiliary.FCheckMixRepFun1,1,g,tp,sg,g,fc,sub2,chkf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,ct-1)
				if aux.UsedExtraFusionMaterialGroup then
					aux.UsedExtraFusionMaterialGroup:RemoveCard(c)
				end
				extra_maxs[ce]=extra_maxs[ce]+1
				if res2 then
					res=true
					if chk==0 then
						break
					else
						if not aux.ValidExtraFusionMaterialEffects[c] then
							aux.ValidExtraFusionMaterialEffects[c]={}
						end
						if not aux.FindInTable(aux.ValidExtraFusionMaterialEffects[c],ce) then
							table.insert(aux.ValidExtraFusionMaterialEffects[c],ce)
						end
					end
				end
			end
		end
	end
	if g:IsContains(c) then
		g:RemoveCard(c)
	end
	
	return res
end

function Auxiliary.FCheckMixRepTemplateEx(c,cond,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
	for i,f in ipairs({...}) do
		local res=false
		local is_valid_mat=0
		
		
		if f(c,fc,false,nil,sg) then
			g:AddCard(c)
			is_valid_mat=1
			if original_mats:IsContains(c) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c)) then
				local t={...}
				table.remove(t,i)
				res=cond(tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,table.unpack(t))
			end
		elseif sub and f(c,fc,sub,nil,sg) then
			g:AddCard(c)
			is_valid_mat=2
			if original_mats:IsContains(c) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c)) then
				local t={...}
				table.remove(t,i)
				res=cond(tp,mg,sg,g,fc,false,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,table.unpack(t))
			end
		end
		
		if is_valid_mat>0 and type(eset[c])=="table" and (chk==1 or not res) then
			for _,ce in ipairs(eset[c]) do
				local remaining_slots=extra_maxs[ce]
				if remaining_slots>0 then
					local sub2=sub
					if is_valid_mat==2 then
						sub2=false
					end
					extra_maxs[ce]=extra_maxs[ce]-1
					local t={...}
					table.remove(t,i)
					if aux.UsedExtraFusionMaterialGroup then
						aux.UsedExtraFusionMaterialGroup:AddCard(c)
					end
					local res2=cond(tp,mg,sg,g,fc,sub2,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,table.unpack(t))
					if aux.UsedExtraFusionMaterialGroup then
						aux.UsedExtraFusionMaterialGroup:RemoveCard(c)
					end
					extra_maxs[ce]=extra_maxs[ce]+1
					if res2 then
						res=true
						if chk==0 then
							break
						else
							if not aux.ValidExtraFusionMaterialEffects[c] then
								aux.ValidExtraFusionMaterialEffects[c]={}
							end
							if not aux.FindInTable(aux.ValidExtraFusionMaterialEffects[c],ce) then
								table.insert(aux.ValidExtraFusionMaterialEffects[c],ce)
							end
						end
					end
				end
			end
		end
		if g:IsContains(c) then
			g:RemoveCard(c)
		end
		-- if res then
			-- Debug.Message("EXTRA CHECK = "..tostring(res))
		-- end
		if res then
			return true
		end
	end
	
	if maxc>0 then
		local res=false
		local is_valid_mat=0
		
		if fun1(c,fc,false,nil,sg) then
			g:AddCard(c)
			is_valid_mat=1
			if original_mats:IsContains(c) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c))  then
				res=cond(tp,mg,sg,g,fc,sub,chkfnf,fun1,minc-1,maxc-1,original_mats,extra_mats,eset,extra_maxs,chk,...)
			end
		elseif sub and fun1(c,fc,sub,nil,sg) then
			g:AddCard(c)
			is_valid_mat=2
			if original_mats:IsContains(c) then
				res=cond(tp,mg,sg,g,fc,false,chkfnf,fun1,minc-1,maxc-1,original_mats,extra_mats,eset,extra_maxs,chk,...)
			end
		end
		
		if is_valid_mat>0 and type(eset[c])=="table" and (chk==1 or not res) then
			for _,ce in ipairs(eset[c]) do
				local remaining_slots=extra_maxs[ce]
				if remaining_slots>0 then
					local sub2=sub
					if is_valid_mat==2 then
						sub2=false
					end
					extra_maxs[ce]=extra_maxs[ce]-1
					if aux.UsedExtraFusionMaterialGroup then
						aux.UsedExtraFusionMaterialGroup:AddCard(c)
					end
					local res2=cond(tp,mg,sg,g,fc,sub2,chkfnf,fun1,minc-1,maxc-1,original_mats,extra_mats,eset,extra_maxs,chk,...)
					if aux.UsedExtraFusionMaterialGroup then
						aux.UsedExtraFusionMaterialGroup:RemoveCard(c)
					end
					extra_maxs[ce]=extra_maxs[ce]+1
					if res2 then
						res=true
						if chk==0 then
							break
						else
							if not aux.ValidExtraFusionMaterialEffects[c] then
								aux.ValidExtraFusionMaterialEffects[c]={}
							end
							if not aux.FindInTable(aux.ValidExtraFusionMaterialEffects[c],ce) then
								table.insert(aux.ValidExtraFusionMaterialEffects[c],ce)
							end
						end
					end
				end
			end
		end
		if g:IsContains(c) then
			g:RemoveCard(c)
		end
		-- if res then
			-- Debug.Message("EXTRA CHECK = "..tostring(res))
		-- end
		if res then
			return true
		end
	end
	return false
end
function Auxiliary.FCheckMixRepSelectedCondEx(tp,mg,sg,g,...)
	if #g<#sg then
		return sg:IsExists(Auxiliary.FCheckMixRepSelectedEx,1,g,tp,mg,sg,g,...)
	else
		return Auxiliary.FCheckSelectMixRepEx(tp,mg,sg,g,...)
	end
end
function Auxiliary.FCheckMixRepSelectedEx(c,...)
	return Auxiliary.FCheckMixRepTemplateEx(c,Auxiliary.FCheckMixRepSelectedCondEx,...)
end
function Auxiliary.FCheckSelectMixRepEx(tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
	local chkf=chkfnf&0xff
	if Auxiliary.FCheckAdditional and not Auxiliary.FCheckAdditional(tp,g,fc,original_mats,extra_mats,eset,extra_maxs,chk) then return false end
	if chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,g,fc)>0 then
		if minc<=0 and #{...}==0 and Auxiliary.FCheckMixRepGoalCheck(tp,g,fc,chkfnf) then return true end
		return mg:IsExists(Auxiliary.FCheckSelectMixRepAllEx,1,g,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
	else
		return mg:IsExists(Auxiliary.FCheckSelectMixRepMEx,1,g,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
	end
end
function Auxiliary.FCheckSelectMixRepAllEx(c,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
	if fun2 then
		local res=false
		local is_valid_mat=0
		
		if fun2(c,fc,false,mg,sg) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c)) then
			g:AddCard(c)
			is_valid_mat=1
			if original_mats:IsContains(c) then
				res=Auxiliary.FCheckSelectMixRepEx(tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
			end
		elseif sub and fun2(c,fc,sub,mg,sg) then
			g:AddCard(c)
			is_valid_mat=2
			if original_mats:IsContains(c) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c)) then
				res=Auxiliary.FCheckSelectMixRepEx(tp,mg,sg,g,fc,false,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
			end
		end
		
		if is_valid_mat>0 and type(eset[c])=="table" and (chk==1 or not res) then
			for _,ce in ipairs(eset[c]) do
				local remaining_slots=extra_maxs[ce]
				if remaining_slots>0 then
					local sub2=sub
					if is_valid_mat==2 then
						sub2=false
					end
					extra_maxs[ce]=extra_maxs[ce]-1
					if aux.UsedExtraFusionMaterialGroup then
						aux.UsedExtraFusionMaterialGroup:AddCard(c)
					end
					local res2=Auxiliary.FCheckSelectMixRepEx(tp,mg,sg,g,fc,sub2,chkfnf,fun1,minc,maxc,original_mats,extra_mats,eset,extra_maxs,chk,...)
					if aux.UsedExtraFusionMaterialGroup then
						aux.UsedExtraFusionMaterialGroup:RemoveCard(c)
					end
					extra_maxs[ce]=extra_maxs[ce]+1
					if res2 then
						res=true
						if chk==0 then
							break
						else
							if not aux.ValidExtraFusionMaterialEffects[c] then
								aux.ValidExtraFusionMaterialEffects[c]={}
							end
							if not aux.FindInTable(aux.ValidExtraFusionMaterialEffects[c],ce) then
								table.insert(aux.ValidExtraFusionMaterialEffects[c],ce)
							end
						end
					end
				end
			end
		end
		if g:IsContains(c) then
			g:RemoveCard(c)
		end
		return res
		
	elseif maxc>0 then
		local res=false
		local is_valid_mat=0
		
		if fun1(c,fc,false,mg,sg) then
			g:AddCard(c)
			is_valid_mat=1
			if original_mats:IsContains(c) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c)) then
				res=Auxiliary.FCheckSelectMixRepEx(tp,mg,sg,g,fc,sub,chkfnf,fun1,minc-1,maxc-1,original_mats,extra_mats,eset,extra_maxs,chk)
			end
		elseif sub and fun1(c,fc,sub,mg,sg) then
			g:AddCard(c)
			is_valid_mat=2
			if original_mats:IsContains(c) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c)) then
				res=Auxiliary.FCheckSelectMixRepEx(tp,mg,sg,g,fc,false,chkfnf,fun1,minc-1,maxc-1,original_mats,extra_mats,eset,extra_maxs,chk)
			end
		end
		
		if is_valid_mat>0 and type(eset[c])=="table" and (chk==1 or not res) then
			for _,ce in ipairs(eset[c]) do
				local remaining_slots=extra_maxs[ce]
				if remaining_slots>0 then
					local sub2=sub
					if is_valid_mat==2 then
						sub2=false
					end
					extra_maxs[ce]=extra_maxs[ce]-1
					if aux.UsedExtraFusionMaterialGroup then
						aux.UsedExtraFusionMaterialGroup:AddCard(c)
					end
					local res2=Auxiliary.FCheckSelectMixRepEx(tp,mg,sg,g,fc,sub2,chkfnf,fun1,minc-1,maxc-1,original_mats,extra_mats,eset,extra_maxs,chk)
					if aux.UsedExtraFusionMaterialGroup then
						aux.UsedExtraFusionMaterialGroup:RemoveCard(c)
					end
					extra_maxs[ce]=extra_maxs[ce]+1
					if res2 then
						res=true
						if chk==0 then
							break
						else
							if not aux.ValidExtraFusionMaterialEffects[c] then
								aux.ValidExtraFusionMaterialEffects[c]={}
							end
							if not aux.FindInTable(aux.ValidExtraFusionMaterialEffects[c],ce) then
								table.insert(aux.ValidExtraFusionMaterialEffects[c],ce)
							end
						end
					end
				end
			end
		end
		if g:IsContains(c) then
			g:RemoveCard(c)
		end
		return res
		
	end
	return false
end
function Auxiliary.FCheckSelectMixRepMEx(c,tp,...)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and Auxiliary.FCheckMixRepTemplate(c,Auxiliary.FCheckSelectMixRepEx,tp,...)
end

--Shaddoll Special Fusion Procedures
local _FShaddollCondition, _FShaddollOperation = Auxiliary.FShaddollCondition, Auxiliary.FShaddollOperation

function Auxiliary.FShaddollSpFilter1Ex(c,fc,tp,mg,exg,attr,chkf,original_mats,extra_mats,eset,extra_maxs,chk)
	return mg:IsExists(Auxiliary.FShaddollSpFilter2Ex,1,c,fc,tp,c,attr,chkf,original_mats,extra_mats,eset,extra_maxs,chk)
		or (exg and exg:IsExists(Auxiliary.FShaddollSpFilter2,1,c,fc,tp,c,attr,chkf))
end
function Auxiliary.FShaddollSpFilter2Ex(c,fc,tp,mc,attr,chkf,original_mats,extra_mats,eset,extra_maxs,chk)
	local sg=Group.FromCards(c,mc)
	if sg:IsExists(Auxiliary.TuneMagicianCheckX,1,nil,sg,EFFECT_TUNE_MAGICIAN_F) then return false end
	
	if not Auxiliary.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	
	if not (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0) then return false end
	
	local res=sg:IsExists(aux.FShaddollGoalEx,1,nil,attr,tp,sg,Group.CreateGroup(),fc,original_mats,extra_mats,eset,extra_maxs,chk,2,0,0)
	if not res then return false end
	
	if Auxiliary.FCheckAdditional and not Auxiliary.FCheckAdditional(tp,sg,fc,original_mats,extra_mats,eset,extra_maxs,chk)
		or Auxiliary.FGoalCheckAdditional and not Auxiliary.FGoalCheckAdditional(tp,sg,fc,original_mats,extra_mats,eset,extra_maxs,chk) then return false end
	
	return true
end
function Auxiliary.FShaddollGoalEx(c,attr,tp,sg,g,fc,original_mats,extra_mats,eset,extra_maxs,chk,ct,s1,s2)
	local res=false
	local is_valid_mat=0
	
	g:AddCard(c)

	if type(s1)=="number" then
		s1=Auxiliary.FShaddollFilter1(c)
	end
	if type(s2)=="number" then
		s2=Auxiliary.FShaddollFilter2(c,attr)
	end

	if s1 or s2 then
		is_valid_mat=1
		if original_mats:IsContains(c) or (aux.UsedExtraFusionMaterialGroup and aux.UsedExtraFusionMaterialGroup:IsContains(c)) then
			res=ct==1 or (s1 and sg:IsExists(aux.FShaddollGoalEx,1,g,attr,tp,sg,g,fc,original_mats,extra_mats,eset,extra_maxs,chk,ct-1,false,0))
				or (s2 and sg:IsExists(aux.FShaddollGoalEx,1,g,attr,tp,sg,g,fc,original_mats,extra_mats,eset,extra_maxs,chk,ct-1,0,false))
		end
	end

	if is_valid_mat>0 and type(eset[c])=="table" and (chk==1 or not res) then
		for _,ce in ipairs(eset[c]) do
			local remaining_slots=extra_maxs[ce]
			if remaining_slots>0 then
				extra_maxs[ce]=extra_maxs[ce]-1
				
				if aux.UsedExtraFusionMaterialGroup then
					aux.UsedExtraFusionMaterialGroup:AddCard(c)
				end
				
				local res2=ct==1 or (s1 and sg:IsExists(aux.FShaddollGoalEx,1,g,attr,tp,sg,g,fc,original_mats,extra_mats,eset,extra_maxs,chk,ct-1,false,0))
					or (s2 and sg:IsExists(aux.FShaddollGoalEx,1,g,attr,tp,sg,g,fc,original_mats,extra_mats,eset,extra_maxs,chk,ct-1,0,false))
					
				if aux.UsedExtraFusionMaterialGroup then
					aux.UsedExtraFusionMaterialGroup:RemoveCard(c)
				end
				extra_maxs[ce]=extra_maxs[ce]+1
				if res2 then
					res=true
					if chk==0 then
						break
					else
						if not aux.ValidExtraFusionMaterialEffects[c] then
							aux.ValidExtraFusionMaterialEffects[c]={}
						end
						if not aux.FindInTable(aux.ValidExtraFusionMaterialEffects[c],ce) then
							table.insert(aux.ValidExtraFusionMaterialEffects[c],ce)
						end
					end
				end
			end
		end
	end
	g:RemoveCard(c)
	return res
end
function Auxiliary.FShaddollCondition(attr)
	return 	function(e,g,gc,chkf)
				if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
					return _FShaddollCondition(attr)(e,g,gc,chkf)
				end
				if g==nil then return Auxiliary.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
				local c=e:GetHandler()
				local mg=g:Filter(Auxiliary.FShaddollFilter,nil,c,attr)
				local tp=e:GetHandlerPlayer()
				local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
				local exg=nil
				if fc and fc:IsHasEffect(81788994) and fc:IsCanRemoveCounter(tp,0x16,3,REASON_EFFECT) then
					local fe=fc:IsHasEffect(81788994)
					exg=Duel.GetMatchingGroup(Auxiliary.FShaddollExFilter,tp,0,LOCATION_MZONE,mg,c,attr,fe)
				end
				if gc then
					if not mg:IsContains(gc) then return false end
					return Auxiliary.FShaddollSpFilter1(gc,c,tp,mg,exg,attr,chkf)
				end
				
				local eset,extra_maxs={},{}
				local original_mats=mg:Clone()
				local extra_mats=Group.CreateGroup()
				for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
					local res,max=true,999
					local val=ce:GetValue()
					if val then
						res,max=val(ce,c,tp)
					end
					if res then
						local tg=ce:GetTarget()
						local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,nil,ce,tg,tp,c)
						if #exg>0 then
							mg:Merge(exg)
							
							extra_mats:Merge(exg)
							
							for tc in aux.Next(exg) do
								if not eset[tc] then
									eset[tc]={}
								end
								table.insert(eset[tc],ce)
							end
							
							extra_maxs[ce]=max
						end
					end
				end
				
				return mg:IsExists(Auxiliary.FShaddollSpFilter1Ex,1,nil,c,tp,mg,exg,attr,chkf,original_mats,extra_mats,eset,extra_maxs,0)
				
			end
end
function Auxiliary.FShaddollOperation(attr)
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
				if not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
					return _FShaddollOperation(attr)(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
				end
				local c=e:GetHandler()
				local mg=eg:Filter(Auxiliary.FShaddollFilter,nil,c,attr)
				local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
				local exg=nil
				if fc and fc:IsHasEffect(81788994) and fc:IsCanRemoveCounter(tp,0x16,3,REASON_EFFECT) then
					local fe=fc:IsHasEffect(81788994)
					exg=Duel.GetMatchingGroup(Auxiliary.FShaddollExFilter,tp,0,LOCATION_MZONE,mg,c,attr,fe)
				end
				
				local eset,extra_maxs={},{}
				local original_mats=mg:Clone()
				local extra_mats=Group.CreateGroup()
				for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
					local res,max=true,999
					local val=ce:GetValue()
					if val then
						res,max=val(ce,c,tp)
					end
					if res then
						local tg=ce:GetTarget()
						local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,nil,ce,tg,tp,c)
						if #exg>0 then
							mg:Merge(exg)
							
							extra_mats:Merge(exg)
							
							for tc in aux.Next(exg) do
								if not eset[tc] then
									eset[tc]={}
								end
								table.insert(eset[tc],ce)
							end
							
							extra_maxs[ce]=max
						end
					end
				end
				
				aux.ValidExtraFusionMaterialEffects={}
				aux.UsedExtraFusionMaterialEffects={}
				aux.UsedExtraFusionMaterialGroup=Group.CreateGroup()

				local g=nil
				if gc then
					g=Group.FromCards(gc)
					mg:RemoveCard(gc)
				else
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					g=mg:FilterSelect(tp,Auxiliary.FShaddollSpFilter1Ex,1,1,nil,c,tp,mg,exg,attr,chkf,original_mats,extra_mats,eset,extra_maxs,1)
					local tc=g:GetFirst()
					if extra_mats:IsContains(tc) then
						local available_effs={}
						local extra_descs={}
						local is_original_mat=1
				
						if original_mats:IsContains(tc) then
							local check=true
							if aux.FCheckAdditional then
								extra_mats:RemoveCard(tc)
								check=aux.FCheckAdditional(tp,sg,c,original_mats,extra_mats,eset,extra_maxs,1)
								extra_mats:AddCard(tc)
							end
							if check then
								is_original_mat=0
								table.insert(extra_descs,STRING_DO_NOT_USE_AS_EXTRA_FUSION_MATERIAL)
							end
						end
						
						for _,eff in ipairs(aux.ValidExtraFusionMaterialEffects[tc]) do
							if extra_maxs[eff]>0 then
								table.insert(available_effs,eff)
								table.insert(extra_descs,eff:GetDescription())
							end
						end
						local opt=Duel.SelectOption(tp,table.unpack(extra_descs))+is_original_mat
						
						if opt~=0 then
							local eff=available_effs[opt]
							if aux.GetValueType(eff)=="Effect" then
								if not aux.FindInTable(aux.UsedExtraFusionMaterialEffects,eff) then
									table.insert(aux.UsedExtraFusionMaterialEffects,eff)
								end
								aux.UsedExtraFusionMaterialGroup:AddCard(tc)
								extra_maxs[eff]=extra_maxs[eff]-1
								local e1=Effect.CreateEffect(eff:GetOwner())
								e1:SetType(EFFECT_TYPE_SINGLE)
								e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
								e1:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
								e1:SetLabelObject(eff)
								e1:SetOperation(eff:GetOperation())
								e1:SetReset(RESET_CHAIN)
								tc:RegisterEffect(e1)
							end
						end
					end
					mg:Sub(g)
				end
				if exg and exg:IsExists(Auxiliary.FShaddollSpFilter2,1,nil,c,tp,g:GetFirst(),attr,chkf)
					and (mg:GetCount()==0 or (exg:GetCount()>0 and Duel.SelectYesNo(tp,Auxiliary.Stringid(81788994,0)))) then
					fc:RemoveCounter(tp,0x16,3,REASON_EFFECT)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					local sg=exg:FilterSelect(tp,Auxiliary.FShaddollSpFilter2,1,1,nil,c,tp,g:GetFirst(),attr,chkf)
					g:Merge(sg)
				else
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					local sg=mg:FilterSelect(tp,Auxiliary.FShaddollSpFilter2Ex,1,1,nil,c,tp,g:GetFirst(),attr,chkf,original_mats,extra_mats,eset,extra_maxs,1)
					local tc=sg:GetFirst()
					if extra_mats:IsContains(tc) then
						local available_effs={}
						local extra_descs={}
						local is_original_mat=1
				
						if original_mats:IsContains(tc) then
							local check=true
							if aux.FCheckAdditional then
								extra_mats:RemoveCard(tc)
								check=aux.FCheckAdditional(tp,sg,c,original_mats,extra_mats,eset,extra_maxs,1)
								extra_mats:AddCard(tc)
							end
							if check then
								is_original_mat=0
								table.insert(extra_descs,STRING_DO_NOT_USE_AS_EXTRA_FUSION_MATERIAL)
							end
						end
						
						for _,eff in ipairs(aux.ValidExtraFusionMaterialEffects[tc]) do
							if extra_maxs[eff]>0 then
								table.insert(available_effs,eff)
								table.insert(extra_descs,eff:GetDescription())
							end
						end
						local opt=Duel.SelectOption(tp,table.unpack(extra_descs))+is_original_mat
						
						if opt~=0 then
							local eff=available_effs[opt]
							if aux.GetValueType(eff)=="Effect" then
								if not aux.FindInTable(aux.UsedExtraFusionMaterialEffects,eff) then
									table.insert(aux.UsedExtraFusionMaterialEffects,eff)
								end
								aux.UsedExtraFusionMaterialGroup:AddCard(tc)
								extra_maxs[eff]=extra_maxs[eff]-1
								local e1=Effect.CreateEffect(eff:GetOwner())
								e1:SetType(EFFECT_TYPE_SINGLE)
								e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
								e1:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
								e1:SetLabelObject(eff)
								e1:SetOperation(eff:GetOperation())
								e1:SetReset(RESET_CHAIN)
								tc:RegisterEffect(e1)
							end
						end
					end
					g:Merge(sg)
				end
				Duel.SetFusionMaterial(g)
				
				for _,ce in ipairs(aux.UsedExtraFusionMaterialEffects) do
					ce:UseCountLimit(tp)
				end
				
				aux.ValidExtraFusionMaterialEffects={}
				aux.UsedExtraFusionMaterialEffects={}
				aux.UsedExtraFusionMaterialGroup:DeleteGroup()
				aux.UsedExtraFusionMaterialGroup=nil
			end
end

--Modified operation functions for using Fusion Materials
Auxiliary.PerformingFusionMaterialOperation=false
Duel.SendtoGrave = function(tg,reason,...)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.PerformingFusionMaterialOperation or aux.GetValueType(tg)~="Group" then
		return _SendtoGrave(tg,reason,...)
	end
	local rg=tg:Filter(Card.IsHasEffect,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	tg:Sub(rg)
	local opt=0
	
	local ct1=_SendtoGrave(tg,reason,...)
	local ct2=0
	
	while #rg>0 do
		local extra_g=Group.CreateGroup()
		local check_eff=nil
		local extra_op=nil
		
		for tc in aux.Next(rg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			local eff=ce:GetLabelObject()
			if not check_eff then
				check_eff=eff
				extra_op=ce:GetOperation()
			end
			if eff==check_eff then
				extra_g:AddCard(tc)
			end
		end
		if #extra_g>0 then
			rg:Sub(extra_g)
			if not extra_op then extra_op=_SendtoGrave end
			Duel.Hint(HINT_CARD,0,check_eff:GetOwner():GetOriginalCode())
			aux.PerformingFusionMaterialOperation=true
			local extra_ct=extra_op(extra_g,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			aux.PerformingFusionMaterialOperation=false
			ct2=ct2+extra_ct
		end
	end
	
	return ct1+ct2
end
Duel.Remove = function(tg,pos,reason,...)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.PerformingFusionMaterialOperation or aux.GetValueType(tg)~="Group" then
		return _Remove(tg,pos,reason,...)
	end
	local rg=tg:Filter(Card.IsHasEffect,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	tg:Sub(rg)
	local opt=0
	local ct1=_Remove(tg,pos,reason,...)
	local ct2=0
	
	while #rg>0 do
		local extra_g=Group.CreateGroup()
		local check_eff=nil
		local extra_op=nil
		
		for tc in aux.Next(rg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			local eff=ce:GetLabelObject()
			if not check_eff then
				check_eff=eff
				extra_op=ce:GetOperation()
			end
			if eff==check_eff then
				extra_g:AddCard(tc)
			end
		end
		if #extra_g>0 then
			rg:Sub(extra_g)
			if not extra_op then extra_op=_Remove end
			Duel.Hint(HINT_CARD,0,check_eff:GetOwner():GetOriginalCode())
			aux.PerformingFusionMaterialOperation=true
			local extra_ct=extra_op(extra_g,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			aux.PerformingFusionMaterialOperation=false
			ct2=ct2+extra_ct
		end
	end
	
	return ct1+ct2
end
Duel.SendtoDeck = function(tg,p,seq,reason,...)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.PerformingFusionMaterialOperation or aux.GetValueType(tg)~="Group" then
		return _SendtoDeck(tg,p,seq,reason,...)
	end
	local rg=tg:Filter(Card.IsHasEffect,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	tg:Sub(rg)
	local opt=0
	local ct1=_SendtoDeck(tg,p,seq,reason,...)
	local ct2=0

	while #rg>0 do
		local extra_g=Group.CreateGroup()
		local check_eff=nil
		local extra_op=nil
		
		for tc in aux.Next(rg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			local eff=ce:GetLabelObject()
			if not check_eff then
				check_eff=eff
				extra_op=ce:GetOperation()
			end
			if eff==check_eff then
				extra_g:AddCard(tc)
			end
		end
		if #extra_g>0 then
			rg:Sub(extra_g)
			if not extra_op then extra_op=_Remove end
			Duel.Hint(HINT_CARD,0,check_eff:GetOwner():GetOriginalCode())
			aux.PerformingFusionMaterialOperation=true
			local extra_ct=extra_op(extra_g,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			aux.PerformingFusionMaterialOperation=false
			ct2=ct2+extra_ct
		end
	end
	return ct1+ct2
end
Duel.Destroy = function(tg,reason,...)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.PerformingFusionMaterialOperation or aux.GetValueType(tg)~="Group" then
		return _Destroy(tg,reason,...)
	end
	local rg=tg:Filter(Card.IsHasEffect,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	tg:Sub(rg)

	local ct1=_Destroy(tg,reason,...)
	local ct2=0
	
	while #rg>0 do
		local extra_g=Group.CreateGroup()
		local check_eff=nil
		local extra_op=nil
		
		for tc in aux.Next(rg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			local eff=ce:GetLabelObject()
			if not check_eff then
				check_eff=eff
				extra_op=ce:GetOperation()
			end
			if eff==check_eff then
				extra_g:AddCard(tc)
			end
		end
		if #extra_g>0 then
			rg:Sub(extra_g)
			if not extra_op then extra_op=_Remove end
			Duel.Hint(HINT_CARD,0,check_eff:GetOwner():GetOriginalCode())
			aux.PerformingFusionMaterialOperation=true
			local extra_ct=extra_op(extra_g,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			aux.PerformingFusionMaterialOperation=false
			ct2=ct2+extra_ct
		end
	end
	return ct1+ct2
end
Duel.SendtoHand = function(tg,p,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.PerformingFusionMaterialOperation or aux.GetValueType(tg)~="Group" then
		return _SendtoHand(tg,p,reason)
	end
	local rg=tg:Filter(Card.IsHasEffect,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	tg:Sub(rg)
	
	local ct1=_SendtoHand(tg,p,reason)
	local ct2=0
	
	while #rg>0 do
		local extra_g=Group.CreateGroup()
		local check_eff=nil
		local extra_op=nil
		
		for tc in aux.Next(rg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			local eff=ce:GetLabelObject()
			if not check_eff then
				check_eff=eff
				extra_op=ce:GetOperation()
			end
			if eff==check_eff then
				extra_g:AddCard(tc)
			end
		end
		if #extra_g>0 then
			rg:Sub(extra_g)
			if not extra_op then extra_op=_Remove end
			Duel.Hint(HINT_CARD,0,check_eff:GetOwner():GetOriginalCode())
			aux.PerformingFusionMaterialOperation=true
			local extra_ct=extra_op(extra_g,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			aux.PerformingFusionMaterialOperation=false
			ct2=ct2+extra_ct
		end
	end
	
	return ct1+ct2
end