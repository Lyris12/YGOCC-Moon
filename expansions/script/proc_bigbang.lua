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
FLAG_BIGBANG_ATTACK				= 100000147
FLAG_BIGBANG_DEFENSE			= 100000148

STRING_DO_NOT_USE_BIGBANG_VIBE_EFFECT					= 717
STRING_POSITIVE_VIBE				  					= 718
STRING_NEGATIVE_VIBE									= 719
STRING_NEUTRAL_VIBE										= 720
STRING_DO_NOT_USE_BIGBANG_CUSTOM_MATERIAL_STATS_EFFECT	= 750

EFFECT_CANNOT_BE_BIGBANG_MATERIAL		=624
EFFECT_MUST_BE_BIGBANG_MATERIAL			=625
EFFECT_EXTRA_BIGBANG_MATERIAL			=626
EFFECT_IGNORE_BIGBANG_SUMREQ			=627
EFFECT_BASE_BIGBANG_ATTACK 				=628
EFFECT_BASE_BIGBANG_DEFENSE   			=629
EFFECT_UPDATE_BIGBANG_ATTACK			=630
EFFECT_UPDATE_BIGBANG_DEFENSE   		=631
EFFECT_EXTRA_BIGBANG_VIBE				=632
EFFECT_MATERIAL_CUSTOM_BIGBANG_STATS	=633

TYPE_BIGBANG						=0x8000000000
TYPE_CUSTOM							=TYPE_CUSTOM|TYPE_BIGBANG
TYPES_NO_LEVEL						=TYPES_NO_LEVEL|TYPE_BIGBANG
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
		elseif type(val)=="function" and val(te,ec) then
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
	
	local batk,bdef
	if c:HasFlagEffect(FLAG_BIGBANG_ATTACK) then
		batk=c:GetFlagEffectLabel(FLAG_BIGBANG_ATTACK)
	elseif c:HasAttack() then
		batk=c:GetAttack()
	end
	if c:HasFlagEffect(FLAG_BIGBANG_DEFENSE) then
		bdef=c:GetFlagEffectLabel(FLAG_BIGBANG_DEFENSE)
	elseif c:HasDefense() then
		bdef=c:GetDefense()
	end
	
	if not batk or not bdef then return end
	local stat=batk-bdef
	if stat==0 then
		return stat
	else
		return stat/math.abs(stat)
	end
end
function Card.IsPositive(c)
	local vb=c:GetVibe()
	if not vb then return false end
	return vb==1
end
function Card.IsNegative(c)
	local vb=c:GetVibe()
	if not vb then return false end
	return vb==-1
end
function Card.IsNeutral(c)
	local vb=c:GetVibe()
	if not vb then return false end
	return vb==0
end
function Card.IsNonNeutral(c)
	local vb=c:GetVibe()
	return not vb or vb~=0
end
function Card.HasVibe(c)
	return c:GetVibe()~=nil
end
function Card.HasNoVibe(c)
	return c:GetVibe()==nil
end
function Card.IsOppositeVibe(c1,c2)
	local vb1,vb2=c1:GetVibe(),c2:GetVibe()
	return vb1 and vb2 and vb1*vb2==-1
end

