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

UNIVERSAL_GLITCHY_TOKEN = 1231


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

-----------------------------------------------------------------------
-------------------------------GECCs-----------------------------------
GECC_OVERRIDE_ACTIVE_TYPE	 	= 0x1
GECC_OVERRIDE_REASON_EFFECT 	= 0x2
GECC_OVERRIDE_REASON_CARD 		= 0x4

function Card.SetCheatCode(c,code,temp)
	if not temp then
		if not c.cheat_code_table then
			local mt=getmetatable(c)
			mt.cheat_code_table=code
		else
			local ogcode = type(c.cheat_code_table)~="nil" and c.cheat_code_table or 0
			c.cheat_code_table=ogcode|code
		end
	else
		local id=c:GetFieldID()
		if not c.cheat_code_table_temp then
			local mt=getmetatable(c)
			mt.cheat_code_table_temp={}
			mt.cheat_code_table_temp[id]=code
		else
			local ogcode = type(c.cheat_code_table_temp[id])~="nil" and c.cheat_code_table_temp[id] or 0
			c.cheat_code_table_temp[id]=ogcode|code
		end
	end
end
function Effect.SetCheatCode(e,code,temp)
	local c=e:GetHandler()
	if not c then return end
	if not temp then
		if not c.cheat_code_effect_table then
			local mt=getmetatable(c)
			mt.cheat_code_effect_table={}
			mt.cheat_code_effect_table[e]=code
		else
			local ogcode = type(c.cheat_code_effect_table[e])~="nil" and c.cheat_code_effect_table[e] or 0
			c.cheat_code_effect_table[e]=ogcode|code
		end
	else
		local id=e:GetFieldID()
		if not c.cheat_code_effect_table_temp then
			local mt=getmetatable(c)
			mt.cheat_code_effect_table_temp={}
			mt.cheat_code_effect_table_temp[id]=code
		else
			local ogcode = type(c.cheat_code_effect_table_temp[id])~="nil" and c.cheat_code_effect_table_temp[id] or 0
			c.cheat_code_effect_table_temp[id]=ogcode|code
		end
	end
end
function Card.GetCheatCode(c)
	if not c then return 0 end
	local code = (not c.cheat_code_table) and 0 or c.cheat_code_table
	local temp = (not c.cheat_code_table_temp or not c.cheat_code_table_temp[c:GetFieldID()]) and 0 or c.cheat_code_table_temp[c:GetFieldID()]
	return (code&~temp)|temp
end
function Effect.GetCheatCode(e)
	local c=e:GetHandler()
	if not c then return 0 end
	local code = (not c.cheat_code_effect_table or not c.cheat_code_effect_table[e]) and 0 or c.cheat_code_effect_table[e]
	local temp = (not c.cheat_code_effect_table_temp or not c.cheat_code_effect_table_temp[e:GetFieldID()]) and 0 or c.cheat_code_effect_table_temp[e:GetFieldID()]
	return (code&~temp)|temp
end
function Card.IsHasCheatCode(c,code)
	local getcode=c:GetCheatCode()
	return getcode&code>0
end
function Effect.IsHasCheatCode(e,code)
	local getcode=e:GetCheatCode()
	return getcode&code>0
end

function Card.SetCheatCodeValue(c,code,val)
	if not c or not c:IsHasCheatCode(code) then return end
	if not c.cheat_code_table_values then
		local mt=getmetatable(c)
		mt.cheat_code_table_values={}
		mt.cheat_code_table_values[code]=val
	else
		c.cheat_code_table_values[code]=val
	end
end
function Effect.SetCheatCodeValue(e,code,val)
	local c=e:GetHandler()
	if not c or not e:IsHasCheatCode(code) then return end
	if not c.cheat_code_effect_table_values then
		local mt=getmetatable(c)
		mt.cheat_code_effect_table_values={}
		mt.cheat_code_effect_table_values[e]={}
		mt.cheat_code_effect_table_values[e][code]=val
	else
		if not c.cheat_code_effect_table_values[e] then
			c.cheat_code_effect_table_values[e]={}
		end
		c.cheat_code_effect_table_values[e][code]=val
	end
end
function Card.GetCheatCodeValue(c,code)
	if not c or not c:IsHasCheatCode(code) or not c.cheat_code_table_values or not c.cheat_code_table_values[code] then return end
	return c.cheat_code_table_values[code]
end
function Effect.GetCheatCodeValue(e,code)
	local c=e:GetHandler()
	if not c or not e:IsHasCheatCode(code) or not c.cheat_code_effect_table_values or not c.cheat_code_effect_table_values[e] or not c.cheat_code_effect_table_values[e][code] then return end
	return c.cheat_code_effect_table_values[e][code]
end

local _GetActiveType, _IsActiveType, _GetReasonCard, _GetReasonEffect = Effect.GetActiveType, Effect.IsActiveType, Card.GetReasonCard, Card.GetReasonEffect

Effect.GetActiveType = function(e)
	if e:IsHasCheatCode(GECC_OVERRIDE_ACTIVE_TYPE) then
		return e:GetHandler():GetType()
	else
		return _GetActiveType(e)
	end
end
Effect.IsActiveType = function(e,typ)
	if e:IsHasCheatCode(GECC_OVERRIDE_ACTIVE_TYPE) then
		return e:GetHandler():GetType()&typ>0
	else
		return _IsActiveType(e,typ)
	end
end
Card.GetReasonEffect = function(c)
	if c:IsHasCheatCode(GECC_OVERRIDE_REASON_EFFECT) then
		return c:GetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT)
	else
		return _GetReasonEffect(c)
	end
