--created by Meedogh, coded by Lyris
--Not yet finalized values

bigbang_limit_mats_operation = nil
bigbang_force_mats_operation = nil

--Custom constants
VIBE_POSITIVE = 0x1
VIBE_NEGATIVE = 0x2
VIBE_NEUTRAL  = 0x4
VIBE_ALL	  = 0x7

FLAG_BIGBANG_VIBE 				= 11110642

STRING_DO_NOT_USE_BIGBANG_VIBE_EFFECT	= 717
STRING_POSITIVE_VIBE				  	= 718
STRING_NEGATIVE_VIBE					= 719
STRING_NEUTRAL_VIBE						= 720

EFFECT_CANNOT_BE_BIGBANG_MATERIAL	=624
EFFECT_MUST_BE_BIGBANG_MATERIAL		=625
EFFECT_EXTRA_BIGBANG_MATERIAL		=626
EFFECT_IGNORE_BIGBANG_SUMREQ		=627
EFFECT_BASE_BIGBANG_ATTACK 			=628
EFFECT_BASE_BIGBANG_DEFENSE   		=629
EFFECT_UPDATE_BIGBANG_ATTACK		=630
EFFECT_UPDATE_BIGBANG_DEFENSE   	=631
EFFECT_EXTRA_BIGBANG_VIBE			=632

TYPE_BIGBANG						=0x8000000000
TYPE_CUSTOM							=TYPE_CUSTOM|TYPE_BIGBANG
CTYPE_BIGBANG						=0x80
CTYPE_CUSTOM						=CTYPE_CUSTOM|CTYPE_BIGBANG

SUMMON_TYPE_BIGBANG					=SUMMON_TYPE_SPECIAL+340

REASON_BIGBANG						=0x8000000000

--Custom Type Table
Auxiliary.Bigbangs={} --number as index = card, card as index = function() is_synchro
table.insert(aux.CannotBeEDMatCodes,EFFECT_CANNOT_BE_BIGBANG_MATERIAL)

