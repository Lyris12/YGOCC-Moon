--New EFFECTS
EFFECT_CANNOT_ACTIVATE_LMARKER=8000
EFFECT_CANNOT_DEACTIVATE_LMARKER=8001
EFFECT_PRE_LOCATION=8002
EFFECT_NO_ARCHETYPE=8003
EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL 	= 8004
EFFECT_GLITCHY_EXTRA_LINK_MATERIAL	    = 8005
EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG		= 8006
EFFECT_GLITCHY_HACK_CODE 				= 8007
EFFECT_NAME_DECLARED					= 8008
EFFECT_GLITCHY_CANNOT_DISABLE			= 8009
EFFECT_GLITCHY_FUSION_SUBSTITUTE 		= 8010
EFFECT_GLITCHY_CANNOT_CHANGE_ATK		= 8011

FLAG_UNCOUNTED_NORMAL_SUMMON			= 8000
FLAG_UNCOUNTED_NORMAL_SET				= 8001

EFFECT_BECOME_HOPT=99977755
EFFECT_SYNCHRO_MATERIAL_EXTRA=26134837
EFFECT_SYNCHRO_MATERIAL_MULTIPLE=26134838
EFFECT_REVERSE_WHEN_IF=48928491


---------------------------------------------------------------------------------
-------------------------------NORMAL SUMMON/SET---------------------------------
local _Summon, _MSet = Duel.Summon, Duel.MSet

Duel.Summon = function(tp,c,ign,e,mint,zone)
	if not mint then mint=0 end
	if not zone then zone=0x1f end
	if ign then
		c:RegisterFlagEffect(FLAG_UNCOUNTED_NORMAL_SUMMON,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
	return _Summon(tp,c,ign,e,mint,zone)
end
Duel.MSet = function(tp,c,ign,e,mint,zone)
	if not mint then mint=0 end
	if not zone then zone=0x1f end
	if ign then
		c:RegisterFlagEffect(FLAG_UNCOUNTED_NORMAL_SET,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_SET_AVAILABLE,1)
	end
	return _MSet(tp,c,ign,e,mint,zone)
end

-----------------------------------------------------------------------
-------------------------------NEGATES---------------------------------
local _IsChainDisablable, _NegateEffect = Duel.IsChainDisablable, Duel.NegateEffect

Duel.IsChainDisablable = function(ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	if te and aux.GetValueType(te:GetHandler())=="Card" and te:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE) then
		local egroup={te:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE)}
		for _,ce in ipairs(egroup) do
			if ce and ce.GetLabel then
				local val=ce:GetValue()
				if not val or type(val)=="number" or val(ce,self_reference_effect) then
					return false
				end
			end
		end
	end
	return _IsChainDisablable(ct)
end
Duel.NegateEffect = function(ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	if te and aux.GetValueType(te:GetHandler())=="Card" and te:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE) then
		local egroup={te:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE)}
		for _,ce in ipairs(egroup) do
			if ce and ce.GetLabel then
				local val=ce:GetValue()
				if not val or type(val)=="number" or val(ce,self_reference_effect) then
					return false
				end
			end
		end
	end
	return _NegateEffect(ct)
end

function Auxiliary.GlitchyCannotDisableCon(f)
	return	function(e)
				local egroup={e:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE)}
				for _,ce in ipairs(egroup) do
					if ce and ce.GetLabel then
						local val=ce:GetValue()
						if not val or type(val)=="number" or val(ce,e) then
							return false
						end
					end
				end
				return not f or f(e)
			end
end
function Auxiliary.GlitchyCannotDisable(f)
	return	function(e,c)
				local egroup={c:IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE)}
				for _,ce in ipairs(egroup) do	
					if ce and ce.GetLabel then
						local val=ce:GetValue()
						if not val or type(val)=="number" or val(ce,e) then
							return false
						end
					end
				end
				return not f or f(e,c)
			end
end

-----------------------------------------------------------------------
-------------------------------TRIBUTE-------------------------------
local _Release = Duel.Release