function Card.GetBigbangAttack(c,bc,mg)
	if c:HasFlagEffect(FLAG_BIGBANG_ATTACK) then
		return c:GetFlagEffectLabel(FLAG_BIGBANG_ATTACK)
	end
	local vibe=c:GetVibe()
	
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
	if c:HasFlagEffect(FLAG_BIGBANG_DEFENSE) then
		return c:GetFlagEffectLabel(FLAG_BIGBANG_DEFENSE)
	end
	local vibe=c:GetVibe()
	
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
function Card.HasNoBigbangStat(c)
	return (not c:HasAttack() and not c:HasFlagEffect(FLAG_BIGBANG_ATTACK)) or (not c:HasDefense() and not c:HasFlagEffect(FLAG_BIGBANG_DEFENSE))
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
	local min,max=0,0
	for i=1,#funs do
		min=min+funs[i][2]
		max=max+funs[i][3]
	end
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
				local res=mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,nil,tp,Group.CreateGroup(),mg,fg,c,gf,0,min,max,table.unpack(funs))
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
		if (not con or con(te1,c,tp,lc,1)) then ValidSubstitute=true end
	end
	if not ValidSubstitute then return false end
	if c:IsLocation(LOCATION_ONFIELD) and not c:IsFaceup() then return false end
	return c:IsCanBeBigbangMaterial(lc) and (not flist or #flist<=0 or check)
end
function Auxiliary.BigbangRecursiveFilter(c,tp,sg,mg,fg,bc,gf,ct,min,max,...)
	sg:AddCard(c)
	ct=ct+1
	
	local chk=false
	
	local funs={...}
	for i,ftab in ipairs(funs) do
		local f,fmax=ftab[1],ftab[3]
		if f(c,sg) then
			if sg:FilterCount(f,nil,sg)>fmax then
				for i2,ftab2 in ipairs(funs) do
					local f2,fmax2=ftab2[1],ftab2[3]
					if i2~=i and f2(c,sg) and sg:FilterCount(f2,nil,sg)<fmax2 then
						chk=true
					end
				end
			else
				chk=true
			end
			if chk then
				break
			end
		end
	end
	if not chk then sg:RemoveCard(c) ct=ct-1 return false end
	
	local res,resVibe=false,false
	
	local restorestep=false
	if aux.BigbangMaterialSelectionStep==true then
		aux.BigbangMaterialSelectionStep = false
		restorestep=true
	end
	
	local res=(ct>=min and Auxiliary.BigbangCheckGoal(tp,sg,fg,bc,gf,ct,...)) or (ct<=max and mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,sg,tp,sg,mg,fg,bc,gf,ct,min,max,...))
	
	if restorestep then
		aux.BigbangMaterialSelectionStep = true
	end
	
	--Check whether the Summon can be conducted with EFFECT_MATERIAL_CUSTOM_BIGBANG_ATTACK, and gather all usable instances
	if (chk and ct>=min and not res) or aux.BigbangMaterialSelectionStep then
		local eset={bc:IsHasEffect(EFFECT_MATERIAL_CUSTOM_BIGBANG_STATS)}
		for _,e in ipairs(eset) do
			local mcmax=e:GetLabel()
			if mcmax>0 then
				local tg=e:GetTarget()
				if not tg or tg(e,c,bc,mg,tp) then
					e:SetLabel(mcmax-1)
					local val=e:GetValue()
					if val then
						local mcatk,mcdef=val(e,c,bc,mg,tp)
						
						if mcatk then
							c:RegisterFlagEffect(FLAG_BIGBANG_ATTACK,0,0,1,mcatk)
						end
						if mcdef then
							c:RegisterFlagEffect(FLAG_BIGBANG_DEFENSE,0,0,1,mcdef)
						end
						if not aux.BigbangMaterialSelectionStep then
							res = (Auxiliary.BigbangCheckGoal(tp,sg,fg,bc,gf,ct,...) or (ct<max and mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,sg,tp,sg,mg,fg,bc,gf,ct,min,max,...)))
							if res then
								e:SetLabel(mcmax)
								c:ResetFlagEffect(FLAG_BIGBANG_ATTACK)
								c:ResetFlagEffect(FLAG_BIGBANG_DEFENSE)
								break
							end
						
						else
							aux.BigbangMaterialSelectionStep = false
							if (Auxiliary.BigbangCheckGoal(tp,sg,fg,bc,gf,ct,...) or (ct<max and mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,sg,tp,sg,mg,fg,bc,gf,ct,min,max,...))) then
								if not aux.BigbangCustomMaterialStatEffects[c] then
									aux.BigbangCustomMaterialStatEffects[c]={}
								end
								aux.BigbangDoesNotNeedCustomMaterialStat[c] = res
								table.insert(aux.BigbangCustomMaterialStatEffects[c],e)
								res=true
							end
							aux.BigbangMaterialSelectionStep = true
						end
					end
					e:SetLabel(mcmax)
					c:ResetFlagEffect(FLAG_BIGBANG_ATTACK)
					c:ResetFlagEffect(FLAG_BIGBANG_DEFENSE)
				end
			end
		end
	end
	
	--Check whether the Summon can be conducted with EFFECT_EXTRA_BIGBANG_VIBE, and gather all usable instances
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
									resVibe = (Auxiliary.BigbangCheckGoal(tp,sg,fg,bc,gf,ct,...) or (ct<max and mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,sg,tp,sg,mg,fg,bc,gf,ct,min,max,...)))
									if resVibe then
										c:ResetFlagEffect(FLAG_BIGBANG_VIBE)
										BreakWhile=true
										break
									end
								
								else
									aux.BigbangMaterialSelectionStep = false
									local BreakFor=false
									if (Auxiliary.BigbangCheckGoal(tp,sg,fg,bc,gf,ct,...) or (ct<max and mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,sg,tp,sg,mg,fg,bc,gf,ct,min,max,...))) then
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
	
	local max=0
	local funs={...}
	for i,ftab in ipairs(funs) do
		local f,fmin,fmax=ftab[1],ftab[2],ftab[3]
		if sg:FilterCount(f,nil,sg)<fmin then
			return false
		end
		max=max+fmax
	end
	if #sg>max then return false end
	
	local bigbang_stats_res = false
	if bc:IsHasEffect(EFFECT_IGNORE_BIGBANG_SUMREQ) then
		bigbang_stats_res = true
	else
		bigbang_stats_res = not sg:IsExists(Card.HasNoVibe,1,nil) and not sg:IsExists(Card.HasNoBigbangStat,1,nil)
		and sg:CheckWithSumGreater(Card.GetBigbangAttack,bc:GetAttack(),bc,sg) and sg:CheckWithSumGreater(Card.GetBigbangDefense,bc:GetDefense(),bc,sg)
	end
	
	--LEAVE THIS FOR DEBUGGING PURPOSES IN CASE A BIGBANG MONSTER IS NOT BEING ABLE TO BE SUMMONED
	-- if bc:IsCode(100000146,true) then
		-- Debug.Message(Duel.GetLocationCountFromEx(tp,tp,sg,bc)>0)
		-- Debug.Message(not gf or gf(sg,bc,tp))
		-- Debug.Message(tostring(sg:CheckWithSumGreater(Card.GetBigbangAttack,bc:GetAttack(),bc,sg))..": "..tostring(bc:GetAttack()))
		-- Debug.Message(tostring(sg:CheckWithSumGreater(Card.GetBigbangAttack,bc:GetDefense(),bc,sg))..": "..tostring(bc:GetDefense()))
		-- Debug.Message(not sg:IsExists(Auxiliary.BigbangUncompatibilityFilter,1,nil,sg,bc,tp))
		-- local atk,def=0,0
		-- for tc in aux.Next(sg) do
			-- Debug.Message(tostring(tc:GetCode())..": "..tostring(tc:GetBigbangAttack(bc,sg)).."|"..tostring(tc:GetBigbangDefense(bc,sg)))
			-- atk=atk+tc:GetBigbangAttack(bc,sg)
			-- def=def+tc:GetBigbangDefense(bc,sg)
		-- end
		-- Debug.Message("ATK: "..tostring(atk))
		-- Debug.Message("DEF: "..tostring(def))
		-- Debug.Message("--------------------------")
	-- end
	
	return Duel.GetLocationCountFromEx(tp,tp,sg,bc)>0 and (not gf or gf(sg,bc,tp))
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
	local funs={...}
	local min,max=0,0
	for i=1,#funs do
		min=min+funs[i][2]
		max=max+funs[i][3]
	end
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
				aux.BigbangCustomMaterialStatEffects = {}
				aux.BigbangDoesNotNeedCustomMaterialStat = {}
				aux.BigbangCustomMaterialStatMax = {}
				aux.BigbangCustomMaterialStatOperations = {}
				aux.BigbangExtraVibeEffects = {}
				aux.BigbangDoesNotNeedExtraVibe = {}
				local finish=false
				while #sg<max do
					finish=Auxiliary.BigbangCheckGoal(tp,sg,fg,c,gf,#sg,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.BigbangRecursiveFilter,sg,tp,sg,mg,fg,c,gf,#sg,min,max,table.unpack(funs))
					if #cg==0 then break end
					local cancel=Duel.IsSummonCancelable() and not finish
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
					local tc=cg:SelectUnselect(sg,tp,finish,cancel,min,max)
					if not tc then
						break
					end
				
					if not sg:IsContains(tc) then
						if aux.BigbangCustomMaterialStatEffects[tc] then
							local Descriptions={}
							local opt=1
							if aux.BigbangDoesNotNeedCustomMaterialStat[tc]==true then
								table.insert(Descriptions,STRING_DO_NOT_USE_BIGBANG_CUSTOM_MATERIAL_STATS_EFFECT)
								opt=0
							end
							
							local map={}
							for i,effect in ipairs(aux.BigbangCustomMaterialStatEffects[tc]) do
								if effect:GetLabel()>0 then
									table.insert(map,i)
									table.insert(Descriptions,effect:GetDescription())
								end
							end
							opt = opt + Duel.SelectOption(tp,table.unpack(Descriptions))
							if opt>0 then
								local tab=aux.BigbangCustomMaterialStatEffects[tc]
								local effect=tab[map[opt]]
								
								if not aux.BigbangCustomMaterialStatMax[tc] then
									aux.BigbangCustomMaterialStatMax[tc]={}
								end
								if not aux.BigbangCustomMaterialStatMax[tc][effect] then
									aux.BigbangCustomMaterialStatMax[tc][effect]=0
								end
								aux.BigbangCustomMaterialStatMax[tc][effect]=aux.BigbangCustomMaterialStatMax[tc][effect]+1
								effect:SetLabel(effect:GetLabel()-1)
								
								local val=effect:GetValue()
								local mcatk,mcdef=val(effect,tc,bc,mg,tp)
								
								if mcatk then
									tc:RegisterFlagEffect(FLAG_BIGBANG_ATTACK,0,0,1,mcatk)
								end
								if mcdef then
									tc:RegisterFlagEffect(FLAG_BIGBANG_DEFENSE,0,0,1,mcdef)
								end
								
								local op=effect:GetOperation()
								if op then
									if not aux.BigbangCustomMaterialStatOperations[tc] then
										aux.BigbangCustomMaterialStatOperations[tc] = {}
									end
									aux.BigbangCustomMaterialStatOperations[tc][effect] = op
								end
							end
						end
						
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
						if aux.BigbangCustomMaterialStatMax[tc] then
							for effect,restore in pairs(aux.BigbangCustomMaterialStatMax[tc]) do
								effect:SetLabel(effect:GetLabel()+restore)
							end
						end
						tc:ResetFlagEffect(FLAG_BIGBANG_ATTACK)
						tc:ResetFlagEffect(FLAG_BIGBANG_DEFENSE)
						tc:ResetFlagEffect(FLAG_BIGBANG_VIBE)
						if aux.BigbangCustomMaterialStatOperations[tc] then
							aux.BigbangCustomMaterialStatOperations[tc] = {}
						end
					end
					
					aux.BigbangCustomMaterialStatEffects = {}
					aux.BigbangDoesNotNeedCustomMaterialStat = {}
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
				aux.BigbangCustomMaterialStatEffects = {}
				aux.BigbangDoesNotNeedCustomMaterialStat = {}
				aux.BigbangExtraVibeEffects = {}
				aux.BigbangDoesNotNeedExtraVibe = {}
				for tc in aux.Next(sg) do
					if aux.BigbangCustomMaterialStatMax[tc] then
						for effect,restore in pairs(aux.BigbangCustomMaterialStatMax[tc]) do
							effect:SetLabel(effect:GetLabel()+restore)
						end
					end
					tc:ResetFlagEffect(FLAG_BIGBANG_ATTACK)
					tc:ResetFlagEffect(FLAG_BIGBANG_DEFENSE)
					tc:ResetFlagEffect(FLAG_BIGBANG_VIBE)
				end
				aux.BigbangCustomMaterialStatMax = {}
				
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
					op(tc,tp,dg)
				else
					dg:AddCard(tc)
				end
			end
		end
		
		if aux.BigbangCustomMaterialStatOperations[tc] then
			for tef,op in pairs(aux.BigbangCustomMaterialStatOperations[tc]) do
				if op then
					op(tef,tc,tp,dg)
				end
			end
		end
	end
	aux.BigbangCustomMaterialStatOperations = {}
	if #dg>0 then
		Duel.Destroy(dg,REASON_RULE+REASON_MATERIAL+REASON_BIGBANG+REASON_REPLACE)
	end
	g:DeleteGroup()
end