--overwrite constants
TYPE_EXTRA							=TYPE_EXTRA|TYPE_BIGBANG

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_reason, get_fusion_type, get_synchro_type, get_xyz_type, get_link_type, get_ritual_type =
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetReason, Card.GetFusionType, Card.GetSynchroType, Card.GetXyzType, Card.GetLinkType, Card.GetRitualType

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Bigbangs[c] then
		tpe=tpe|TYPE_BIGBANG
		if not Auxiliary.Bigbangs[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Bigbangs[c] then
		tpe=tpe|TYPE_BIGBANG
		if not Auxiliary.Bigbangs[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Bigbangs[c] then
		tpe=tpe|TYPE_BIGBANG
		if not Auxiliary.Bigbangs[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetReason=function(c)
	local rs=get_reason(c)
	local rc=c:GetReasonCard()
	if rc and Auxiliary.Bigbangs[rc] then
		rs=rs|REASON_BIGBANG
	end
	return rs
end
Card.GetFusionType=function(c)
	local tpe=get_fusion_type(c)
	if Auxiliary.Bigbangs[c] then
		tpe=tpe|TYPE_BIGBANG
		if not Auxiliary.Bigbangs[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetSynchroType=function(c)
	local tpe=get_synchro_type(c)
	if Auxiliary.Bigbangs[c] then
		tpe=tpe|TYPE_BIGBANG
		if not Auxiliary.Bigbangs[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetXyzType=function(c)
	local tpe=get_xyz_type(c)
	if Auxiliary.Bigbangs[c] then
		tpe=tpe|TYPE_BIGBANG
		if not Auxiliary.Bigbangs[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetLinkType=function(c)
	local tpe=get_link_type(c)
	if Auxiliary.Bigbangs[c] then
		tpe=tpe|TYPE_BIGBANG
		if not Auxiliary.Bigbangs[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetRitualType=function(c)
	local res=get_ritual_type(c)
	if Auxiliary.Bigbangs[c] then
		tpe=tpe|TYPE_BIGBANG
		if not Auxiliary.Bigbangs[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end

--Custom Functions
function Card.IsCanBeBigbangMaterial(c,ec)
	--if c:IsType(TYPE_LINK) and not c:IsHasEffect(EFFECT_EXTRA_BIGBANG_VIBE) then return false end
	if c:IsOnField() and not c:IsFaceup() then return false end
	if c:IsHasEffect(EFFECT_INDESTRUCTABLE) then return false end
	local tef={c:IsHasEffect(EFFECT_CANNOT_BE_BIGBANG_MATERIAL)}
	for _,te in ipairs(tef) do
		local val=te:GetValue()
		if type(val)=="nil" or type(val)=="number" then
			return false
		elseif type(val)=="function" and val(te,c) then
			return false
		end 
	end
	return true
end
function Card.GetVibe(c)
	---1 = Negative; +0 = Neutral; +1 = Positive
	if c:HasFlagEffect(FLAG_BIGBANG_VIBE) then
		local val=c:GetFlagEffectLabel(FLAG_BIGBANG_VIBE)
		if val==2 then
			return -1
		else
			return val
		end
	end
	
	if not c:IsDefenseAbove(0) then return nil end
	local stat=c:GetAttack()-c:GetDefense()
	if stat==0 then
		return stat
	else
		return stat/math.abs(stat)
	end
end
function Card.IsPositive(c)
	return c:GetVibe()==1
end
function Card.IsNegative(c)
	return c:GetVibe()==-1
end
function Card.IsNeutral(c)
	return c:GetVibe()==0
end
function Card.HasVibe(c)
	return c:GetVibe()
end
function Card.HasNoVibe(c)
	return not c:GetVibe()
end

function Card.GetBigbangAttack(c,bc,mg)
	local vibe=c:GetVibe()
	if c:HasFlagEffect(FLAG_BIGBANG_VIBE) then
		local val=c:GetFlagEffectLabel(FLAG_BIGBANG_VIBE)
		if val==2 then
			vibe=-1
		else
			vibe=val
		end
	end
	
	local val=c:GetAttack()
	local extraval_base=0
	local te=c:IsHasEffect(EFFECT_BASE_BIGBANG_ATTACK)
	if te then
		local tg=te:GetTarget()
		if not tg or tg(te,c,bc,mg) then 
			local nval=te:GetValue()
			if type(nval)=='number' then
				val=nval
			else
				local tempval,count_neutral=nval(te,c,bc,mg)
				if vibe==0 and count_neutral then
					extraval_base=tempval
				else
					val=tempval
				end
			end
		end
	end
	
	local extraval_update=0
	if c:IsHasEffect(EFFECT_UPDATE_BIGBANG_ATTACK) then
		local tef={c:IsHasEffect(EFFECT_UPDATE_BIGBANG_ATTACK)}
		for _,upe in ipairs(tef) do
			local nval = upe:GetValue()
			if type(nval)=='number' then
				val=val+nval
			else
				local tempval,count_neutral=nval(upe,c,bc,mg)
				if vibe==0 and count_neutral then
					extraval_update=extraval_update+ tempval
				else
					val=val+tempval
				end
			end
		end
	end
	return val*math.abs(vibe) + extraval_base + extraval_update
end
function Card.GetBigbangDefense(c,bc,mg)
	local vibe=c:GetVibe()
	if c:HasFlagEffect(FLAG_BIGBANG_VIBE) then
		local val=c:GetFlagEffectLabel(FLAG_BIGBANG_VIBE)
		if val==2 then
			vibe=-1
		else
			vibe=val
		end
	end
	
	local val=c:GetDefense()
	local extraval_base=0
	local te=c:IsHasEffect(EFFECT_BASE_BIGBANG_DEFENSE)
	if te then
		local tg=te:GetTarget()
		if not tg or tg(te,c,bc,mg) then 
			local nval=te:GetValue()
			if type(nval)=='number' then
				val=nval
			else
				local tempval,count_neutral=nval(te,c,bc,mg)
				if vibe==0 and count_neutral then
					extraval_base=tempval
					
				else
					val=tempval
				end
			end
		end
	end
	
	local extraval_update=0
	if c:IsHasEffect(EFFECT_UPDATE_BIGBANG_DEFENSE) then
		local tef={c:IsHasEffect(EFFECT_UPDATE_BIGBANG_DEFENSE)}
		for _,upe in ipairs(tef) do
			local nval = upe:GetValue()
			if type(nval)=='number'
				then val=val+nval
			else
				local tempval,count_neutral=nval(upe,c,bc,mg)
				if vibe==0 and count_neutral then
					extraval_update=extraval_update+ tempval
				else
					val=val+tempval
				end
			end
		end
	end
	
	return val*math.abs(vibe) + extraval_base + extraval_update
end
function Auxiliary.AddOrigBigbangType(c,issynchro)
	table.insert(Auxiliary.Bigbangs,c)
	Auxiliary.Customs[c]=true
	local issynchro=issynchro==nil and false or issynchro
	Auxiliary.Bigbangs[c]=function() return issynchro end
end
function Auxiliary.AddBigbangProc(c,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local t={...}
	local list={}
	local min,max
	local gf
	local ignore_sumreq=false
	
	local ignore_sumreq_chk,gf_chk=false,false
	while type(t[#t])~="number" do 
		if not ignore_sumreq_chk and type(t[#t])=="boolean" then
			ignore_sumreq=t[#t]
			ignore_sumreq_chk=true
		elseif not gf_chk and type(t[#t])=="function" then
			gf=t[#t]
			gf_chk=true
		end
		table.remove(t)
	end
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
	ge2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ge2:SetRange(LOCATION_EXTRA)
	ge2:SetCondition(Auxiliary.BigbangCondition(gf,ignore_sumreq,table.unpack(list)))
	ge2:SetTarget(Auxiliary.BigbangTarget(gf,ignore_sumreq,table.unpack(list)))
	ge2:SetOperation(Auxiliary.BigbangOperation)
	ge2:SetValue(340)
	c:RegisterEffect(ge2)
	return ge2
end
function Auxiliary.BigbangCondition(gf,ignore_sumreq,...)
	local funs={...}
	return  function(e,c,matg,mustg)
				if c==nil then return true end
				if (c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_PANDEMONIUM)) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				
				local ignore_sumreq_effect
				if ignore_sumreq then
					ignore_sumreq_effect=Effect.CreateEffect(c)
					ignore_sumreq_effect:SetType(EFFECT_TYPE_SINGLE)
					ignore_sumreq_effect:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
					ignore_sumreq_effect:SetCode(EFFECT_IGNORE_BIGBANG_SUMREQ)
					c:RegisterEffect(ignore_sumreq_effect)
				end
				
				if bigbang_limit_mats_condition and bigbang_limit_mats_condition.SetLabelObject then
					Duel.RegisterEffect(bigbang_limit_mats_condition,tp)
				end
				local bigbang_forced_mats_table={}
				if bigbang_force_mats_condition and bigbang_force_mats_condition.SetLabelObject then
					local forcedmat=bigbang_force_mats_condition:GetLabelObject()
					if forcedmat then
						if aux.GetValueType(forcedmat)=="Card" then
							forcedmat:RegisterEffect(bigbang_force_mats_condition)
						elseif aux.GetValueType(forcedmat)=="Group" then
							local already_registered_original=false
							for tc in aux.Next(forcedmat) do
								if already_registered_original then
									local clone=bigbang_force_mats_condition:Clone()
									tc:RegisterEffect(clone)
									table.insert(bigbang_forced_mats_table,clone)
								else
									tc:RegisterEffect(bigbang_force_mats_condition)
									already_registered_original=true
								end
							end
						end
					end
				end
				
				local mg,mg2
				if matg and aux.GetValueType(matg)=="Group" then
					mg=matg:Filter(Card.IsCanBeBigbangMaterial,nil,c)
					mg2=matg:Filter(Auxiliary.BigbangExtraFilter,nil,c,tp,table.unpack(funs))			
				else
					mg=Duel.GetMatchingGroup(Card.IsCanBeBigbangMaterial,tp,LOCATION_MZONE,0,nil,c)
					mg2=Duel.GetMatchingGroup(Auxiliary.BigbangExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				end
				if #mg2>0 then mg:Merge(mg2) end
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_BIGBANG_MATERIAL)
				if mustg and aux.GetValueType(mustg)=="Group" then
					fg:Merge(mustg)
				end
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then
					--Debug.Message(c:GetCode().." error")
					-- for tc in aux.Next(fg) do
						-- Debug.Message(tc:GetCode())
					-- end
					if ignore_sumreq_effect then
						ignore_sumreq_effect:Reset()
						ignore_sumreq_effect=nil
					end
					if bigbang_limit_mats_condition and bigbang_limit_mats_condition.SetLabelObject then
						bigbang_limit_mats_condition:Reset()
						bigbang_limit_mats_condition=nil
					end
					if bigbang_force_mats_condition and bigbang_force_mats_condition.SetLabelObject then
						bigbang_force_mats_condition:Reset()
						bigbang_force_mats_condition=nil
						for _,clone in ipairs(bigbang_forced_mats_table) do
							if aux.GetValueType(clone)=="Effect" then clone:Reset() end
						end
					end
					return false
				end
				--Duel.SetSelectedCard(fg)
				local res=mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,nil,tp,Group.CreateGroup(),mg,fg,c,gf,0,table.unpack(funs))
				if ignore_sumreq_effect then
					ignore_sumreq_effect:Reset()
					ignore_sumreq_effect=nil
				end
				if bigbang_limit_mats_condition and bigbang_limit_mats_condition.SetLabelObject then
					bigbang_limit_mats_condition:Reset()
					bigbang_limit_mats_condition=nil
				end
				if bigbang_force_mats_condition and bigbang_force_mats_condition.SetLabelObject then
					bigbang_force_mats_condition:Reset()
					bigbang_force_mats_condition=nil
					for _,clone in ipairs(bigbang_forced_mats_table) do
						if aux.GetValueType(clone)=="Effect" then clone:Reset() end
					end
				end
				return res
			end
end
function Auxiliary.BigbangExtraFilter(c,lc,tp,...)
	local flist={...}
	local check=false
	for i=1,#flist do
		if flist[i][1](c,nil) then
			check=true
		end
	end
	local tef1={c:IsHasEffect(EFFECT_EXTRA_BIGBANG_MATERIAL,tp)}
	local ValidSubstitute=false
	for _,te1 in ipairs(tef1) do
		local con=te1:GetCondition()
		if (not con or con(c,lc,1)) then ValidSubstitute=true end
	end
	if not ValidSubstitute then return false end
	if c:IsLocation(LOCATION_ONFIELD) and not c:IsFaceup() then return false end
	return c:IsCanBeBigbangMaterial(lc) and (not flist or #flist<=0 or check)
end
function Auxiliary.BigbangRecursiveFilter(c,tp,sg,mg,fg,bc,gf,ct,...)
	sg:AddCard(c)
	ct=ct+1
	local funs,max,chk={...},0,false
	for i=1,#funs do
		max=max+funs[i][3]
		if funs[i][1](c,sg) then
			chk=true
		end
	end
	if max>99 then max=99 end
	
	local res,resVibe=false,false
	
	local restorestep=false
	if aux.BigbangMaterialSelectionStep==true then
		aux.BigbangMaterialSelectionStep = false
		restorestep=true
	end
	res = (chk and (Auxiliary.BigbangCheckGoal(tp,sg,fg,bc,gf,ct,...) or (ct<max and mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,sg,tp,sg,mg,fg,bc,gf,ct,...))))
	if restorestep then
		aux.BigbangMaterialSelectionStep = true
	end
	
	if not res or aux.BigbangMaterialSelectionStep then
		local eset={c:IsHasEffect(EFFECT_EXTRA_BIGBANG_VIBE)}
		for _,e in ipairs(eset) do
			local val=e:GetValue()
			if val then
				local LegalVibes=0
				local CheckingVibe=1
				while CheckingVibe<=VIBE_ALL do
					if val&CheckingVibe~=0 then
						local VibeFlag = CheckingVibe==VIBE_POSITIVE and 1 or CheckingVibe==VIBE_NEGATIVE and 2 or 0
						c:RegisterFlagEffect(FLAG_BIGBANG_VIBE,0,0,1,VibeFlag)
						local BreakWhile = false
						for i=1,#funs do
							if funs[i][1](c,sg) then
								if not aux.BigbangMaterialSelectionStep then
									resVibe = (Auxiliary.BigbangCheckGoal(tp,sg,fg,bc,gf,ct,...) or (ct<max and mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,sg,tp,sg,mg,fg,bc,gf,ct,...)))
									if resVibe then
										c:ResetFlagEffect(FLAG_BIGBANG_VIBE)
										BreakWhile=true
										break
									end
								
								else
									aux.BigbangMaterialSelectionStep = false
									local BreakFor=false
									if (Auxiliary.BigbangCheckGoal(tp,sg,fg,bc,gf,ct,...) or (ct<max and mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,sg,tp,sg,mg,fg,bc,gf,ct,...))) then
										LegalVibes=LegalVibes|CheckingVibe
										BreakFor=true
									end
									aux.BigbangMaterialSelectionStep = true
									if BreakFor then
										break
									end
								end
							end
						end
						if BreakWhile then
							break
						end
						c:ResetFlagEffect(FLAG_BIGBANG_VIBE)
					end
					CheckingVibe = CheckingVibe<<1
					
				end
				if LegalVibes~=0 then
					if not aux.BigbangExtraVibeEffects[c] then
						aux.BigbangExtraVibeEffects[c]={}
					end
					aux.BigbangDoesNotNeedExtraVibe[c] = res
					table.insert(aux.BigbangExtraVibeEffects[c],{e,LegalVibes})
					resVibe=true
				end
			end
		end
	end
	
	sg:RemoveCard(c)
	ct=ct-1
	return res or resVibe
end
function Auxiliary.BigbangCheckGoal(tp,sg,fg,bc,gf,ct,...)
	if fg and fg:IsExists(aux.NOT(Card.IsContained),1,nil,sg) then return false end
	
	local funs,min={...},0
	for i=1,#funs do
		if not sg:IsExists(funs[i][1],funs[i][2],nil,sg) or sg:IsExists(funs[i][1],funs[i][3]+1,nil,sg) then return false end
		min=min+funs[i][2]
	end
	
	local bigbang_stats_res = false
	if bc:IsHasEffect(EFFECT_IGNORE_BIGBANG_SUMREQ) then
		bigbang_stats_res = true
	else
		bigbang_stats_res = not sg:IsExists(Card.HasNoVibe,1,nil)
		and sg:CheckWithSumGreater(Card.GetBigbangAttack,bc:GetAttack(),bc,sg) and sg:CheckWithSumGreater(Card.GetBigbangDefense,bc:GetDefense(),bc,sg)
	end
	
	--LEAVE THIS FOR DEBUGGING PURPOSES IN CASE A BIGBANG MONSTER IS NOT BEING ABLE TO BE SUMMONED
	-- if bc:IsCode(CODE_OF_THE_BUGGED_BIGBANG) then
		-- Debug.Message(ct>=min)
		-- Debug.Message(Duel.GetLocationCountFromEx(tp,tp,sg,bc)>0)
		-- Debug.Message(not gf or gf(sg,bc,tp))
		-- Debug.Message(tostring(sg:CheckWithSumGreater(Card.GetBigbangAttack,bc:GetAttack(),bc,sg))..": "..tostring(bc:GetAttack()))
		-- Debug.Message(tostring(sg:CheckWithSumGreater(Card.GetBigbangAttack,bc:GetDefense(),bc,sg))..": "..tostring(bc:GetDefense()))
		-- Debug.Message(not sg:IsExists(Auxiliary.BigbangUncompatibilityFilter,1,nil,sg,bc,tp))
		-- local atk,def=0,0
		-- for tc in aux.Next(sg) do
			-- Debug.Message(tc:GetCode())
			-- atk=atk+tc:GetBigbangAttack(bc,sg)
			-- def=def+tc:GetBigbangDefense(bc,sg)
		-- end
		-- Debug.Message("ATK: "..tostring(atk))
		-- Debug.Message("DEF: "..tostring(def))
		-- Debug.Message("--------------------------")
	-- end
	
	return ct>=min and Duel.GetLocationCountFromEx(tp,tp,sg,bc)>0 and (not gf or gf(sg,bc,tp))
		and bigbang_stats_res
		and not sg:IsExists(Auxiliary.BigbangUncompatibilityFilter,1,nil,sg,bc,tp)
end
function Auxiliary.BigbangUncompatibilityFilter(c,sg,lc,tp)
	local mg=sg:Filter(aux.TRUE,c)
	return not Auxiliary.BigbangCheckOtherMaterial(c,mg,lc,tp)
end
function Auxiliary.BigbangCheckOtherMaterial(c,mg,lc,tp)
	local le={c:IsHasEffect(EFFECT_EXTRA_BIGBANG_MATERIAL,tp)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		if f and type(f)=="function" and not f(te,lc,mg) then return false end
	end
	return true
end

Auxiliary.BigbangMaterialSelectionStep = false
function Auxiliary.BigbangTarget(gf,ignore_sumreq,...)
	local funs,min,max={...},0,0
	for i=1,#funs do min=min+funs[i][2] max=max+funs[i][3] end
	if max>99 then max=99 end
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				if bigbang_limit_mats_operation and bigbang_limit_mats_operation.SetLabelObject then
					Duel.RegisterEffect(bigbang_limit_mats_operation,tp)
				end
				local bigbang_forced_mats_table={}
				if bigbang_force_mats_operation and bigbang_force_mats_operation.SetLabelObject then
					local forcedmat=bigbang_force_mats_operation:GetLabelObject()
					if forcedmat then
						if aux.GetValueType(forcedmat)=="Card" then
							forcedmat:RegisterEffect(bigbang_force_mats_operation)
						elseif aux.GetValueType(forcedmat)=="Group" then
							local already_registered_original=false
							for tc in aux.Next(forcedmat) do
								if already_registered_original then
									local clone=bigbang_force_mats_operation:Clone()
									tc:RegisterEffect(clone)
									table.insert(bigbang_forced_mats_table,clone)
								else
									tc:RegisterEffect(bigbang_force_mats_operation)
									already_registered_original=true
								end
							end
						end
					end
				end
				
				local ignore_sumreq_effect
				if ignore_sumreq then
					ignore_sumreq_effect=Effect.CreateEffect(c)
					ignore_sumreq_effect:SetType(EFFECT_TYPE_SINGLE)
					ignore_sumreq_effect:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
					ignore_sumreq_effect:SetCode(EFFECT_IGNORE_BIGBANG_SUMREQ)
					c:RegisterEffect(ignore_sumreq_effect)
				end
				
				local mg=Duel.GetMatchingGroup(Card.IsCanBeBigbangMaterial,tp,LOCATION_MZONE,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.BigbangExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_BIGBANG_MATERIAL)
				
				local sg=Group.CreateGroup()
				aux.BigbangMaterialSelectionStep = true
				aux.BigbangExtraVibeEffects = {}
				aux.BigbangDoesNotNeedExtraVibe = {}
				local finish=false
				while #sg<max do
					finish=Auxiliary.BigbangCheckGoal(tp,sg,fg,c,gf,#sg,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.BigbangRecursiveFilter,sg,tp,sg,mg,fg,c,gf,#sg,table.unpack(funs))
					if #cg==0 then break end
					local cancel=Duel.IsSummonCancelable() and not finish
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
					local tc=cg:SelectUnselect(sg,tp,finish,cancel,min,max)
					if not tc then
						break
					end
				
					if not sg:IsContains(tc) then
						if aux.BigbangExtraVibeEffects[tc] then
							local Descriptions={}
							local opt=1
							if aux.BigbangDoesNotNeedExtraVibe[tc]==true then
								table.insert(Descriptions,STRING_DO_NOT_USE_BIGBANG_VIBE_EFFECT)
								opt=0
							end
							for _,tab in ipairs(aux.BigbangExtraVibeEffects[tc]) do
								local effect=tab[1]
								table.insert(Descriptions,effect:GetDescription())
							end
							opt = opt + Duel.SelectOption(tp,table.unpack(Descriptions))
							if opt>0 then
								local vibes,DoesNotNeedAltVibe=aux.BigbangExtraVibeEffects[tc][opt][2],aux.BigbangExtraVibeEffects[tc][opt][3]
								local b1=vibes&VIBE_POSITIVE>0
								local b2=vibes&VIBE_NEGATIVE>0
								local b3=vibes&VIBE_NEUTRAL>0
								local VibeOpt=aux.Option(tp,false,false,
									{b1,false,STRING_POSITIVE_VIBE},
									{b2,false,STRING_NEGATIVE_VIBE},
									{b3,false,STRING_NEUTRAL_VIBE}
								)
								local VibeFlag = VibeOpt==0 and 1 or VibeOpt==1 and 2 or 0
								tc:RegisterFlagEffect(FLAG_BIGBANG_VIBE,0,0,1,VibeFlag)
							end
						end
						sg:AddCard(tc)
						if #sg>=max then
							finish=true
						end
					else
						sg:RemoveCard(tc)
						tc:ResetFlagEffect(FLAG_BIGBANG_VIBE)
					end
					
					aux.BigbangExtraVibeEffects = {}
					aux.BigbangDoesNotNeedExtraVibe = {}
						
					-- elseif #bg>0 and #sg<=#bg then
						-- if bigbang_limit_mats_operation and bigbang_limit_mats_operation.SetLabelObject then
							-- bigbang_limit_mats_operation:Reset()
							-- bigbang_limit_mats_operation=nil
						-- end
						-- if bigbang_force_mats_operation and bigbang_force_mats_operation.SetLabelObject then
							-- bigbang_force_mats_operation:Reset()
							-- bigbang_force_mats_operation=nil
						-- end
						-- return false
					--end
				end
				aux.BigbangMaterialSelectionStep = false
				aux.BigbangExtraVibeEffects = {}
				aux.BigbangDoesNotNeedExtraVibe = {}
				for tc in aux.Next(sg) do
					tc:ResetFlagEffect(FLAG_BIGBANG_VIBE)
				end
				if finish then
					if ignore_sumreq_effect then
						ignore_sumreq_effect:Reset()
						ignore_sumreq_effect=nil
					end
					sg:KeepAlive()
					e:SetLabelObject(sg)
					if bigbang_limit_mats_operation and bigbang_limit_mats_operation.SetLabelObject then
						bigbang_limit_mats_operation:Reset()
						bigbang_limit_mats_operation=nil
					end
					if bigbang_force_mats_operation and bigbang_force_mats_operation.SetLabelObject then
						bigbang_force_mats_operation:Reset()
						bigbang_force_mats_operation=nil
						for _,clone in ipairs(bigbang_forced_mats_table) do
							if aux.GetValueType(clone)=="Effect" then clone:Reset() end
						end
					end
					return true
				else
					if ignore_sumreq_effect then
						ignore_sumreq_effect:Reset()
						ignore_sumreq_effect=nil
					end
					if bigbang_limit_mats_operation and bigbang_limit_mats_operation.SetLabelObject then
						bigbang_limit_mats_operation:Reset()
						bigbang_limit_mats_operation=nil
					end
					if bigbang_force_mats_operation and bigbang_force_mats_operation.SetLabelObject then
						bigbang_force_mats_operation:Reset()
						bigbang_force_mats_operation=nil
						for _,clone in ipairs(bigbang_forced_mats_table) do
							if aux.GetValueType(clone)=="Effect" then clone:Reset() end
						end
					end
					return false
				end
			end
end
function Auxiliary.BigbangOperation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	if Duel.SetSummonCancelable then Duel.SetSummonCancelable(true) end
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	local dg=Group.CreateGroup()
	for tc in aux.Next(g) do
		local tef={tc:IsHasEffect(EFFECT_EXTRA_BIGBANG_MATERIAL)}
		if #tef==0 then
			dg:AddCard(tc)
		else
			for i=1,#tef do
				local op=tef[i]:GetOperation()
				if op then
					op(tc,tp)
				else
					dg:AddCard(tc)
				end
			end
		end
	end
	if #dg>0 then
		Duel.Destroy(dg,REASON_RULE+REASON_MATERIAL+REASON_BIGBANG+REASON_REPLACE)
	end
	g:DeleteGroup()
end