Duel.Release = function(g,r)
	if aux.GetValueType(g)=="Card" then
		g=Group.FromCards(g)
	end
	local ct1,ct2=0,0
	local gx=g:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	g:Sub(gx)
	if #g>0 then
		ct1=_Release(g,r)
	end
	if #gx>0 then
		ct2=Duel.SendtoGrave(gx,r|REASON_RELEASE)
	end
	return ct1+ct2
end

--Modified Functions: Names
local _IsCode, _IsFusionCode, _IsLinkCode, _IsOriginalCodeRule =
Card.IsCode, Card.IsFusionCode, Card.IsLinkCode, Card.IsOriginalCodeRule

Card.IsCode = function(c,code,...)
	local x={...}
	if c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE) then
		local hacked_codes={}
		for _,e in ipairs({c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE)}) do
			local val=e:GetValue()
			local re=e:GetLabelObject()
			if val and (not re or re and self_reference_effect and self_reference_effect==re) then
				table.insert(hacked_codes,val)
			end
		end
		return _IsCode(c,table.unpack(hacked_codes))
	else
		return _IsCode(c,code,...)
	end
end
Card.IsFusionCode = function(c,code,...)
	local x={...}
	if c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE) then
		local hacked_codes={}
		for _,e in ipairs({c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE)}) do
			local val=e:GetValue()
			local re=e:GetLabelObject()
			if val and (not re or re and self_reference_effect and self_reference_effect==re) then
				table.insert(hacked_codes,val)
			end
		end
		return _IsFusionCode(c,table.unpack(hacked_codes))
	else
		return _IsFusionCode(c,code,...)
	end
end
Card.IsLinkCode = function(c,code,...)
	local x={...}
	if c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE) then
		local hacked_codes={}
		for _,e in ipairs({c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE)}) do
			local val=e:GetValue()
			local re=e:GetLabelObject()
			if val and (not re or re and self_reference_effect and self_reference_effect==re) then
				table.insert(hacked_codes,val)
			end
		end
		return _IsLinkCode(c,table.unpack(hacked_codes))
	else
		return _IsLinkCode(c,code,...)
	end
end
Card.IsOriginalCodeRule = function(c,code,...)
	local x={...}
	if c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE) then
		local hacked_codes={}
		for _,e in ipairs({c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE)}) do
			local val=e:GetValue()
			local re=e:GetLabelObject()
			if val and (not re or re and self_reference_effect and self_reference_effect==re) then
				table.insert(hacked_codes,val)
			end
		end
		return _IsOriginalCodeRule(c,table.unpack(hacked_codes))
	else
		return _IsOriginalCodeRule(c,code,...)
	end
end

--Modified Functions: ANNOUNCES
local _AnnounceCard =
Duel.AnnounceCard

Duel.AnnounceCard = function(p,...)
	local ac=_AnnounceCard(p,...)
	local e=self_reference_effect
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_NAME_DECLARED)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,ac))
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetValue(ac)
	Duel.RegisterEffect(e1,p)
	return ac
end

--Modified Functions: FUSIONS
function Auxiliary.PureExtraFilter(c)
	return c:GetFlagEffect(1005)>0
end
function Auxiliary.PureExtraFilterLoop(c,eff)
	return c:GetFlagEffect(1005)>0 and not c:IsHasEffect(eff)
end
function Auxiliary.ExtraFusionFilter0(c,ce,tg)
	return c:IsCanBeFusionMaterial() and tg(ce,c)
end
function Auxiliary.ExtraFusionFilter(c,e,ce,tg)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e) and tg(ce,c)
end
function Auxiliary.ExtraMaterialFilterSelect(c,e,f)
	return c:GetFlagEffect(1006)>0 and f(e,c)
end
function Auxiliary.ExtraMaterialFilterGoal(mg,og)
	local og=og:Clone()
	local res = (not og:IsExists(aux.TRUE,1,mg) or not og:IsExists(aux.PureExtraFilter,1,mg))
	og:DeleteGroup()
	return res