end
Card.GetReasonCard = function(c)
	if c:IsHasCheatCode(GECC_OVERRIDE_REASON_CARD) then
		return c:GetCheatCodeValue(GECC_OVERRIDE_REASON_CARD)
	else
		return _GetReasonCard(c)
	end
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
local _SendtoGrave, _Remove, _SendtoDeck, _Destroy, _SendtoHand, _FShaddollCondition, _FShaddollOperation =
Duel.SendtoGrave, Duel.Remove, Duel.SendtoDeck, Duel.Destroy, Duel.SendtoHand, Auxiliary.FShaddollCondition, Auxiliary.FShaddollOperation

Auxiliary.FGoalCheckGlitchy = nil
Auxiliary.EnableOnlyGlitchyFusionProcs = false

function Auxiliary.AddFusionProcMix(c,sub,insf,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local val={...}
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

function Auxiliary.FConditionMix(insf,sub,...)
	local funs={...}
	return	function(e,g,gc,chkfnf)
				if g==nil then return insf and Auxiliary.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=chkfnf&0x100>0
				local concat_fusion=chkfnf&0x200>0
				local sub=(sub or notfusion) and not concat_fusion
				local mg=g:Filter(Auxiliary.FConditionFilterMix,c,c,sub,concat_fusion,table.unpack(funs))
				if gc then
					if not mg:IsContains(gc) then return false end
					Duel.SetSelectedCard(Group.FromCards(gc))
				end
				if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
					return mg:CheckSubGroup(Auxiliary.FCheckMixGoal,#funs,#funs,tp,c,sub,chkfnf,table.unpack(funs))
				else
					local original_mats=mg:Clone()
					local extramats,extrafuns,extramaxs,extramats_only={},{},{},{}
					for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
						if ce and ce.GetLabel then
							local val=ce:GetValue()
							if not val or val(ce,c,tp) then
								local tg=ce:GetTarget()
								local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,mg,ce,tg,tp,c)
								if #exg>0 then
									mg:Merge(exg)
									
									local exmg=exg:Filter(aux.TRUE,original_mats)
									table.insert(extramats_only,exmg)
									original_mats:Merge(exg)
									table.insert(extramats,exg)
									if tg then
										table.insert(extrafuns,tg)
									else
										table.insert(extrafuns,aux.TRUE)
									end
									local max=1
									if val then
										_,max=val(ce,c,tp)
										max = type(max)=="number" and max or 1
									end
									table.insert(extramaxs,max)
								end
							end
						end
					end
					return mg:CheckSubGroup(Auxiliary.FCheckMixExGoal,#funs,#funs,tp,c,sub,chkfnf,extramats,extrafuns,extramaxs,extramats_only,table.unpack(funs))
				end
			end
end
function Auxiliary.FOperationMix(insf,sub,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=chkfnf&0x100>0
				local concat_fusion=chkfnf&0x200>0
				local sub=(sub or notfusion) and not concat_fusion
				local mg=eg:Filter(Auxiliary.FConditionFilterMix,c,c,sub,concat_fusion,table.unpack(funs))
				if gc then Duel.SetSelectedCard(Group.FromCards(gc)) end
				--
				local original_mats, original_mats2 = mg:Clone(), mg:Clone()
				local extramats,extramats_repetead,extrafuns,extramaxs,extraeffs,extramats_only={},{},{},{},{},{}
				for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
					if ce and ce.GetLabel then
						local val=ce:GetValue()
						if not val or val(ce,c,tp) then
							local tg=ce:GetTarget()
							local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,nil,ce,tg,tp,c)
							if #exg>0 then
								table.insert(extraeffs,ce)
								mg:Merge(exg)
								local exmg=exg:Filter(aux.TRUE,original_mats2)
								table.insert(extramats_only,exmg)
								original_mats2:Merge(exg)
								table.insert(extramats,exg)
								if tg then
									table.insert(extrafuns,tg)
								else
									table.insert(extrafuns,aux.TRUE)
								end
								local max=1
								if val then
									_,max=val(ce,c,tp)
									max = type(max)=="number" and max or 1
								end
								table.insert(extramaxs,max)
							end
						end
					end
				end
				
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
				local sg=mg:SelectSubGroup(tp,Auxiliary.FCheckMixExGoal,false,#funs,#funs,tp,c,sub,chkfnf,extramats,extrafuns,extramaxs,extramats_only,table.unpack(funs))
				if #extramats>0 then
					for i,exg in ipairs(extramats) do
						local ce=extraeffs[i]
						local tg=ce:GetTarget()
						exg=exg:Filter(aux.NOT(Card.IsHasEffect),nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
						if ce:GetCode()==EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL then
							exg=exg:Filter(aux.GlitchyFMaterialExFilter,nil,ce,tg,tp,c,false,sg,sg,true)
							local exmg=original_mats:Filter(aux.GlitchyFMaterialExFilter,nil,ce,tg,tp,c,false,sg,sg,true)
							if #exmg>0 then
								original_mats:Merge(exg)
								for clone in aux.Next(exmg) do
									if not extramats_repetead[clone] then
										extramats_repetead[clone]=0
									end
									extramats_repetead[clone]=extramats_repetead[clone]+1
								end
							end
						end
						if #exg>0 then
							local max=extramaxs[i]
							local valid=sg:IsExists(Card.IsContained,1,nil,exg)
							local forced=sg:IsExists(aux.FMaterialFilterSelEx,1,nil,exg,extramats_repetead)
							if valid and (forced or Duel.SelectYesNo(tp,ce:GetDescription())) then
								Duel.Hint(HINT_CARD,tp,ce:GetHandler():GetOriginalCode())
								local fg=sg:Filter(aux.FMaterialFilterSelEx,nil,exg,extramats_repetead)
								if #fg<max and exg:FilterCount(aux.TRUE,fg)>0 and Duel.SelectYesNo(tp,ce:GetDescription()) then
									local opt=exg:Select(tp,1,max-#fg,fg)
									fg:Merge(opt)
								end
								Duel.HintSelection(fg)
								for tc in aux.Next(fg) do
									local e1=Effect.CreateEffect(ce:GetOwner())
									e1:SetType(EFFECT_TYPE_FIELD)
									e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
									e1:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
									e1:SetOperation(ce:GetOperation())
									e1:SetReset(RESET_CHAIN)
									tc:RegisterEffect(e1)
								end
							end
							for clone in aux.Next(exg) do
								if extramats_repetead[clone] then
									extramats_repetead[clone]=extramats_repetead[clone]-1
								end
							end
						end
					end
				end			
				Duel.SetFusionMaterial(sg)
			end
end
function Auxiliary.GlitchyFMaterialExFilter(c,ce,tg,tp,fc,sub,mg,sg,depth)
	return not c:IsImmuneToEffect(ce) and (not tg or tg(c,tp,fc,sub,mg,sg,depth))
end
function Auxiliary.FMaterialFilterSelEx(c,exg,extramats_repetead)
	return exg:IsContains(c) and (not extramats_repetead[c] or extramats_repetead[c]<=0)
end
function Auxiliary.FCheckMixExGoal(sg,tp,fc,sub,chkfnf,extramats,extrafuns,extramaxs,extramats_only,...)
	local chkf=chkfnf&0xff
	local concat_fusion=chkfnf&0x200>0
	if not concat_fusion and sg:IsExists(Auxiliary.TuneMagicianCheckX,1,nil,sg,EFFECT_TUNE_MAGICIAN_F) then return false end
	if not Auxiliary.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	local g=Group.CreateGroup()
	local xct={}
	local res=sg:IsExists(Auxiliary.FCheckMixEx,1,nil,tp,sg,g,fc,sub,extramats,extrafuns,extramaxs,extramats_only,xct,...)
	local res1=(chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0)
	local res2=(not Auxiliary.FCheckAdditional or Auxiliary.FCheckAdditional(tp,sg,fc))
	local res3=(not Auxiliary.FGoalCheckAdditional or Auxiliary.FGoalCheckAdditional(tp,sg,fc))
	local res4=(not Auxiliary.FGoalCheckGlitchy or Auxiliary.FGoalCheckGlitchy(tp,sg,fc,sub,chkfnf))
	----Debug.Message(res4)
	return res and res1	and res2 and res3 and res4
end
function Auxiliary.FCheckMixEx(c,tp,mg,sg,fc,sub,extramats,extrafuns,extramaxs,extramats_only,xct,fun1,fun2,...)
	local xchk=false
	if fun2 then
		sg:AddCard(c)
		local res=false
		--Debug.Message('fun2 '..tostring(c:GetCode()))
		if #extramats>0 then
			for i,exg in ipairs(extramats) do
				if exg:IsContains(c) then
					if extramats_only and extramats_only[i]:IsContains(c) then
						xchk=true
					end
					if (extrafuns[i](c,tp,fc,false,mg,sg,true) or (sub and extrafuns[i](c,tp,fc,sub,mg,sg,true))) and (not xct[i] or xct[i]<extramaxs[i]) then
						local presub=sub
						if not extrafuns[i](c,tp,fc,false,mg,sg,true) and sub and extrafuns[i](c,tp,fc,sub,mg,sg,true) then
							sub=false
						end
						if not xct[i] then
							xct[i]=0
						end
						xct[i]=xct[i]+1
						res=mg:IsExists(Auxiliary.FCheckMixEx,1,sg,tp,mg,sg,fc,sub,extramats,extrafuns,extramaxs,extramats_only,xct,fun2,...)
						if res then
							break
						else
							xct[i]=xct[i]-1
							sub=presub
						end
					end
				end
			end
		end
		--Debug.Message(tostring(res)..' '..tostring(xchk)..' '..tostring(c:GetCode()))
		if not xchk then
			if fun1(c,fc,false,mg,sg) then
				res=mg:IsExists(Auxiliary.FCheckMixEx,1,sg,tp,mg,sg,fc,sub,extramats,extrafuns,extramaxs,extramats_only,xct,fun2,...)
			elseif sub and fun1(c,fc,sub,mg,sg) then
				res=mg:IsExists(Auxiliary.FCheckMixEx,1,sg,tp,mg,sg,fc,false,extramats,extrafuns,extramaxs,extramats_only,xct,fun2,...)
			end
		end
		sg:RemoveCard(c)
		--Debug.Message(' ')
		return res
	else
		--Debug.Message('final '..tostring(c:GetCode()))
		if #extramats>0 then
			for i,exg in ipairs(extramats) do
				if exg:IsContains(c) then
					if extramats_only and extramats_only[i]:IsContains(c) then
						xchk=true
					end
					--Debug.Message('final extracheck '..tostring(c:GetCode().." "..tostring(xct[i])))
					if extrafuns[i](c,tp,fc,sub,mg,sg,true) and (not xct[i] or xct[i]<extramaxs[i]) then
						if not xct[i] then
							xct[i]=0
						end
						xct[i]=xct[i]+1
						return true
					end
				end
			end
		end
		--Debug.Message('final check '..tostring(c:GetCode().." "..tostring(not xchk and fun1(c,fc,sub,mg,sg))))
		return not xchk and fun1(c,fc,sub,mg,sg)
	end
end
--
function Auxiliary.AddFusionProcShaddoll(c,attr)
	local mt=getmetatable(c)
	if mt.material_funs==nil then
		mt.material_funs={aux.FShaddollFilter1,aux.FShaddollFilterAttr(attr)}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(Auxiliary.FShaddollCondition(attr))
	e1:SetOperation(Auxiliary.FShaddollOperation(attr))
	c:RegisterEffect(e1)
end
function Auxiliary.FShaddollFilterAttr(attr)
	return	function(c)
				return aux.FShaddollFilter2(c,attr)
			end
end
function Auxiliary.FShaddollCondition(attr)
	return 	function(e,g,gc,chkf)
				if not aux.EnableOnlyGlitchyFusionProcs then
					return _FShaddollCondition(attr)(e,g,gc,chkf)
				else
					if g==nil then return Auxiliary.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
					local c=e:GetHandler()
					local tp=e:GetHandlerPlayer()
					local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					local exg=nil
					local mg=g:Filter(Auxiliary.FConditionFilterMix,c,c,false,false,aux.FShaddollFilter1,aux.FShaddollFilterAttr(attr))
					
					local original_mats=mg:Clone()
					local extramats,extraeffs,extrafuns,extramaxs,extramats_only={},{},{},{},{}
					if fc and fc:IsHasEffect(81788994) and fc:IsCanRemoveCounter(tp,0x16,3,REASON_EFFECT) then
						local fe=fc:IsHasEffect(81788994)
						exg=Duel.GetMatchingGroup(Auxiliary.FShaddollExFilter,tp,0,LOCATION_MZONE,mg,c,attr,fe)
						mg:Merge(exg)
						local exmg=exg:Filter(aux.TRUE,original_mats)
						table.insert(extramats_only,exmg)
						original_mats:Merge(exg)
						table.insert(extramats,exg)
						table.insert(extraeffs,fe)
						table.insert(extrafuns,aux.TRUE)
						table.insert(extramaxs,1)
					end
					if gc then
						if not mg:IsContains(gc) then return false end
						Duel.SetSelectedCard(Group.FromCards(gc))
					end
					if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
						return mg:CheckSubGroup(Auxiliary.FCheckMixGoal,2,2,tp,c,false,false,aux.FShaddollFilter1,aux.FShaddollFilterAttr(attr))
					else
						for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
							if ce and ce.GetLabel then
								local val=ce:GetValue()
								if not val or val(ce,c,tp) then
									local tg=ce:GetTarget()
									local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,mg,ce,tg,tp,c)
									if #exg>0 then
										mg:Merge(exg)
										table.insert(extramats,exg)
										local exmg=exg:Filter(aux.TRUE,original_mats)
										table.insert(extramats_only,exmg)
										original_mats:Merge(exg)
										table.insert(extraeffs,ce)
										if tg then
											table.insert(extrafuns,tg)
										else
											table.insert(extrafuns,aux.TRUE)
										end
										local max=1
										if val then
											_,max=val(ce,c,tp)
											max = type(max)=="number" and max or 1
										end
										table.insert(extramaxs,max)
									end
								end
							end
						end
						return mg:CheckSubGroup(Auxiliary.FCheckMixExGoal,2,2,tp,c,false,chkf,extramats,extrafuns,extramaxs,extramats_only,aux.FShaddollFilter1,aux.FShaddollFilterAttr(attr))
					end
				end
			end
end
function Auxiliary.FShaddollOperation(attr)
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
				if not aux.EnableOnlyGlitchyFusionProcs then
					return _FShaddollOperation(attr)(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
				else
					local c=e:GetHandler()
					local mg=eg:Filter(Auxiliary.FConditionFilterMix,c,c,false,false,aux.FShaddollFilter1,aux.FShaddollFilterAttr(attr))
					local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					local exg0=nil
					
					local original_mats, original_mats2 = mg:Clone(), mg:Clone()
					local extramats,extramats_repetead,extraeffs,extrafuns,extramaxs,extramats_only={},{},{},{},{},{}
					if fc and fc:IsHasEffect(81788994) and fc:IsCanRemoveCounter(tp,0x16,3,REASON_EFFECT) then
						local fe=fc:IsHasEffect(81788994)
						exg0=Duel.GetMatchingGroup(Auxiliary.FShaddollExFilter,tp,0,LOCATION_MZONE,nil,c,attr,fe)
						if #exg0>0 then
							mg:Merge(exg0)
							table.insert(extramats,exg0)
							local exmg=exg0:Filter(aux.TRUE,original_mats2)
							table.insert(extramats_only,exmg)
							original_mats2:Merge(exg0)
							table.insert(extraeffs,fe)
							table.insert(extrafuns,aux.TRUE)
							table.insert(extramaxs,1)
						end
					end
					if gc then Duel.SetSelectedCard(Group.FromCards(gc)) end
					--
					for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
						if ce and ce.GetLabel then
							local val=ce:GetValue()
							if not val or val(ce,c,tp) then
								local tg=ce:GetTarget()
								local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,nil,ce,tg,tp,c)
								if #exg>0 then
									table.insert(extramats,exg)
									table.insert(extraeffs,ce)
									mg:Merge(exg)
									local exmg=exg:Filter(aux.TRUE,original_mats2)
									table.insert(extramats_only,exmg)
									original_mats2:Merge(exg)
									if tg then
										table.insert(extrafuns,tg)
									else
										table.insert(extrafuns,aux.TRUE)
									end
									local max=1
									if val then
										_,max=val(ce,c,tp)
										max = type(max)=="number" and max or 1
									end
									table.insert(extramaxs,max)
								end
							end
						end
					end
					
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					local sg=mg:SelectSubGroup(tp,Auxiliary.FCheckMixExGoal,false,2,2,tp,c,false,chkf,extramats,extrafuns,extramaxs,extramats_only,aux.FShaddollFilter1,aux.FShaddollFilterAttr(attr))
					if #extramats>0 then
						for i,exg in ipairs(extramats) do
							local ce=extraeffs[i]
							local tg=ce:GetTarget()
							exg=exg:Filter(aux.NOT(Card.IsHasEffect),nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
							if ce:GetCode()==EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL then
								exg=exg:Filter(aux.GlitchyFMaterialExFilter,nil,ce,tg,tp,c,false,sg,sg,true)
								local exmg=original_mats:Filter(aux.GlitchyFMaterialExFilter,nil,ce,tg,tp,c,false,sg,sg,true)
								if #exmg>0 then
									original_mats:Merge(exg)
									for clone in aux.Next(exmg) do
										if not extramats_repetead[clone] then
											extramats_repetead[clone]=0
										end
										extramats_repetead[clone]=extramats_repetead[clone]+1
									end
								end
							end
							if #exg>0 then								
								local max=extramaxs[i]
								local valid=sg:IsExists(Card.IsContained,1,nil,exg)
								local forced=sg:IsExists(aux.FMaterialFilterSelEx,1,nil,exg,extramats_repetead)
								local ShaddollPrison = ce:GetCode()==81788994 and fc and fc:IsHasEffect(81788994) and fc:IsCanRemoveCounter(tp,0x16,3,REASON_EFFECT)
								if valid and (forced or Duel.SelectYesNo(tp,ce:GetDescription())) then
									Duel.Hint(HINT_CARD,tp,ce:GetHandler():GetOriginalCode())
									if ShaddollPrison then
										fc:RemoveCounter(tp,0x16,3,REASON_EFFECT)
									end
									local fg=sg:Filter(aux.FMaterialFilterSelEx,nil,exg,extramats_repetead)
									if #fg<max and exg:FilterCount(aux.TRUE,fg)>0 and Duel.SelectYesNo(tp,ce:GetDescription()) then
										local opt=exg:Select(tp,1,max-#fg,fg)
										fg:Merge(opt)
									end
									Duel.HintSelection(fg)
									for tc in aux.Next(fg) do
										local e1=Effect.CreateEffect(ce:GetOwner())
										e1:SetType(EFFECT_TYPE_FIELD)
										e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
										e1:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
										e1:SetOperation(ce:GetOperation())
										e1:SetReset(RESET_CHAIN)
										tc:RegisterEffect(e1)
									end
								end
								for clone in aux.Next(exg) do
									if extramats_repetead[clone] then
										extramats_repetead[clone]=extramats_repetead[clone]-1
									end
								end
							end
						end
					end			
					Duel.SetFusionMaterial(sg)
				end
			end
end

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
function Auxiliary.FConditionMixRep(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,g,gc,chkfnf)
				if g==nil then return insf and Auxiliary.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=chkfnf&0x100>0
				local concat_fusion=chkfnf&0x200>0
				local sub=(sub or notfusion) and not concat_fusion
				local mg=g:Filter(Auxiliary.FConditionFilterMix,c,c,sub,concat_fusion,fun1,table.unpack(funs))
				if gc then
					if not mg:IsContains(gc) then return false end
					local sg=Group.CreateGroup()
					return Auxiliary.FSelectMixRep(gc,tp,mg,sg,c,sub,chkfnf,fun1,minc,maxc,table.unpack(funs))
				end
				local sg=Group.CreateGroup()
				if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
					return mg:IsExists(Auxiliary.FSelectMixRep,1,nil,tp,mg,sg,c,sub,chkfnf,fun1,minc,maxc,table.unpack(funs))
				else
					local original_mats=mg:Clone()
					local extramats,extrafuns,extramaxs,extramats_only={},{},{},{}
					for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
						if ce and ce.GetLabel then
							local val=ce:GetValue()
							if not val or val(ce,c,tp) then
								local tg=ce:GetTarget()
								local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,mg,ce,tg,tp,c)
								if #exg>0 then
									mg:Merge(exg)
									table.insert(extramats,exg)
									local exmg=exg:Filter(aux.TRUE,original_mats)
									table.insert(extramats_only,exmg)
									original_mats:Merge(exg)
									if tg then
										table.insert(extrafuns,tg)
									else
										table.insert(extrafuns,aux.TRUE)
									end
									local max=1
									if val then
										_,max=val(ce,c,tp)
										max = type(max)=="number" and max or 1
									end
									table.insert(extramaxs,max)
								end
							end
						end
					end
					return mg:IsExists(Auxiliary.FSelectMixRepEx,1,nil,tp,mg,sg,c,sub,chkfnf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,table.unpack(funs))
				end
			end
end
function Auxiliary.FOperationMixRep(insf,sub,fun1,minc,maxc,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local c=e:GetHandler()
				local tp=c:GetControler()
				local notfusion=chkfnf&0x100>0
				local concat_fusion=chkfnf&0x200>0
				local sub=(sub or notfusion) and not concat_fusion
				local mg=eg:Filter(Auxiliary.FConditionFilterMix,c,c,sub,concat_fusion,fun1,table.unpack(funs))
				local sg=Group.CreateGroup()
				if gc then sg:AddCard(gc) end
				
				local original_mats, original_mats2 = mg:Clone(), mg:Clone()
				local extramats,extramats_repetead,extrafuns,extramaxs,extraeffs,extramats_only={},{},{},{},{},{}
				for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
					if ce and ce.GetLabel then
						local val=ce:GetValue()
						if not val or val(ce,c,tp) then
							local tg=ce:GetTarget()
							local exg=Duel.GetMatchingGroup(aux.GlitchyFMaterialExFilter,tp,0xff,0xff,nil,ce,tg,tp,c)
							if #exg>0 then
								table.insert(extraeffs,ce)
								mg:Merge(exg)
								table.insert(extramats,exg)
								local exmg=exg:Filter(aux.TRUE,original_mats2)
								table.insert(extramats_only,exmg)
								original_mats2:Merge(exg)
								if tg then
									table.insert(extrafuns,tg)
								else
									table.insert(extrafuns,aux.TRUE)
								end
								local max=1
								if val then
									_,max=val(ce,c,tp)
									max = type(max)=="number" and max or 1
								end
								table.insert(extramaxs,max)
							end
						end
					end
				end
				
				while sg:GetCount()<maxc+#funs do
					local cg=mg:Filter(Auxiliary.FSelectMixRepEx,sg,tp,mg,sg,c,sub,chkfnf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,table.unpack(funs))
					if cg:GetCount()==0 then break end
					local finish=Auxiliary.FCheckMixRepGoalEx(tp,sg,c,sub,chkfnf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,table.unpack(funs))
					--Debug.Message(tostring(finish)..'1')
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
					--Debug.Message(tostring(finish)..'2')
				end
				
				if #extramats>0 then
					for i,exg in ipairs(extramats) do
						local ce=extraeffs[i]
						local tg=ce:GetTarget()
						exg=exg:Filter(aux.NOT(Card.IsHasEffect),nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
						if ce:GetCode()==EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL then
							exg=exg:Filter(aux.GlitchyFMaterialExFilter,nil,ce,tg,tp,c,false,sg,sg,true)
							local exmg=original_mats:Filter(aux.GlitchyFMaterialExFilter,nil,ce,tg,tp,c,false,sg,sg,true)
							if #exmg>0 then
								original_mats:Merge(exg)
								for clone in aux.Next(exmg) do
									if not extramats_repetead[clone] then
										extramats_repetead[clone]=0
									end
									extramats_repetead[clone]=extramats_repetead[clone]+1
								end
							end
						end
						if #exg>0 then
							local max=extramaxs[i]
							local valid=sg:IsExists(Card.IsContained,1,nil,exg)
							local forced=sg:IsExists(aux.FMaterialFilterSelEx,1,nil,exg,extramats_repetead)
							if valid and (forced or Duel.SelectYesNo(tp,ce:GetDescription())) then
								Duel.Hint(HINT_CARD,tp,ce:GetHandler():GetOriginalCode())
								local fg=sg:Filter(aux.FMaterialFilterSelEx,nil,exg,extramats_repetead)
								if #fg<max and exg:FilterCount(aux.TRUE,fg)>0 and Duel.SelectYesNo(tp,ce:GetDescription()) then
									local opt=exg:Select(tp,1,max-#fg,fg)
									fg:Merge(opt)
								end
								Duel.HintSelection(fg)
								for tc in aux.Next(fg) do
									local e1=Effect.CreateEffect(ce:GetOwner())
									e1:SetType(EFFECT_TYPE_FIELD)
									e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
									e1:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
									e1:SetOperation(ce:GetOperation())
									e1:SetReset(RESET_CHAIN)
									tc:RegisterEffect(e1)
								end
							end
							for clone in aux.Next(exg) do
								if extramats_repetead[clone] then
									extramats_repetead[clone]=extramats_repetead[clone]-1
								end
							end
						end
					end
				end			
				
				Duel.SetFusionMaterial(sg)
			end
end
--Auxiliary.NoDebug = false
function Auxiliary.FSelectMixRepEx(c,tp,mg,sg,fc,sub,chkfnf,...)
	--Debug.Message(c:GetCode())
	sg:AddCard(c)
	local res=false
	if Auxiliary.FCheckAdditional and not Auxiliary.FCheckAdditional(tp,sg,fc) then
		res=false
	elseif Auxiliary.FCheckMixRepGoalEx(tp,sg,fc,sub,chkfnf,...) then
		res=true
	else
		local g=Group.CreateGroup()
		local xct={}
		res=sg:IsExists(Auxiliary.FCheckMixRepSelectedEx,1,nil,xct,tp,mg,sg,g,fc,sub,chkfnf,...)
	end
	sg:RemoveCard(c)
	return res
end
function Auxiliary.FCheckMixRepGoalEx(tp,sg,fc,sub,chkfnf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,...)
	--Debug.Message(0)
	local chkf=chkfnf&0xff
	local res1 = (sg:GetCount()<minc+#{...} or sg:GetCount()>maxc+#{...})
	--Debug.Message('res1: '..tostring(res1))
	if res1 then return false end
	local res2 = not (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0)
	--Debug.Message('res2: '..tostring(res2))
	if res2 then return false end
	local res3 = Auxiliary.FCheckAdditional and not Auxiliary.FCheckAdditional(tp,sg,fc)
	--Debug.Message('res3: '..tostring(res3))
	if res3 then return false end
	local res4 = Auxiliary.FGoalCheckGlitchy and not Auxiliary.FGoalCheckGlitchy(tp,sg,fc,sub,chkfnf)
	--Debug.Message('res4: '..tostring(res4))
	if res4 then return false end
	local res5 = not Auxiliary.FCheckMixRepGoalCheck(tp,sg,fc,chkfnf)
	--Debug.Message('res5: '..tostring(res5))
	if res5 then return false end
	local g=Group.CreateGroup()
	local res6 = Auxiliary.FCheckMixRepEx(tp,sg,g,fc,sub,chkf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,{},...)
	--if not aux.NoDebug then Debug.Message('res6: '..tostring(res6)) end
	return res6
end
function Auxiliary.FCheckMixRepGoalCheck(tp,sg,fc,chkfnf)
	local concat_fusion=chkfnf&0x200>0
	if not concat_fusion and sg:IsExists(Auxiliary.TuneMagicianCheckX,1,nil,sg,EFFECT_TUNE_MAGICIAN_F) then return false end
	if not Auxiliary.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	if Auxiliary.FGoalCheckAdditional and not Auxiliary.FGoalCheckAdditional(tp,sg,fc) then return false end
	return true
end
function Auxiliary.FCheckMixRepEx(tp,sg,g,fc,sub,chkf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,xct,fun2,...)
	if fun2 then
		return sg:IsExists(Auxiliary.FCheckMixRepFilterEx,1,g,tp,sg,g,fc,sub,chkf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,xct,fun2,...)
	else
		local xg=Group.CreateGroup()
		local used_sub=false
		local tg=sg:Filter(aux.TRUE,g)
		for c in aux.Next(tg) do
			local xchk=false
			if #extramats>0 then
				for i,exg in ipairs(extramats) do
					if exg:IsContains(c) then
						if extramats_only and extramats_only[i]:IsContains(c) then
							xchk=true
						end
						if (extrafuns[i](c,tp,fc,false,mg,sg,true) or (not used_sub and extrafuns[i](c,tp,fc,sub,mg,sg,true))) and (not xct[i] or xct[i]<extramaxs[i]) then
							if not extrafuns[i](c,tp,fc,false,mg,sg,true) and extrafuns[i](c,tp,fc,sub,mg,sg,true) then
								used_sub=true
							end
							if not xct[i] then
								xct[i]=0
							end
							xct[i]=xct[i]+1
							xg:AddCard(c)
						end
					end
				end
			end
			if not xchk and (fun1(c,fc,false,mg,sg) or (not used_sub and fun1(c,tp,fc,sub,mg,sg,true))) then
				if not fun1(c,tp,fc,false,mg,sg,true) and fun1(c,tp,fc,sub,mg,sg,true) then
					used_sub=true
				end
				xg:AddCard(c)
			end
		end
		local ct1=#xg
		return ct1==sg:GetCount()-g:GetCount() --and ct1-ct2<=1
	end
end
function Auxiliary.FCheckMixRepFilterEx(c,tp,sg,g,fc,sub,chkf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,xct,fun2,...)
	--Debug.Message("02 "..tostring(c:GetCode()))
	local xchk=false
	if #extramats>0 then
		for i,exg in ipairs(extramats) do
			--Debug.Message('extramat 02')
			if exg:IsContains(c) then
				if extramats_only and extramats_only[i]:IsContains(c) then
					xchk=true
				end
				if extrafuns[i](c,tp,fc,sub,mg,sg,true) and (not xct[i] or xct[i]<extramaxs[i]) then
					if not xct[i] then
						xct[i]=0
					end
					xct[i]=xct[i]+1
					g:AddCard(c)
					local res=Auxiliary.FCheckMixRepEx(tp,sg,g,fc,sub,chkf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,xct,...)
					g:RemoveCard(c)
					if res then
						return true
					else
						xct[i]=xct[i]-1
					end
				end
			end
		end
	end
	--Debug.Message(tostring(xchk)..' '..tostring(fun2(c,fc,sub,mg,sg)))
	if not xchk and fun2(c,fc,sub,mg,sg) then
		--Debug.Message('function 02')
		g:AddCard(c)
		local sub=sub and fun2(c,fc,false,mg,sg)
		local res=Auxiliary.FCheckMixRepEx(tp,sg,g,fc,sub,chkf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,xct,...)
		g:RemoveCard(c)
		return res
	end
	return false
end

function Auxiliary.FCheckMixRepSelectedEx(c,...)
	return Auxiliary.FCheckMixRepTemplateEx(c,Auxiliary.FCheckMixRepSelectedCondEx,...)
end
function Auxiliary.FCheckMixRepSelectedCondEx(xct,tp,mg,sg,g,...)
	if g:GetCount()<sg:GetCount() then
		--Debug.Message(21)
		return sg:IsExists(Auxiliary.FCheckMixRepSelectedEx,1,g,xct,tp,mg,sg,g,...)
	else
		--Debug.Message(22)
		return Auxiliary.FCheckSelectMixRepEx(xct,tp,mg,sg,g,...)
	end
end
function Auxiliary.FCheckMixRepTemplateEx(c,cond,xct,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,...)
	--Debug.Message(tostring(3).." "..tostring(c:GetCode()))
	local xchk=false
	for i,f in ipairs({...}) do
		if #extramats>0 then
			for j,exg in ipairs(extramats) do
				--Debug.Message('extramat')
				if exg:IsContains(c) then
					if extramats_only and extramats_only[j]:IsContains(c) then
						xchk=true
					end
					if extrafuns[j](c,tp,fc,sub,mg,sg,true) and (not xct[j] or xct[j]<extramaxs[j]) then
						if not xct[j] then
							xct[j]=0
						end
						xct[j]=xct[j]+1
						g:AddCard(c)
						local sub=sub and f(c,fc,false,mg,sg)
						local t={...}
						table.remove(t,i)
						local res=cond(xct,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,table.unpack(t))
						g:RemoveCard(c)
						if res then
							return true
						else
							xct[j]=xct[j]-1
						end
					end
				end
			end
		end
		if not xchk and f(c,fc,sub,mg,sg) then
			--Debug.Message('dots')
			g:AddCard(c)
			local sub=sub and f(c,fc,false,mg,sg)
			local t={...}
			table.remove(t,i)
			local res=cond(xct,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,table.unpack(t))
			g:RemoveCard(c)
			if res then return true end
		end
	end
	if maxc>0 then
		if #extramats>0 then
			for i,exg in ipairs(extramats) do
				--Debug.Message('extramat_maxc')
				if exg:IsContains(c) then
					if extramats_only and extramats_only[i]:IsContains(c) then
						xchk=true
					end
					if extrafuns[i](c,tp,fc,sub,mg,sg,true) and (not xct[i] or xct[i]<extramaxs[i]) then
						if not xct[i] then
							xct[i]=0
						end
						xct[i]=xct[i]+1
						g:AddCard(c)
						local res=cond(xct,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc-1,maxc-1,extramats,extrafuns,extramaxs,extramats_only,...)
						g:RemoveCard(c)
						if res then
							return true
						else
							xct[i]=xct[i]-1
						end
					end
				end
			end
		end
		if not xchk and fun1(c,fc,sub,mg,sg) then
			--Debug.Message('function')
			g:AddCard(c)
			local sub=sub and fun1(c,fc,false,mg,sg)
			local res=cond(xct,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc-1,maxc-1,extramats,extrafuns,extramaxs,extramats_only,...)
			g:RemoveCard(c)
			if res then return true end
		end
	end
	return false
end
function Auxiliary.FCheckSelectMixRepEx(xct,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,...)
	local chkf=chkfnf&0xff
	if Auxiliary.FCheckAdditional and not Auxiliary.FCheckAdditional(tp,g,fc) then return false end
	if Auxiliary.FGoalCheckGlitchy and not Auxiliary.FGoalCheckGlitchy(tp,sg,fc,sub,chkfnf) then return false end
	if chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,g,fc)>0 then
		--Debug.Message(tostring(41).." "..tostring(minc).." "..tostring(#{...}).." "..tostring(Auxiliary.FCheckMixRepGoalCheck(tp,g,fc,chkfnf)))
		if minc<=0 and #{...}==0 and Auxiliary.FCheckMixRepGoalCheck(tp,g,fc,chkfnf) then return true end
		return mg:IsExists(Auxiliary.FCheckSelectMixRepAllEx,1,g,xct,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,...)
	else
		--Debug.Message(42)
		return mg:IsExists(Auxiliary.FCheckSelectMixRepMEx,1,g,xct,tp,mg,sg,g,fc,sub,chkfnf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,...)
	end
end
function Auxiliary.FCheckSelectMixRepAllEx(c,xct,tp,mg,sg,g,fc,sub,chkf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,fun2,...)
	--Debug.Message(tostring(51).." "..tostring(c:GetCode()))
	local xchk=false
	if fun2 then
		if #extramats>0 then
			--Debug.Message('extramat 05')
			for i,exg in ipairs(extramats) do
				if exg:IsContains(c) then
					if extramats_only and extramats_only[i]:IsContains(c) then
						xchk=true
					end
					if extrafuns[i](c,tp,fc,sub,mg,sg,true) and (not xct[i] or xct[i]<extramaxs[i]) then
						if not xct[i] then
							xct[i]=0
						end
						xct[i]=xct[i]+1
						g:AddCard(c)
						local res=Auxiliary.FCheckSelectMixRepEx(xct,tp,mg,sg,g,fc,sub,chkf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,...)
						g:RemoveCard(c)
						if res then
							return true
						else
							xct[i]=xct[i]-1
						end
					end
				end
			end
		end
		if not xchk and fun2(c,fc,sub,mg,sg) then
			--Debug.Message('fun2 05')
			g:AddCard(c)
			local sub=sub and fun2(c,fc,false,mg,sg)
			local res=Auxiliary.FCheckSelectMixRepEx(xct,tp,mg,sg,g,fc,sub,chkf,fun1,minc,maxc,extramats,extrafuns,extramaxs,extramats_only,...)
			g:RemoveCard(c)
			return res
		end
	elseif maxc>0 then
		if #extramats>0 then
			--Debug.Message('extramat_maxc 05')
			for i,exg in ipairs(extramats) do
				if exg:IsContains(c) then
					if extramats_only and extramats_only[i]:IsContains(c) then
						xchk=true
					end
					if extrafuns[i](c,tp,fc,sub,mg,sg,true) and (not xct[i] or xct[i]<extramaxs[i]) then
						if not xct[i] then
							xct[i]=0
						end
						xct[i]=xct[i]+1
						g:AddCard(c)
						local res=Auxiliary.FCheckSelectMixRepEx(xct,tp,mg,sg,g,fc,sub,chkf,fun1,minc-1,maxc-1,extramats,extrafuns,extramaxs,extramats_only)
						g:RemoveCard(c)
						if res then
							return true
						else
							xct[i]=xct[i]-1
						end
					end
				end
			end
		end
		if not xchk and fun1(c,fc,sub,mg,sg) then
			--Debug.Message('fun1 05')
			g:AddCard(c)
			local sub=sub and fun1(c,fc,false,mg,sg)
			local res=Auxiliary.FCheckSelectMixRepEx(xct,tp,mg,sg,g,fc,sub,chkf,fun1,minc-1,maxc-1,extramats,extrafuns,extramaxs,extramats_only)
			g:RemoveCard(c)
			return res
		end
	end
	return false
end
function Auxiliary.FCheckSelectMixRepMEx(c,xct,tp,...)
	--Debug.Message(52)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and Auxiliary.FCheckMixRepTemplateEx(c,Auxiliary.FCheckSelectMixRepEx,xct,tp,...)
end

Duel.SendtoGrave = function(tg,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _SendtoGrave(tg,reason)
	end
	local rg=tg:Filter(Card.IsHasEffect,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	tg:Sub(rg)
	local opt=0
	
	local ct1=_SendtoGrave(tg,reason)
	local ct2=0
	
	while #rg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(rg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel then
				extra_g:AddCard(tc)
				local fusop=ce:GetOperation()
				if not extra_op and fusop then
					extra_op=fusop
				end
			end
		end
		if #extra_g>0 then
			rg:Sub(extra_g)
			local op = extra_op and extra_op or _SendtoGrave
			local extra_ct=op(extra_g,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			ct2=ct2+extra_ct
		end
	end
	return ct1+ct2
end
Duel.Remove = function(tg,pos,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _Remove(tg,pos,reason)
	end
	local rg=tg:Filter(Card.IsHasEffect,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	tg:Sub(rg)
	local opt=0
	local ct1=_Remove(tg,pos,reason)
	local ct2=0
	while #rg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(rg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			rg:Sub(extra_g)
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
	end
	return ct1+ct2
end
Duel.SendtoDeck = function(tg,p,seq,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _SendtoDeck(tg,p,seq,reason)
	end
	local rg=tg:Filter(Card.IsHasEffect,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	tg:Sub(rg)
	local opt=0
	local ct1=_SendtoDeck(tg,p,seq,reason)
	local ct2=0

	while #rg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(rg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			rg:Sub(extra_g)
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
	end
	return ct1+ct2
end
Duel.Destroy = function(tg,reason,...)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _Destroy(tg,reason,...)
	end
	local rg=tg:Filter(Card.IsHasEffect,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	tg:Sub(rg)
	local opt=0
	local ct1=_Destroy(tg,reason,...)
	local ct2=0
	
	while #rg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(rg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			rg:Sub(extra_g)
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
	local rg=tg:Filter(Card.IsHasEffect,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	tg:Sub(rg)
	local opt=0
	local ct1=_SendtoHand(tg,p,reason)
	local ct2=0
	while #rg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(rg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			rg:Sub(extra_g)
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
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
						if ce and ce.GetLabel then
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