end
function Auxiliary.ExtraMaterialMaxCheck(c,id)
	if not c:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG) then return false end
	local res=false
	for _,flag in ipairs({c:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
		if flag and flag.GetLabel then
			if flag:GetValue()==id then
				res=true
			else
				return false
			end
		end
	end
	return res
end

local _GetFusionMaterial, _CheckFusionMaterial, _SelectFusionMaterial, _FConditionFilterMix, _FCheckMixGoal, _AddFusionProcMix, _AddFusionProcMixRep, _SendtoGrave, _Remove, _SendtoDeck, _Destroy, _SendtoHand =
Duel.GetFusionMaterial, Card.CheckFusionMaterial, Duel.SelectFusionMaterial, Auxiliary.FConditionFilterMix, Auxiliary.FCheckMixGoal, Auxiliary.AddFusionProcMix, Auxiliary.AddFusionProcMixRep, Duel.SendtoGrave, Duel.Remove, Duel.SendtoDeck, Duel.Destroy, Duel.SendtoHand

Duel.GetFusionMaterial = function(tp,...)
	local x={...}
	local loc = #x>0 and x[1] or LOCATION_MZONE+LOCATION_HAND
	local res,base=_GetFusionMaterial(tp,...)
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
		local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}
		local ogres=res:Clone()
		for _,ce in ipairs(egroup) do
			if ce and ce.GetLabel then
				local mats=Duel.GetMatchingGroup(aux.ExtraFusionFilter0,tp,0xff,0xff,nil,ce,ce:GetTarget())
				if #mats>0 then
					for tc in aux.Next(mats) do
						if tc:GetFlagEffect(1005)>0 then
							tc:ResetFlagEffect(1005)
						end
						if not ogres:IsContains(tc) then
							tc:RegisterFlagEffect(1005,RESET_CHAIN,0,1)
						end
					end
					res:Merge(mats)
				end
			end
		end
	end
	return res,base
end

Card.CheckFusionMaterial = function(c,...)
	local x={...}
	local matg = #x>0 and x[1] or nil
	local cg = #x>1 and x[2] or nil
	local chkf = #x>2 and x[3] or PLAYER_NONE
	local not_material = #x>3 and x[4]
	
	local res=_CheckFusionMaterial(c,matg,cg,chkf,not_material)
	if self_reference_effect then
		local tp=self_reference_effect:GetHandlerPlayer()
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
			local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}
			local all_mats=Group.CreateGroup()
			for _,ce in ipairs(egroup) do
				if ce and ce.GetLabel then
					local id=ce:GetLabel()
					local chk_fus=ce:GetValue()
					if aux.GetValueType(chk_fus)=="function" then
						chk_fus,_=chk_fus(ce,c,tp)
					end
					if chk_fus then
						local mats=Duel.GetMatchingGroup(aux.ExtraFusionFilter0,tp,0xff,0xff,nil,ce,ce:GetTarget())
						if #mats>0 then
							for ec1 in aux.Next(mats) do
								if ec1:GetFlagEffect(1005)>0 then
									if ec1:GetFlagEffect(1006)<=0 then
										ec1:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
									end
									local flag=Effect.CreateEffect(ce:GetHandler())
									flag:SetType(EFFECT_TYPE_SINGLE)
									flag:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
									flag:SetCode(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)
									flag:SetValue(id)
									flag:SetReset(RESET_CHAIN)
									ec1:RegisterEffect(flag)
								end
							end
							all_mats:Merge(mats)
						end
					end
				end
			end
			all_mats:Merge(matg)
			res=_CheckFusionMaterial(c,all_mats,cg,chkf,not_material)
			for ec2 in aux.Next(all_mats) do
				if ec2:GetFlagEffect(1006)>0 then
					ec2:ResetFlagEffect(1006)
				end
				for _,flag in ipairs({ec2:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
					if flag and flag.GetLabel then
						flag:Reset()
					end
				end
			end
		end
	end
	return res
end

Duel.SelectFusionMaterial = function(tp,fc,matg,...)
	local x={...}
	local cg= #x>0 and x[1] or nil
	local chkf= #x>1 and x[2] or PLAYER_NONE
	local not_material= #x>2 and x[3]
	if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
		return _SelectFusionMaterial(tp,fc,matg,cg,chkf,not_material)
	else
		local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}
		local all_mats=Group.CreateGroup()
		for _,ce in ipairs(egroup) do
			if ce and ce.GetLabel then
				local id=ce:GetLabel()
				local chk_fus=ce:GetValue()
				if aux.GetValueType(chk_fus)=="function" then
					chk_fus,_=chk_fus(ce,fc,tp)
				end
				if chk_fus then
					local mats=Duel.GetMatchingGroup(aux.ExtraFusionFilter,tp,0xff,0xff,nil,self_reference_effect,ce,ce:GetTarget())
					if #mats>0 then
						for ec1 in aux.Next(mats) do
							if ec1:GetFlagEffect(1005)>0 then
								if ec1:GetFlagEffect(1006)<=0 then
									ec1:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
								end
								local flag=Effect.CreateEffect(ce:GetHandler())
								flag:SetType(EFFECT_TYPE_SINGLE)
								flag:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
								flag:SetCode(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)
								flag:SetValue(id)
								flag:SetReset(RESET_CHAIN)
								ec1:RegisterEffect(flag)
							end
						end
						all_mats:Merge(mats)
					end
				end
			end
		end
		all_mats:Merge(matg)
		
		local chosen_mats=_SelectFusionMaterial(tp,fc,all_mats,cg,chkf,not_material)
		for ec2 in aux.Next(all_mats) do
			if ec2:GetFlagEffect(1006)>0 then
				ec2:ResetFlagEffect(1006)
			end
			for _,flag in ipairs({ec2:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
				if flag and flag.GetLabel then
					flag:Reset()
				end
			end
		end
		
		local extra_mats=Group.CreateGroup()
		local valid_effs,extra_opt={},{}
		for mc in aux.Next(chosen_mats) do
			for _,ce in ipairs(egroup) do
				if --[[mc:GetFlagEffect(1005)>0 and ]]ce and ce.GetLabel and ce:GetTarget()(ce,mc) then
					--register card as possible extra material
					extra_mats:AddCard(mc)
					mc:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
					--register description
					local d=ce:GetDescription()
					for _,desc in ipairs(extra_opt) do
						if desc==d then
							d=false
							break
						end
					end
					if d then
						table.insert(extra_opt,d)
						table.insert(valid_effs,ce)
					end
				end
			end
		end
		if #extra_opt>0 and (chosen_mats:IsExists(aux.PureExtraFilter,1,nil) or Duel.SelectYesNo(tp,aux.Stringid(1006,0))) then
			local ecount=0
			while aux.GetValueType(extra_mats)=="Group" and #extra_mats>0 and #extra_opt>0 and (ecount==0 or chosen_mats:IsExists(aux.PureExtraFilterLoop,1,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) or Duel.SelectYesNo(tp,aux.Stringid(1006,0))) do
				local opt=Duel.SelectOption(tp,table.unpack(extra_opt))+1
				local eff=valid_effs[opt]
				local _,max=eff:GetValue()(eff,nil)
				if not max or max==0 then max=#extra_mats end
				local emats=extra_mats:SelectSubGroup(tp,aux.ExtraMaterialFilterGoal,false,1,max,extra_mats)
				--local emats=extra_mats:FilterSelect(tp,aux.ExtraMaterialFilterSelect,1,max,nil,eff,eff:GetTarget())
				if #emats>0 then
					for tc in aux.Next(emats) do
						local e1=Effect.CreateEffect(tc)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
						e1:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
						e1:SetOperation(eff:GetOperation())
						e1:SetLabel(ecount)
						e1:SetReset(RESET_CHAIN)
						tc:RegisterEffect(e1,true)
						extra_mats:RemoveCard(tc)
					end
				end
				table.remove(extra_opt,opt)
				table.remove(valid_effs,opt)
				ecount=ecount+1
			end
		end
		for ec3 in aux.Next(matg) do
			if ec3:GetFlagEffect(1005)>0 then
				ec3:ResetFlagEffect(1005)
			end
		end
		for ec4 in aux.Next(chosen_mats) do
			if ec4:GetFlagEffect(1006)>0 and not ec4:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
				ec4:ResetFlagEffect(1006)
			end
		end
		return chosen_mats
	end
end

Auxiliary.FConditionFilterMix = function(c,fc,sub,concat_fusion,...)
	local fusion_type=concat_fusion and SUMMON_TYPE_SPECIAL or SUMMON_TYPE_FUSION
	if not c:IsCanBeFusionMaterial(fc,fusion_type) then return false end
	if c:IsHasEffect(EFFECT_GLITCHY_FUSION_SUBSTITUTE) then return true end
	for i,f in ipairs({...}) do
		if f(c,fc,sub) then return true end
	end
	return false
end

Auxiliary.FCheckMixGoal = function(sg,tp,fc,sub,chkfnf,...)
	for _,e in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
		local id=e:GetLabel()
		local val=e:GetValue()
		if val then
			local _,valmax=val(e,nil)
			if not (not sg or not sg:IsExists(aux.ExtraMaterialMaxCheck,valmax+1,nil,id)) then
				return false
			end
		end
	end
	return _FCheckMixGoal(sg,tp,fc,sub,chkfnf,...)
end

function Card.IsCanBeGlitchyFusionSubstitute(c,fc,sub,mg,sg)
	if not c:IsHasEffect(EFFECT_GLITCHY_FUSION_SUBSTITUTE) then return false end
	for _,ce in ipairs({c:IsHasEffect(EFFECT_GLITCHY_FUSION_SUBSTITUTE)}) do
		local tg=ce:GetTarget()
		if not tg or type(tg)=="function" and tg(ce,c,fc,sub,mg,sg) then
			return true
		end
	end
	return false
end

Auxiliary.AddFusionProcMix = function(c,sub,insf,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local val={...}
	local fun={}
	local mat={}
	for i=1,#val do
		if type(val[i])=='function' then
			fun[i]=function(c,fc,sub,mg,sg,chk) return val[i](c,fc,sub,mg,sg) and not c:IsHasEffect(6205579) or not chk and c:IsCanBeGlitchyFusionSubstitute(fc,sub,mg,sg) end
		elseif type(val[i])=='table' then
			fun[i]=function(c,fc,sub,mg,sg,chk)
					if not chk and c:IsCanBeGlitchyFusionSubstitute(fc,sub,mg,sg) then return true end
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
			fun[i]=function(c,fc,sub,_,_2,chk) return c:IsFusionCode(val[i]) or (sub and c:CheckFusionSubstitute(fc)) or not chk and c:IsCanBeGlitchyFusionSubstitute(fc,sub,mg,sg) end
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
	e1:SetCondition(Auxiliary.FConditionMix(insf,sub,table.unpack(fun)))
	e1:SetOperation(Auxiliary.FOperationMix(insf,sub,table.unpack(fun)))
	c:RegisterEffect(e1)
end
function Auxiliary.AddFusionProcMixRep(c,sub,insf,fun1,minc,maxc,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local val={fun1,...}
	local fun={}
	local mat={}
	for i=1,#val do
		if type(val[i])=='function' then
			fun[i]=function(c,fc,sub,mg,sg,chk) return val[i](c,fc,sub,mg,sg) and not c:IsHasEffect(6205579) or not chk and c:IsCanBeGlitchyFusionSubstitute(fc,sub,mg,sg) end
		elseif type(val[i])=='table' then
			fun[i]=function(c,fc,sub,mg,sg,chk)
					if not chk and c:IsCanBeGlitchyFusionSubstitute(fc,sub,mg,sg) then return true end
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
			fun[i]=function(c,fc,sub,_,_2,chk) return c:IsFusionCode(val[i]) or (sub and c:CheckFusionSubstitute(fc)) or not chk and c:IsCanBeGlitchyFusionSubstitute(fc,sub,mg,sg) end
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

Duel.SendtoGrave = function(tg,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _SendtoGrave(tg,reason)
	end
	local rg=tg:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
	tg:Sub(rg)
	local opt=0
	local ct1=_SendtoGrave(rg,reason)
	local ct2=0
	
	local ecount=0
	while #tg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(tg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel and ce:GetLabel()==ecount then
				extra_g:AddCard(tc)
				local fusop=ce:GetOperation()
				if not extra_op and fusop then
					extra_op=fusop
				end
			end
		end
		if #extra_g>0 then
			tg:Sub(extra_g)
			for tc in aux.Next(extra_g) do
				tc:ResetFlagEffect(1006)
			end
			local op = extra_op and extra_op or _SendtoGrave
			local extra_ct=op(extra_g,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			ct2=ct2+extra_ct
		end
		ecount=ecount+1
	end
	return ct1+ct2
end
Duel.Remove = function(tg,pos,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _Remove(tg,pos,reason)
	end
	local rg=tg:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
	tg:Sub(rg)
	local opt=0
	local ct1=_Remove(rg,pos,reason)
	local ct2=0
	local ecount=0
	while #tg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(tg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel and ce:GetLabel()==ecount then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			tg:Sub(extra_g)
			for tc in aux.Next(extra_g) do
				tc:ResetFlagEffect(1006)
			end
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
		ecount=ecount+1
	end
	return ct1+ct2
end
Duel.SendtoDeck = function(tg,p,seq,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _SendtoDeck(tg,p,seq,reason)
	end
	local rg=tg:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
	tg:Sub(rg)
	local opt=0
	local ct1=_SendtoDeck(rg,p,seq,reason)
	local ct2=0
	local ecount=0
	while #tg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(tg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel and ce:GetLabel()==ecount then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			tg:Sub(extra_g)
			for tc in aux.Next(extra_g) do
				tc:ResetFlagEffect(1006)
			end
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
		ecount=ecount+1
	end
	return ct1+ct2
end
Duel.Destroy = function(tg,reason,...)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _Destroy(tg,reason,...)
	end
	local rg=tg:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
	tg:Sub(rg)
	local opt=0
	local ct1=_Destroy(rg,reason,...)
	local ct2=0
	local ecount=0
	while #tg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(tg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel and ce:GetLabel()==ecount then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			tg:Sub(extra_g)
			for tc in aux.Next(extra_g) do
				tc:ResetFlagEffect(1006)
			end
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
		ecount=ecount+1
	end
	return ct1+ct2
end
Duel.SendtoHand = function(tg,p,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _SendtoHand(tg,p,reason)
	end
	local rg=tg:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
	tg:Sub(rg)
	local opt=0
	local ct1=_SendtoHand(rg,p,reason)
	local ct2=0
	local ecount=0
	while #tg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(tg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel and ce:GetLabel()==ecount then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			tg:Sub(extra_g)
			for tc in aux.Next(extra_g) do
				tc:ResetFlagEffect(1006)
			end
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
		ecount=ecount+1
	end
	return ct1+ct2
end

--Modified Functions: LINKS
function Auxiliary.ExtraLinkFilter0(c,ce,tg,lc)
	return c:IsCanBeLinkMaterial(lc) and tg(ce,c)
end

local _LinkCondition, _LinkTarget, _LinkOperation, _LCheckGoal =
Auxiliary.LinkCondition, Auxiliary.LinkTarget, Auxiliary.LinkOperation, Auxiliary.LCheckGoal

Auxiliary.LinkCondition = function(f,minc,maxc,gf)
	return	function(e,c,og,lmat,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local tp=c:GetControler()
				local mg=nil
				if og then
					mg=og:Filter(Auxiliary.LConditionFilter,nil,f,c,e)
				else
					mg=Auxiliary.GetLinkMaterials(tp,f,c,e)
				end
				if lmat~=nil then
					if not Auxiliary.LConditionFilter(lmat,f,c,e) then return false end
					mg:AddCard(lmat)
				end
				local fg=Auxiliary.GetMustMaterialGroup(tp,EFFECT_MUST_BE_LMATERIAL)
				if fg:IsExists(Auxiliary.MustMaterialCounterFilter,1,nil,mg) then return false end
				Duel.SetSelectedCard(fg)
				
				if Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) then
					local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)}
					local all_mats=Group.CreateGroup()
					for _,ce in ipairs(egroup) do
						if ce and ce.GetLabel then
							local id=ce:GetLabel()
							local chk_lnk=ce:GetValue()
							if aux.GetValueType(chk_lnk)=="function" then
								chk_lnk=chk_lnk(ce,c,mg,nil,tp)
							end
							if chk_lnk then
								local mats=Duel.GetMatchingGroup(aux.ExtraLinkFilter0,tp,0xff,0xff,nil,ce,ce:GetTarget(),c)
								if #mats>0 then
									for ec1 in aux.Next(mats) do
										if not mg:IsContains(ec1) then
											if ec1:GetFlagEffect(1006)<=0 then
												ec1:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
											end
											local flag=Effect.CreateEffect(ce:GetHandler())
											flag:SetType(EFFECT_TYPE_SINGLE)
											flag:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
											flag:SetCode(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)
											flag:SetValue(id)
											flag:SetReset(RESET_CHAIN)
											ec1:RegisterEffect(flag)
										end
									end
									all_mats:Merge(mats)
								end
							end
						end
					end
					all_mats:Merge(mg)
					local res=all_mats:CheckSubGroup(Auxiliary.LCheckGoal,minc,maxc,tp,c,gf,lmat)
					for ec2 in aux.Next(all_mats) do
						if ec2:GetFlagEffect(1006)>0 then
							ec2:ResetFlagEffect(1006)
						end
						for _,flag in ipairs({ec2:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
							if flag and flag.GetLabel then
								flag:Reset()
							end
						end
					end
					return res
				else			
					return mg:CheckSubGroup(Auxiliary.LCheckGoal,minc,maxc,tp,c,gf,lmat)
				end
			end
end

Auxiliary.LinkTarget = function(f,minc,maxc,gf)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,lmat,min,max)
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local mg=nil
				if og then
					mg=og:Filter(Auxiliary.LConditionFilter,nil,f,c,e)
				else
					mg=Auxiliary.GetLinkMaterials(tp,f,c,e)
				end
				if lmat~=nil then
					if not Auxiliary.LConditionFilter(lmat,f,c,e) then return false end
					mg:AddCard(lmat)
				end
				local fg=Auxiliary.GetMustMaterialGroup(tp,EFFECT_MUST_BE_LMATERIAL)
				Duel.SetSelectedCard(fg)
				
				if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					local cancel=Duel.IsSummonCancelable()
					local sg=mg:SelectSubGroup(tp,Auxiliary.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
					if sg then
						sg:KeepAlive()
						e:SetLabelObject(sg)
						return true
					else
						return false
					end
				else
					local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)}
					local all_mats=Group.CreateGroup()
					for _,ce in ipairs(egroup) do
						if ce and ce.GetLabel then
							local id=ce:GetLabel()
							local chk_lnk=ce:GetValue()
							if aux.GetValueType(chk_lnk)=="function" then
								chk_lnk=chk_lnk(ce,c,mg,nil,tp)
							end
							if chk_lnk then
								local mats=Duel.GetMatchingGroup(aux.ExtraLinkFilter0,tp,0xff,0xff,nil,ce,ce:GetTarget(),c)
								if #mats>0 then
									for ec1 in aux.Next(mats) do
										if not mg:IsContains(ec1) then
											if ec1:GetFlagEffect(1006)<=0 then
												ec1:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
											end
											local flag=Effect.CreateEffect(ce:GetHandler())
											flag:SetType(EFFECT_TYPE_SINGLE)
											flag:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
											flag:SetCode(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)
											flag:SetValue(id)
											flag:SetReset(RESET_CHAIN)
											ec1:RegisterEffect(flag)
										end
									end
									all_mats:Merge(mats)
								end
							end
						end
					end
					all_mats:Merge(mg)
					
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					local cancel=Duel.IsSummonCancelable()
					local chosen_mats=all_mats:SelectSubGroup(tp,Auxiliary.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
					for ec2 in aux.Next(all_mats) do
						if ec2:GetFlagEffect(1006)>0 then
							ec2:ResetFlagEffect(1006)
						end
						for _,flag in ipairs({ec2:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
							if flag and flag.GetLabel then
								flag:Reset()
							end
						end
					end
					
					local extra_mats=Group.CreateGroup()
					local valid_effs,extra_opt={},{}
					for mc in aux.Next(chosen_mats) do
						for _,ce in ipairs(egroup) do
							if --[[not mg:IsContains(mc) and ]]ce and ce.GetLabel and ce:GetTarget()(ce,mc) then
								--register card as possible extra material
								extra_mats:AddCard(mc)
								mc:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
								--register description
								local d=ce:GetDescription()
								for _,desc in ipairs(extra_opt) do
									if desc==d then
										d=false
										break
									end
								end
								if d then
									table.insert(extra_opt,d)
									table.insert(valid_effs,ce)
								end
							end
						end
					end
					if #extra_opt>0 and (chosen_mats:IsExists(aux.NOT(aux.IsInGroup),1,nil,mg) or Duel.SelectYesNo(tp,aux.Stringid(1006,0))) then
						local ecount=0
						while aux.GetValueType(extra_mats)=="Group" and #extra_mats>0 and #extra_opt>0 and (ecount==0 or chosen_mats:IsExists(aux.PureExtraFilterLoop,1,nil,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) or Duel.SelectYesNo(tp,aux.Stringid(1006,0))) do
							local opt=Duel.SelectOption(tp,table.unpack(extra_opt))+1
							local eff=valid_effs[opt]
							local _,max=eff:GetValue()(eff,nil)
							if not max or max==0 then max=#extra_mats end
							local emats=extra_mats:SelectSubGroup(tp,aux.ExtraMaterialFilterGoal,false,1,max,extra_mats)
							--local emats=extra_mats:FilterSelect(tp,aux.ExtraMaterialFilterSelect,1,max,nil,eff,eff:GetTarget())
							if #emats>0 then
								for tc in aux.Next(emats) do
									local e1=Effect.CreateEffect(tc)
									e1:SetType(EFFECT_TYPE_SINGLE)
									e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
									e1:SetCode(EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)
									e1:SetLabel(ecount)
									e1:SetOperation(eff:GetOperation())
									e1:SetReset(RESET_CHAIN)
									tc:RegisterEffect(e1,true)
									extra_mats:RemoveCard(tc)
								end
							end
							table.remove(extra_opt,opt)
							table.remove(valid_effs,opt)
							ecount=ecount+1
						end
					end
					for ec4 in aux.Next(chosen_mats) do
						if ec4:GetFlagEffect(1006)>0 and not ec4:IsHasEffect(EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) then
							ec4:ResetFlagEffect(1006)
						end
					end
					
					if chosen_mats then
						chosen_mats:KeepAlive()
						e:SetLabelObject(chosen_mats)
						return true
					else
						return false
					end
				end
			end
end

Auxiliary.LinkOperation = function(f,minc,maxc,gf)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				Auxiliary.LExtraMaterialCount(g,c,tp)
				
				local rg=g:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
				g:Sub(rg)
				local opt=0
				Duel.SendtoGrave(rg,REASON_MATERIAL+REASON_LINK)
				
				local ecount=0
				while #g>0 do
					local extra_g=Group.CreateGroup()
					local extra_op=false
					for tc in aux.Next(g) do
						local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)
						if ce and ce.GetLabel and ce:GetLabel()==ecount then
							extra_g:AddCard(tc)
							if not extra_op then
								extra_op=ce:GetOperation()
							end
						end
					end
					if #extra_g>0 then
						g:Sub(extra_g)
						for tc in aux.Next(extra_g) do
							tc:ResetFlagEffect(1006)
						end
						extra_op(extra_g)
						extra_g:DeleteGroup()
					end
					ecount=ecount+1
				end

				g:DeleteGroup()
			end
end

Auxiliary.LCheckGoal = function(sg,tp,lc,gf,lmat)
	for _,e in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)}) do
		local id=e:GetLabel()
		local val=e:GetValue()
		if val then
			local _,valmax=val(e,nil)
			if not (not sg or not sg:IsExists(aux.ExtraMaterialMaxCheck,valmax+1,nil,id)) then
				return false
			end
		end
	end
	return _LCheckGoal(sg,tp,lc,gf,lmat)
end
