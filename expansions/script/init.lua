--Not yet finalized values
--Custom constants

self_reference_effect				= nil
current_triggering_player			= nil
current_reason_effect				= nil

EFFECT_DEFAULT_CALL					=31993443
EFFECT_EXTRA_GEMINI					=86433590
EFFECT_AVAILABLE_LMULTIPLE			=86433612
EFFECT_MULTIPLE_LMATERIAL			=86433613
EFFECT_RANDOM_TARGET				=39759371
EFFECT_CANNOT_BANISH				=1500
EFFECT_CANNOT_BANISH_AS_COST		=1501
EFFECT_CANNOT_ADD_TO_HAND			=1502
EFFECT_GRANT_LEVEL					=1503
EFFECT_REMEMBER_GRANTED_LEVEL		=1504
EFFECT_REMEMBER_XYZ_HOLDER			=1505
EFFECT_INDESTRUCTABLE_COST			=1506
EFFECT_EXTRA_XYZ_MATERIAL			=1507
EFFECT_ORIGINAL_LEVEL_RANK_DUALITY	=1509
EFFECT_CANNOT_APPLY					=221594332

TYPE_CUSTOM							=0
CTYPE_CUSTOM						=0

EVENT_XYZATTACH						=EVENT_CUSTOM+9966607

EFFECT_COUNT_SECOND_HOPT			=10000000

REASON_FAKE_FU_BANISH=0x10000000000
FLAG_FACEDOWN_BANISH=21932999
FLAG_FAKE_FU_BANISH=21933000

--Effect Aliases
-- EFFECT_MUST_BE_SYNCHRO_MATERIAL = EFFECT_MUST_BE_SMATERIAL
-- EFFECT_MUST_BE_LINK_MATERIAL = EFFECT_MUST_BE_LMATERIAL
-- EFFECT_MUST_BE_XYZ_MATERIAL = EFFECT_MUST_BE_XMATERIAL
-- EFFECT_MUST_BE_FUSION_MATERIAL = EFFECT_MUST_BE_FMATERIAL

--Custom Type Tables
Auxiliary.Customs={} --check if card uses custom type, indexing card
Auxiliary.CannotBeEDMatCodes = {}

--overwrite constants
TYPE_EXTRA						=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK
REASON_EXTRA					=REASON_FUSION+REASON_SYNCHRO+REASON_XYZ+REASON_LINK

--Custom Functions
function Card.IsCustomType(c,tpe,scard,sumtype,p)
	return (c:GetType(scard,sumtype,p)>>32)&tpe>0
end
function Card.IsPreviousCustomTypeOnField(c,tpe)
	local custpe=tpe>>32
	return (c:GetPreviousTypeOnField()>>32)&custpe>0
end
function Card.IsCustomReason(c,rs)
	return (c:GetReason()>>32)&rs>0
end
function Card.GetRitualType(c)
	if c:IsLocation(LOCATION_SZONE) and c:GetOriginalType()&TYPE_MONSTER>0 then
		return c:GetOriginalType()
	end
	return c:GetType()
end

dofile("expansions/script/glitchylib_names.lua") --Constants for the names of cards, archetypes, counters (both TCG/OCG and customs), and for in-game strings
dofile("expansions/script/glitchylib.lua") --Glitchy
dofile("expansions/script/glitchylib_new.lua") --Glitchy's New Functions
dofile("expansions/script/glitchylib_single.lua") --Glitchy's Single-Type Effects
dofile("expansions/script/glitchylib_field.lua") --Glitchy's Field-Type Effects
dofile("expansions/script/glitchylib_trigger.lua") --Glitchy's Trigger Effects
dofile("expansions/script/glitchylib_global.lua") --Glitchy's Global Effects
dofile("expansions/script/glitchylib_cond.lua") --Glitchy's Conditions
dofile("expansions/script/glitchylib_cost.lua") --Glitchy's Costs
dofile("expansions/script/glitchylib_tgop.lua") --Glitchy's Target+Operations (will be deprecated once all scripts that use these functions are updated)
dofile("expansions/script/glitchylib_activated.lua") --Glitchy's shortcuts for common activated effects
dofile("expansions/script/glitchylib_subgroup.lua") --Glitchy's shortcuts for subgroup selection and checking

dofile("expansions/script/proc_evolute.lua") --Evolutes				0 x 1 0000 0000
dofile("expansions/script/proc_pandemonium.lua") --Pandemoniums		0 x 2 0000 0000
dofile("expansions/script/proc_polarity.lua") --Polarities			0 x 4 0000 0000
dofile("expansions/script/proc_spatial.lua") --Spatials				0 x 8 0000 0000
dofile("expansions/script/proc_doublesided.lua") --Doublesided		0 x 10 0000 0000
dofile("expansions/script/proc_skill.lua") --Skills					0 x 20 0000 0000
dofile("expansions/script/proc_conjoin.lua") --Conjoints			0 x 40 0000 0000
dofile("expansions/script/proc_bigbang.lua") --Bigbangs				0 x 80 0000 0000
dofile("expansions/script/proc_timeleap.lua") --Time Leaps			0 x 100 0000 0000
dofile("expansions/script/proc_relay.lua") --Relays					0 x 200 0000 0000
dofile("expansions/script/proc_harmony.lua") --Harmonies			0 x 800 0000 0000
dofile("expansions/script/proc_accent.lua") --Accents				0 x 1000 0000 0000
dofile("expansions/script/proc_magick.lua") --Magick				0 x 8 0000 0000 0000
--dofile("expansions/script/proc_xros.lua") --Xroses				0 x 10 0000 0000 0000	(BREAKS TIMELEAP FUNCTIONS)
dofile("expansions/script/proc_evolve.lua") --Evolves				0 x 20 0000 0000 0000
dofile("expansions/script/proc_drive.lua") --Drive 					0 x 40 0000 0000 0000
dofile("expansions/script/muse_proc.lua") --"Muse"
dofile("expansions/script/proc_runic.lua") --Runic
dofile("expansions/script/tables.lua") --Special Tables
-- dofile("expansions/script/proc_bypath.lua") --Bypaths
-- dofile("expansions/script/proc_toxia.lua") --Toxias
-- dofile("expansions/script/proc_annotee.lua") --Annotees
-- dofile("expansions/script/proc_chroma.lua") --Chromas
-- dofile("expansions/script/proc_corona.lua") --Coronas
-- dofile("expansions/script/proc_perdition.lua") --Perditions
-- dofile("expansions/script/proc_impure.lua") --Impures

dofile("expansions/script/mods_ritual.lua") --Generic Ritual Procedure modifications
dofile("expansions/script/mods_fusion.lua") --Generic Fusion Procedure modifications
dofile("expansions/script/mods_xyz.lua") --Generic Fusion Procedure modifications
dofile("expansions/script/mods_pendulum.lua") --Generic Pendulum Procedure modifications
dofile("expansions/script/mods_link.lua") --Generic Link Procedure modifications
-- dofile("expansions/script/mods_archetype.lua") --SetCard modifcations for Custom Archetypes

--fix for Duel.IsSummonCancelable wrong return
local fix1=Effect.GlobalEffect()
fix1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
fix1:SetCode(EVENT_SUMMON)
fix1:SetOperation(aux.ResetSummonCancelable)
Duel.RegisterEffect(fix1,0)
local fix2=Effect.GlobalEffect()
fix2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
fix2:SetCode(EVENT_MSET)
fix2:SetOperation(aux.ResetSummonCancelable)
Duel.RegisterEffect(fix2,0)
local fix3=Effect.GlobalEffect()
fix3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
fix3:SetCode(EVENT_SPSUMMON)
fix3:SetOperation(aux.ResetSummonCancelable)
Duel.RegisterEffect(fix3,0)

Debug.ReloadFieldBegin=(function()
	local old=Debug.ReloadFieldBegin
	return function(...)
			old(...)
			local fix1=Effect.GlobalEffect()
			fix1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			fix1:SetCode(EVENT_SUMMON)
			fix1:SetOperation(aux.ResetSummonCancelable)
			Duel.RegisterEffect(fix1,0)
			local fix2=Effect.GlobalEffect()
			fix2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			fix2:SetCode(EVENT_MSET)
			fix2:SetOperation(aux.ResetSummonCancelable)
			Duel.RegisterEffect(fix2,0)
			local fix3=Effect.GlobalEffect()
			fix3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			fix3:SetCode(EVENT_SPSUMMON)
			fix3:SetOperation(aux.ResetSummonCancelable)
			Duel.RegisterEffect(fix3,0)
		end
	end
)()

function Auxiliary.ResetSummonCancelable()
	Duel.SetSummonCancelable(false)
end


--overwrite functions
local is_type, card_remcounter, duel_remcounter, effect_set_target_range, effect_set_reset, duel_select_target, duel_banish, card_check_remove_overlay_card, is_reason, duel_check_tribute, select_tribute,card_sethighlander,
	card_is_facedown, card_is_able_to_remove, card_is_able_to_remove_as_cost, card_is_able_to_hand, card_is_can_be_ssed, card_get_level, card_is_xyz_level, card_get_original_level, card_get_previous_level, card_is_level, card_is_level_below, card_is_level_above, card_is_destructable, card_get_syn_level, card_get_rit_level
	= 
	
	Card.IsType, Card.RemoveCounter, Duel.RemoveCounter, Effect.SetTargetRange, Effect.SetReset, Duel.SelectTarget, Duel.Remove, Card.CheckRemoveOverlayCard, Card.IsReason, Duel.CheckTribute, Duel.SelectTribute, Card.SetUniqueOnField,
	Card.IsFacedown, Card.IsAbleToRemove, Card.IsAbleToRemoveAsCost, Card.IsAbleToHand, Card.IsCanBeSpecialSummoned, Card.GetLevel, Card.IsXyzLevel, Card.GetOriginalLevel, Card.GetPreviousLevelOnField, Card.IsLevel, Card.IsLevelBelow, Card.IsLevelAbove, Card.IsDestructable, Card.GetSynchroLevel, Card.GetRitualLevel

Card.IsReason=function(c,rs)
	local cusrs=rs>>32
	local ors=rs&0xffffffff
	if c:GetReason()&ors>0 then return true end
	if cusrs<=0 then return false end
	return c:IsCustomReason(cusrs)
end
Card.IsType=function(c,tpe,scard,sumtype,p)
	local custpe=tpe>>32
	local otpe=tpe&0xffffffff
	
	--fix for changing type in deck
	if c:IsLocation(LOCATION_DECK) and c:IsHasEffect(EFFECT_ADD_TYPE) and not scard and not sumtype and not p then
		local egroup={c:IsHasEffect(EFFECT_ADD_TYPE)}
		local typ=0
		for _,ce in ipairs(egroup) do
			if typ&ce:GetValue()==0 then
				typ=typ|ce:GetValue()
			end
		end
		return typ&tpe>0
	end
	
	if (scard and c:GetType(scard,sumtype,p)&otpe>0) or (not scard and c:GetType()&otpe>0) then return true end
	if custpe<=0 then return false end
	return c:IsCustomType(custpe,scard,sumtype,p)
end
Card.IsRitualType=function(c,tpe)
	local custpe=tpe>>32
	local otpe=tpe&0xffffffff
	local stpe=c:GetRitualType()
	return stpe&otpe>0 or (stpe>>32)&custpe>0
end
Card.IsFusionType=function(c,tpe)
	local custpe=tpe>>32
	local otpe=tpe&0xffffffff
	local stpe=c:GetFusionType()
	return stpe&otpe>0 or (stpe>>32)&custpe>0
end
Card.IsSynchroType=function(c,tpe)
	local custpe=tpe>>32
	local otpe=tpe&0xffffffff
	local stpe=c:GetSynchroType()
	return stpe&otpe>0 or (stpe>>32)&custpe>0
end
Card.IsXyzType=function(c,tpe)
	local custpe=tpe>>32
	local otpe=tpe&0xffffffff
	local stpe=c:GetXyzType()
	return stpe&otpe>0 or (stpe>>32)&custpe>0
end
Card.IsLinkType=function(c,tpe)
	local custpe=tpe>>32
	local otpe=tpe&0xffffffff
	local stpe=c:GetLinkType()
	return stpe&otpe>0 or (stpe>>32)&custpe>0
end

Card.RemoveCounter=function(c,p,typ,ct,r)
	local n=c:GetCounter(typ)
	local res=card_remcounter(c,p,typ,ct,r)
	return res,n-c:GetCounter(typ)==ct
end
Duel.RemoveCounter=function(p,s,o,typ,ct,r,rp)
	if rp==nil or rp==PLAYER_NONE --[[2]] then
		return duel_remcounter(p,s,o,typ,ct,r)
	elseif rp==PLAYER_ALL --[[3]] then
		local n=Duel.GetCounter(p,s,o,typ)
		duel_remcounter(p,s,o,typ,ct,r)
		return n-Duel.GetCounter(p,s,o,typ)==ct,ct
	elseif rp==p then
		local n=Duel.GetCounter(p,s,0,typ)
		duel_remcounter(p,s,o,typ,ct,r)
		return n-Duel.GetCounter(p,s,0,typ)
	elseif rp==1-p then
		local n=Duel.GetCounter(p,0,o,typ)
		duel_remcounter(p,s,o,typ,ct,r)
		return n-Duel.GetCounter(p,0,o,typ)
	end
end
Auxiliary.kaiju_procs={}
global_target_range_effect_table={}
Effect.SetTargetRange=function(e,self,oppo)
	local table_oppo = oppo
	if type(oppo)==nil then
		table_oppo=false
	end
	global_target_range_effect_table[e]={self,table_oppo}
	if e:GetCode()==EFFECT_SPSUMMON_PROC or e:GetCode()==EFFECT_SPSUMMON_PROC_G then
		if oppo==1 then
			table.insert(Auxiliary.kaiju_procs,e)
		end
	end
	return effect_set_target_range(e,self,oppo)
end

global_reset_effect_table={}
Effect.SetReset=function(e,reset,rct)
	local rct=rct or 1
	global_reset_effect_table[e]={reset,rct}
	return effect_set_reset(e,reset,rct)
end

Duel.SelectTarget=function(actp,func,self,loc1,loc2,cmin,cmax,exc,...)
	local extras={...}
	if Duel.IsPlayerAffectedByEffect(actp,EFFECT_RANDOM_TARGET) then
		local rg=Duel.GetMatchingGroup(func,self,loc1,loc2,exc,table.unpack(extras))
		rg:KeepAlive()
		if rg:IsExists(Auxiliary.CheckPrevRandom,1,nil) then
			local resg=rg:Filter(Auxiliary.CheckPrevRandom,nil)
			for res in aux.Next(resg) do
				res:ResetFlagEffect(39759371)
			end
		end
		local rct=#rg
		local rlist={}
		local rlct=0
		for rnum=1,rct do
			table.insert(rlist,rnum)
			rlct=rlct+1
		end
		for tc in aux.Next(rg) do
			local rgd
			local loop1=0
			while loop1==0 do
				rgd=math.random(1,rlct)
				if rlist[rgd]~=nil then
					loop1=1
				end
			end
			tc:RegisterFlagEffect(39759371,0,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
			tc:SetFlagEffectLabel(39759371,rlist[rgd])
			rlist[rgd]=nil
		end
		local llist={}
		local llct=0
		for rnum2=1,rct do
			table.insert(llist,rnum2)
			llct=llct+1
		end
		for maxs=cmin,cmax do
			local rgd2
			local loop1=0
			while loop1==0 do
				rgd2=math.random(1,llct)
				if llist[rgd2]~=nil then
					loop1=1
				end
			end
			for fftc in aux.Next(rg) do
				if fftc:GetFlagEffectLabel(39759371)==llist[rgd2] then
					fftc:SetFlagEffectLabel(39759371,999)
					llist[rgd2]=nil
				end
			end
		end
		rg:DeleteGroup()
		return duel_select_target(actp,Auxiliary.RandomTargetFilter,self,loc1,loc2,cmin,cmax,exc,table.unpack(extras))
	else
		return duel_select_target(actp,func,self,loc1,loc2,cmin,cmax,exc,table.unpack(extras))
	end
end
Duel.Remove=function(cc,pos,r,...)
	local x={...}
	local checkp=#x>0 and x[1] or self_reference_effect and current_triggering_player or nil
	local cc=Group.CreateGroup()+cc
	local tg=cc:Clone()
	for c in aux.Next(tg) do
		if c:IsHasEffect(EFFECT_CANNOT_BANISH) then
			local ef={c:IsHasEffect(EFFECT_CANNOT_BANISH)}
			for _,te1 in ipairs(ef) do
				local cf=te1:GetValue()
				local typ=aux.GetValueType(cf)
				if not cf and r&REASON_EFFECT>0 then
					cc=cc-c
				elseif (typ=="number" and cf==pos) and r&REASON_EFFECT>0 then
					cc=cc-c
				elseif typ=="function" then
					local checkpos,func=cf()
					if (not checkpos or checkpos==pos) and (not func or func(c,self_reference_effect,r,checkp)) then
						return false
					end
				end
			end
		end
	end
	if pos&POS_FACEDOWN~=0 then
		for c in aux.Next(cc) do
			if c.fu_banish_forced then
				c:RegisterFlagEffect(FLAG_FACEDOWN_BANISH,RESET_EVENT+RESETS_STANDARD-RESET_REMOVE,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1)
			end
		end
	end
	return duel_banish(cc,pos,r,table.unpack(x))
end
Card.CheckRemoveOverlayCard=function(c,tp,ct,r)
	if Duel.IsPlayerAffectedByEffect(tp,25149863) and bit.band(r,REASON_COST)~=0 then
		Duel.RegisterFlagEffect(tp,25149863,0,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE,1)
		Duel.SetFlagEffectLabel(tp,25149863,ct)
	end
	return card_check_remove_overlay_card(c,tp,ct,r)
end

--THESE 2 FUNCTIONS BELOW NEED TO BE REMOVED OR MODIFIED SINCE THEY PREVENT CERTAIN EFFECTS AND INTERACTIONS FROM FUNCTIONING ALTOGETHER
--See: Dai Dance and EFFECT_SUMMON_PROC ; Ra Sphere Mode with Stormforth

-- Duel.CheckTribute=function(c,min,max,mg,p,zone)
	-- if not max then max=min end
	-- if not p then p=c:GetControler() end
	-- if not zone then zone=0x1f001f end
	-- local ef={Duel.IsPlayerAffectedByEffect(c:GetControler(),EFFECT_MUST_USE_MZONE)}
	-- for _,e in ipairs(ef) do
		-- local ev=e:GetValue()
		-- if type(ev)=='function' then zone=zone&ev(e) else zone=zone&ev end
	-- end
	-- zone=zone&(0x1f<<16*p)
	-- if zone>0x1f then zone=zone>>16 end
	-- return duel_check_tribute(c,min,max,mg,p,zone)
-- end
-- Duel.SelectTribute=function(sp,c,min,max,mg,p)
	-- if not p then p=c:GetControler() end
	-- local zone=0x1f001f
	-- local ef={Duel.IsPlayerAffectedByEffect(sp,EFFECT_MUST_USE_MZONE)}
	-- for _,e in ipairs(ef) do
		-- local ev=e:GetValue()
		-- if type(ev)=='function' then zone=zone&ev(e) else zone=zone&ev end
	-- end
	-- zone=zone&(0x1f<<16*p)
	-- if zone>0x1f then zone=zone>>16 end
	-- local rg=mg~=nil and mg or Duel.GetTributeGroup(c)
	-- local sg=Group.CreateGroup()
	-- if rg:IsExists(Auxiliary.TribCheckRecursive,1,nil,sp,rg,sg,c,0,min,max,p,zone) then
		-- local finish=false
		-- while #sg<max do
			-- finish=Auxiliary.TributeGoal(sp,sg,c,#sg,min,max,p,zone)
			-- local cg=rg:Filter(Auxiliary.TribCheckRecursive,sg,sp,rg,sg,c,#sg,min,max,p,zone)
			-- if #cg==0 then break end
			-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TRIBUTE)
			-- local tc=cg:SelectUnselect(sg,sp,finish,false,min,max)
			-- if not tc then break end
			-- if not sg:IsContains(tc) then
				-- sg:AddCard(tc)
				-- if #sg>=max then finish=true end
			-- else sg:RemoveCard(tc) end
		-- end
	-- end
	-- return #sg>0 and sg or select_tribute(sp,c,min,max,rg,p)
-- end
Card.SetUniqueOnField=function(c,s,o,code,loc)
	if not loc then loc=LOCATION_ONFIELD end
	card_sethighlander(c,s,o,code,loc)
	if aux.GetValueType(code)=="number" then aux.AddCodeList(c,code) end
end
Card.IsFacedown=function(c)
	if c:IsLocation(LOCATION_REMOVED) and c:GetFlagEffect(FLAG_FAKE_FU_BANISH)>0 then
		return true
	else
		return card_is_facedown(c)
	end
end
Card.IsAbleToRemove=function(c,...)
	local x={...}
	local checkp=#x>0 and x[1] or self_reference_effect and current_triggering_player or nil
	local checkpos=#x>1 and x[2] or POS_FACEUP
	local checkr=#x>2 and x[3] or REASON_EFFECT
	if c:IsHasEffect(EFFECT_CANNOT_BANISH) then
		local ef={c:IsHasEffect(EFFECT_CANNOT_BANISH)}
		for _,te1 in ipairs(ef) do
			local cf=te1:GetValue()
			local typ=aux.GetValueType(cf)
			if not cf and checkr&REASON_EFFECT>0 then
				return false
			elseif (typ=="number" and cf==checkpos) and checkr&REASON_EFFECT>0 then
				return false
			elseif typ=="function" then
				local checkpos2,func=cf()
				if (not checkpos2 or checkpos2==checkpos) and (not func or func(c,self_reference_effect,checkr,checkp)) then
					return false
				end
			end
		end
	end
	return card_is_able_to_remove(c,table.unpack(x))
end
Card.IsAbleToRemoveAsCost=function(c,...)
	local x={...}
	local checkpos=#x>0 and x[1] or POS_FACEUP
	local checkp=#x>1 and x[2] or self_reference_effect and current_triggering_player or nil
	
	if c:IsHasEffect(EFFECT_CANNOT_BANISH_AS_COST) then
		local ef={c:IsHasEffect(EFFECT_CANNOT_BANISH_AS_COST)}
		for _,te1 in ipairs(ef) do
			local cf=te1:GetValue()
			local typ=aux.GetValueType(cf)
			if not cf then
				return false
			elseif (typ=="number" and cf==checkpos) then
				return false
			elseif typ=="function" then
				local checkpos2,func=cf()
				if (not checkpos2 or checkpos2==checkpos) and (not func or func(c,self_reference_effect,REASON_COST,checkp)) then
					return false
				end
			end
		end
	end
	return card_is_able_to_remove_as_cost(c,table.unpack(x))
end
Card.IsAbleToHand=function(c,...)
	local x={...}
	local checkp=#x>0 and x[1] or self_reference_effect and current_triggering_player or nil
	local checkrp=#x>1 and x[2] or x[1]
	if c:IsHasEffect(EFFECT_CANNOT_ADD_TO_HAND) then
		local ef={c:IsHasEffect(EFFECT_CANNOT_ADD_TO_HAND)}
		for _,te1 in ipairs(ef) do
			local cf=te1:GetValue()
			local typ=aux.GetValueType(cf)
			if not cf then
				return false
			elseif (typ=="number" and cf==checkp) then
				return false
			elseif typ=="function" then
				local checkp2,func=cf()
				if (not checkp2 or checkp2==checkp) and (not func or func(c,self_reference_effect,REASON_EFFECT,checkrp)) then
					return false
				end
			end
		end
	end
	return card_is_able_to_hand(c,table.unpack(x))
end
Card.IsCanBeSpecialSummoned=function(c,e,sumtype,sump,nocheck,nolimit,...)
	local x={...}
	local pos0=#x>0 and x[1] or POS_FACEUP
	local toplayer0=#x>1 and x[2] or sump
	if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then
		if c:IsHasEffect(EFFECT_CANNOT_SPECIAL_SUMMON) then
			return false
		end
		if Duel.IsPlayerAffectedByEffect(sump,EFFECT_CANNOT_SPECIAL_SUMMON) then
			local ef={Duel.IsPlayerAffectedByEffect(sump,EFFECT_CANNOT_SPECIAL_SUMMON)}
			for _,te1 in ipairs(ef) do
				local cf,tg=te1:GetValue(),te1:GetTarget()
				local typ1,typ2=aux.GetValueType(cf),aux.GetValueType(tg)
				if not tg and not cf then
					return false
				elseif typ2=="number" or not tg and typ1=="number" then
					return false
				elseif typ2=="function" and tg(te1,c,sump,sumtype,pos0,toplayer0,e) or not tg and typ1=="function" and cf(te1,c,sump,sumtype,pos0,toplayer0,e) then
					return false
				end
			end
		end
		return Duel.IsPlayerCanSpecialSummonMonster(sump,c:GetCode(),c:GLGetSetCard(),c:GetType(),c:GetAttack(),c:GetDefense(),c:GLGetLevel(),c:GetRace(),c:GetAttribute(),pos0,toplayer0,sumtype)
	end
	return card_is_can_be_ssed(c,e,sumtype,sump,nocheck,nolimit,table.unpack(x))
end

Card.GetLevel=function(c)
	if (card_get_level(c)==0 or not card_get_level(c)) then
		if c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) then
			return c:GetRank()
		elseif c:IsHasEffect(EFFECT_GRANT_LEVEL) then
			local ef={c:IsHasEffect(EFFECT_GRANT_LEVEL)}
			local te1=ef[#ef]
			local cf=te1:GetValue()
			local typ=aux.GetValueType(cf)
			local level
			if not cf then
				level=0
			elseif typ=="number" then
				level=cf
			elseif typ=="function" then
				level=cf(te1,c)
			end
			
			if c:IsHasEffect(EFFECT_UPDATE_LEVEL) or c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
				local l={}
				if c:IsHasEffect(EFFECT_UPDATE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_UPDATE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				if c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_CHANGE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				table.sort(l, function(a,b) return a:GetFieldID() < b:GetFieldID() end)
				for _,ce in ipairs(l) do
					if ce:GetCode()==EFFECT_UPDATE_LEVEL then
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=level+val
						else
							level=level+val(ce,c)
						end
					else
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=val
						else
							level=val(ce,c)
						end
					end
				end
			end
			return level
		end
	end
	return card_get_level(c)
end

Card.IsXyzLevel=function(c,sc,lv)
	if (card_get_level(c)==0 or not card_get_level(c)) then
		if c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) then
			return c:GetRank()==lv
		elseif c:IsHasEffect(EFFECT_GRANT_LEVEL) then
			local ef={c:IsHasEffect(EFFECT_GRANT_LEVEL)}
			local te1=ef[#ef]
			local cf=te1:GetValue()
			local typ=aux.GetValueType(cf)
			local level
			if not cf then
				level = 0
			elseif typ=="number" then
				level = cf
			elseif typ=="function" then
				templv,sumtyp = cf(te1,c,sc)
				if not sumtyp or sumtyp&TYPE_XYZ>0 then
					level=templv
				else
					level=0
				end
			end
			
			if c:IsHasEffect(EFFECT_UPDATE_LEVEL) or c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
				local l={}
				if c:IsHasEffect(EFFECT_UPDATE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_UPDATE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				if c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_CHANGE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				table.sort(l, function(a,b) return a:GetFieldID() < b:GetFieldID() end)
				for _,ce in ipairs(l) do
					if ce:GetCode()==EFFECT_UPDATE_LEVEL then
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=level+val
						else
							level=level+val(ce,c)
						end
					else
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=val
						else
							level=val(ce,c)
						end
					end
				end
			end
		
			if lv==level then
				return true
			end
		end
	end
	return card_is_xyz_level(c,sc,lv) 
end

Card.GetOriginalLevel=function(c)
	if (card_get_original_level(c)==0 or not card_get_original_level(c)) then
		if c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) then
			return c:GetOriginalRank()
		end
	end
	return card_get_original_level(c)
end

Card.GetPreviousLevelOnField=function(c)
	if (card_get_previous_level(c)==0 or not card_get_previous_level(c)) then
		if c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) then
			return c:GetPreviousRankOnField()
		elseif c:IsHasEffect(EFFECT_REMEMBER_GRANTED_LEVEL) then
			local ef={c:IsHasEffect(EFFECT_REMEMBER_GRANTED_LEVEL)}
			local te1=ef[#ef]
			local cf=te1:GetValue()
			local typ=aux.GetValueType(cf)
			if not cf then
				return 0
			elseif typ=="number" then
				return cf
			elseif typ=="function" then
				return cf(te1,c)
			end
		end
	end
	return card_get_previous_level(c)
end

Card.IsLevel=function(c,...)
	local lvs={...}
	if (card_get_level(c)==0 or not card_get_level(c)) then
		if c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) then
			return c:IsRank(table.unpack(lvs))
		elseif c:IsHasEffect(EFFECT_GRANT_LEVEL) then
			local ef={c:IsHasEffect(EFFECT_GRANT_LEVEL)}
			local te1=ef[#ef]
			local cf=te1:GetValue()
			local typ=aux.GetValueType(cf)
			local level
			if not cf then
				level = 0
			elseif typ=="number" then
				level = cf
			elseif typ=="function" then
				level = cf(te1,c)
			end
			
			if c:IsHasEffect(EFFECT_UPDATE_LEVEL) or c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
				local l={}
				if c:IsHasEffect(EFFECT_UPDATE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_UPDATE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				if c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_CHANGE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				table.sort(l, function(a,b) return a:GetFieldID() < b:GetFieldID() end)
				for _,ce in ipairs(l) do
					if ce:GetCode()==EFFECT_UPDATE_LEVEL then
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=level+val
						else
							level=level+val(ce,c)
						end
					else
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=val
						else
							level=val(ce,c)
						end
					end
				end
			end
					
			for i=1,#lvs do
				if lvs[i]==level then
					return true
				end
			end
			return false
		end
	end
	return card_is_level(c,table.unpack(lvs))
end

Card.IsLevelBelow=function(c,lv)
	if (card_get_level(c)==0 or not card_get_level(c)) then
		if c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) then
			return c:GetRank()<=lv
		elseif c:IsHasEffect(EFFECT_GRANT_LEVEL) then
			local ef={c:IsHasEffect(EFFECT_GRANT_LEVEL)}
			local te1=ef[#ef]
			local cf=te1:GetValue()
			local typ=aux.GetValueType(cf)
			local level
			if not cf then
				level = 0
			elseif typ=="number" then
				level = cf
			elseif typ=="function" then
				level = cf(te1,c)
			end
			
			if c:IsHasEffect(EFFECT_UPDATE_LEVEL) or c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
				local l={}
				if c:IsHasEffect(EFFECT_UPDATE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_UPDATE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				if c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_CHANGE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				table.sort(l, function(a,b) return a:GetFieldID() < b:GetFieldID() end)
				for _,ce in ipairs(l) do
					if ce:GetCode()==EFFECT_UPDATE_LEVEL then
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=level+val
						else
							level=level+val(ce,c)
						end
					else
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=val
						else
							level=val(ce,c)
						end
					end
				end
			end
			
			if level<=lv then
				return true
			end
			return false
		end
	end
	return card_is_level_below(c,lv)
end

Card.IsLevelAbove=function(c,lv)
	if (card_get_level(c)==0 or not card_get_level(c)) then
		if c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) then
			return c:GetRank()>=lv
		elseif c:IsHasEffect(EFFECT_GRANT_LEVEL) then
			local ef={c:IsHasEffect(EFFECT_GRANT_LEVEL)}
			local te1=ef[#ef]
			local cf=te1:GetValue()
			local typ=aux.GetValueType(cf)
			local level
			if not cf then
				level = 0
			elseif typ=="number" then
				level = cf
			elseif typ=="function" then
				level = cf(te1,c)
			end
			
			if c:IsHasEffect(EFFECT_UPDATE_LEVEL) or c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
				local l={}
				if c:IsHasEffect(EFFECT_UPDATE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_UPDATE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				if c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_CHANGE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				table.sort(l, function(a,b) return a:GetFieldID() < b:GetFieldID() end)
				for _,ce in ipairs(l) do
					if ce:GetCode()==EFFECT_UPDATE_LEVEL then
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=level+val
						else
							level=level+val(ce,c)
						end
					else
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=val
						else
							level=val(ce,c)
						end
					end
				end
			end
			
			if level>=lv then
				return true
			end
			return false
		end
	end
	return card_is_level_above(c,lv)
end

Card.IsDestructable=function(c,...)
	local x={...}
	local e=x[1]
	local r=x[2]
	local tp=x[3]
	if r and r&REASON_COST>0 then
		for _,ce in ipairs({c:IsHasEffect(EFFECT_INDESTRUCTABLE_COST)}) do
			local val=ce:GetValue()
			if val and type(val)=="number" then
				return false
			elseif type(val)=="function" and val(ce,e,tp) then
				return false
			end
		end
		return true
	else
		return card_is_destructable(c,table.unpack(x))
	end
end

Card.GetSynchroLevel=function(c,sc)
	local synlv=card_get_syn_level(c,sc)
	local level=false
	if (card_get_level(c)==0 or not card_get_level(c)) then
		if c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) then
			level=c:GetRank()
		elseif c:IsHasEffect(EFFECT_GRANT_LEVEL) then
			local ef={c:IsHasEffect(EFFECT_GRANT_LEVEL)}
			for _,te1 in ipairs(ef) do
				local cf=te1:GetValue()
				local typ=aux.GetValueType(cf)
				local templv
				if not cf then
					level = 0
				elseif typ=="number" then
					level = cf
				elseif typ=="function" then
					templv,sumtyp = cf(te1,c,sc)
					if not sumtyp or sumtyp&TYPE_SYNCHRO>0 then
						level=templv
					else
						level=0
					end
				end
			end
			if c:IsHasEffect(EFFECT_UPDATE_LEVEL) or c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
				local l={}
				if c:IsHasEffect(EFFECT_UPDATE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_UPDATE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				if c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_CHANGE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				table.sort(l, function(a,b) return a:GetFieldID() < b:GetFieldID() end)
				for _,ce in ipairs(l) do
					if ce:GetCode()==EFFECT_UPDATE_LEVEL then
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=level+val
						else
							level=level+val(ce,c)
						end
					else
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=val
						else
							level=val(ce,c)
						end
					end
				end
			end
		end
	end
	if level then
		if synlv then
			synlv=level*65536+synlv
		else
			synlv=level
		end
	end
	return synlv
end
Card.GetRitualLevel=function(c,sc)
	local synlv=card_get_rit_level(c,sc)
	local level=false
	if (card_get_level(c)==0 or not card_get_level(c)) then
		if c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) then
			level=c:GetRank()
		elseif c:IsHasEffect(EFFECT_GRANT_LEVEL) then
			local ef={c:IsHasEffect(EFFECT_GRANT_LEVEL)}
			for _,te1 in ipairs(ef) do
				local cf=te1:GetValue()
				local typ=aux.GetValueType(cf)
				local templv
				if not cf then
					level = 0
				elseif typ=="number" then
					level = cf
				elseif typ=="function" then
					templv,sumtyp = cf(te1,c,sc)
					if not sumtyp or sumtyp&TYPE_RITUAL>0 then
						level=templv
					else
						level=0
					end
				end
			end
			if c:IsHasEffect(EFFECT_UPDATE_LEVEL) or c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
				local l={}
				if c:IsHasEffect(EFFECT_UPDATE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_UPDATE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				if c:IsHasEffect(EFFECT_CHANGE_LEVEL) then
					for _,v in ipairs({c:IsHasEffect(EFFECT_CHANGE_LEVEL)}) do
						table.insert(l,v)
					end
				end
				table.sort(l, function(a,b) return a:GetFieldID() < b:GetFieldID() end)
				for _,ce in ipairs(l) do
					if ce:GetCode()==EFFECT_UPDATE_LEVEL then
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=level+val
						else
							level=level+val(ce,c)
						end
					else
						local val=ce:GetValue()
						if aux.GetValueType(val)=="number" then
							level=val
						else
							level=val(ce,c)
						end
					end
				end
			end
		end
	end
	if level then
		synlv=level*65536+synlv
	end
	return synlv
end

--Custom Functions
function Auxiliary.TribCheckRecursive(c,tp,mg,sg,sc,ct,min,max,p,zone)
	sg:AddCard(c)
	ct=ct+1
	local res=Auxiliary.TributeGoal(tp,sg,sc,ct,min,max,p,zone)
		or (ct<max and mg:IsExists(Auxiliary.TribCheckRecursive,1,sg,tp,mg,sg,sc,ct,min,max,p,zone))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.TributeGoal(tp,sg,sc,ct,min,max,p,zone)
	return ct>=min and duel_check_tribute(sc,ct,ct,sg,p,zone)
end
--add procedure to equip spells equipping by rule
function Auxiliary.AddEquipProcedure(c,p,f,eqlimit,cost,tg,op,con,ctlimit)
	--Note: p==0 is check equip spell controler, p==1 for opponent's, PLAYER_ALL for both player's monsters
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1068)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	if ctlimit~=nil then
		e1:SetCountLimit(1,c:GetCode()+EFFECT_COUNT_CODE_OATH)
	end
	if con then
		e1:SetCondition(con)
	end
	if cost~=nil then
		e1:SetCost(cost)
	end
	e1:SetTarget(Auxiliary.EquipTarget(tg,p,f))
	e1:SetOperation(op)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	if eqlimit~=nil then
		e2:SetValue(eqlimit)
	else
		e2:SetValue(Auxiliary.EquipLimit(f))
	end
	c:RegisterEffect(e2)
end
function Auxiliary.EquipLimit(f)
	return function(e,c)
				return not f or f(c,e,e:GetHandlerPlayer())
			end
end
function Auxiliary.EquipFilter(c,p,f,e,tp)
	return (p==PLAYER_ALL or c:IsControler(p)) and c:IsFaceup() and (not f or f(c,e,tp))
end
function Auxiliary.EquipTarget(tg,p,f)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local player=nil
				if p==0 then
					player=tp
				elseif p==1 then
					player=1-tp
				elseif p==PLAYER_ALL or p==nil then
					player=PLAYER_ALL
				end
				if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and Auxiliary.EquipFilter(chkc,player,f,e,tp) end
				if chk==0 then return player~=nil and Duel.IsExistingTarget(Auxiliary.EquipFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,player,f,e,tp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local g=Duel.SelectTarget(tp,Auxiliary.EquipFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,player,f,e,tp)
				if tg then tg(e,tp,eg,ep,ev,re,r,rp,g:GetFirst()) end
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_CHAIN_SOLVING)
				e1:SetReset(RESET_CHAIN)
				e1:SetLabel(Duel.GetCurrentChain())
				e1:SetLabelObject(e)
				e1:SetOperation(Auxiliary.EquipEquip)
				Duel.RegisterEffect(e1,tp)
				Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
			end
end
function Auxiliary.EquipEquip(e,tp,eg,ep,ev,re,r,rp)
	if re~=e:GetLabelObject() then return end
	local c=e:GetHandler()
	local tc=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TARGET_CARDS):GetFirst()
	if tc and c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end

--Fusion Summon shorthand
--Effect, player, filter for Fusion Monster, materials (optional), monster that must be used as material (optional)
function Auxiliary.IsCanFusionSummon(f,e,tp,mg1,gc)
	local chkf=tp
	if mg1==nil then mg1=Duel.GetFusionMaterial(tp):Filter(Auxiliary.PerformFusionFilter,nil,e) end
	local res=Duel.IsExistingMatchingCard(f,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf,gc)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=Duel.IsExistingMatchingCard(f,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf,gc)
		end
	end
	return res
end
function Auxiliary.PerformFusionFilter(c,e)
	return not c:IsImmuneToEffect(e)
end
function Auxiliary.PerformFusionSummon(f,e,tp,mg1,gc,procedure)
	local chkf=tp
	if mg1==nil then mg1=Duel.GetFusionMaterial(tp):Filter(Auxiliary.PerformFusionFilter,nil,e) end
	local sg1=Duel.GetMatchingGroup(f,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(f,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
			tc:SetMaterial(mat1)
			if procedure then procedure(mat1,tp,tc)
			else Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION) end
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
--Can't be used for any ED materials
table.insert(Auxiliary.CannotBeEDMatCodes,EFFECT_CANNOT_BE_FUSION_MATERIAL)
table.insert(Auxiliary.CannotBeEDMatCodes,EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
table.insert(Auxiliary.CannotBeEDMatCodes,EFFECT_CANNOT_BE_XYZ_MATERIAL)
table.insert(Auxiliary.CannotBeEDMatCodes,EFFECT_CANNOT_BE_LINK_MATERIAL)
function Auxiliary.CannotBeEDMaterial(c,f,range,isrule,reset,owner,prop,allow_customs)
	if not owner then owner=c end
	
	local typ = EFFECT_TYPE_SINGLE
	local property = type(prop)=="number" and prop or 0
	
	if (isrule == nil or isrule == true) then
		property = property|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE
	end
	
	if range ~=nil then
		if range=="Equip" then
			typ=EFFECT_TYPE_EQUIP
			range=nil
		else
			property = property|EFFECT_FLAG_SINGLE_RANGE
		end
	end
	
	local allow_customs = type(allow_customs)=="nil" or allow_customs
	for _,val in ipairs(Auxiliary.CannotBeEDMatCodes) do
		if allow_customs or val==EFFECT_CANNOT_BE_FUSION_MATERIAL or val==EFFECT_CANNOT_BE_SYNCHRO_MATERIAL or val==EFFECT_CANNOT_BE_XYZ_MATERIAL or val==EFFECT_CANNOT_BE_LINK_MATERIAL then
			local restrict = Effect.CreateEffect(owner)
			restrict:SetType(typ)
			restrict:SetCode(val)
			if (property ~= 0) then
				restrict:SetProperty(property)
			end
			if range~=nil then
				restrict:SetRange(range)
			end
			if f==nil then
				restrict:SetValue(1)
			else
				restrict:SetValue(Auxiliary.FilterToCannotValue(f))
			end
			if reset~=nil then
				local rct=1
				if type(reset)=="table" then
					rct=reset[2]
					reset=reset[1]
				end
				restrict:SetReset(reset,rct)
			end
			c:RegisterEffect(restrict)
		end
	end
end
function Auxiliary.FilterToCannotValue(f)
	return function (e,c)
		if not c then return false end
		return not f(c)
	end
end

---Effect Manipulation Auxiliaries---
--Effect Conditions
function Auxiliary.ModifyCon(con,...)
	local cons={...}
	return function (e,tp,eg,ep,ev,re,r,rp)
		local check=0
		for _,v in ipairs(cons) do
			if not v(e,tp,eg,ep,ev,re,r,rp) then
				check=1
			end
		end
		return (con==nil or con(e,tp,eg,ep,ev,re,r,rp)) and check==0
	end
end
function Auxiliary.PreserveConQuickE(con,ce)
	return function (e,tp,eg,ep,ev,re,r,rp)
		return (con==nil or con(e,tp,eg,ep,ev,re,r,rp)) and Duel.GetTurnPlayer()~=tp and ce~=nil
	end
end
function Auxiliary.ResetEffectFunc(effect,functype,func,...)
	local funs={...}
	return function(e,tp,eg,ep,ev,re,r,rp)
		if functype=='condition' then
			effect:SetCondition(func)
			e:Reset()
		elseif functype=='cost' then
			effect:SetCost(func)
			e:Reset()
		elseif functype=='target' then
			effect:SetTarget(func)
			e:Reset()
		elseif functype=='operation' then
			effect:SetOperation(func)
			e:Reset()
		elseif functype=='value' then
			effect:SetValue(func)
			e:Reset()
		elseif functype=='countlimit' then
			if funs[1] then
				effect:SetCountLimit(func,funs[1])
			else
				effect:SetCountLimit(func)
			end
			e:Reset()
		else
			e:Reset()
		end
		e:Reset()
	end
end

--
function Auxiliary.CheckKaijuProc(e)
	local kaijuprocs=Auxiliary.kaiju_procs
	local check=false
	for _,k in ipairs(kaijuprocs) do
		if e==k then
			check=true
		end
	end
	return check
end
function Auxiliary.FullReset(e)
	local lab=e:GetLabelObject()
	if lab then
		lab:Reset()
	end
	e:Reset()
end
--Random Target Auxiliary
function Auxiliary.CheckPrevRandom(c)
	return c:GetFlagEffect(39759371)>0
end
function Auxiliary.RandomTargetFilter(c)
	return c:GetFlagEffect(39759371)>0 and c:GetFlagEffectLabel(39759371)==999
end

--Glitchy's custom auxs and functions
if not glitchy_effect_table then glitchy_effect_table={} end
if not glitchy_archetype_table then glitchy_archetype_table={} end

--constant aliases
RACE_PSYCHIC=RACE_PSYCHO
RACE_WINGEDBEAST=RACE_WINDBEAST
EFFECT_TYPE_TRIGGER=EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_TRIGGER_F
EFFECT_TYPE_QUICK=EFFECT_TYPE_QUICK_O+EFFECT_TYPE_QUICK_F
EFFECT_TYPE_CHAIN_STARTER=EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_QUICK_O+EFFECT_TYPE_QUICK_F+EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_IGNITION

--glitchy's custom events
EVENT_ACTIVATE_LINK_MARKER=9000
EVENT_DEACTIVATE_LINK_MARKER=9001

--resets
RESETS_STANDARD_DISABLE=RESETS_STANDARD|RESET_DISABLE

function Group.Includes(g1,g2)
	if #g1==0 or #g1<#g2 then return false end
	local check=true
	if #g2>0 then
		for tc in aux.Next(g2) do
			if not g1:IsContains(tc) then
				check=false
				break
			end
		end
	end
	return check
end

function Effect.GLGetTargetRange(e)
	if not global_target_range_effect_table[e] then return false,false end
	local s=global_target_range_effect_table[e][1]
	local o=global_target_range_effect_table[e][2]
	return s,o
end

function Effect.GLGetReset(e)
	if not global_reset_effect_table[e] then return 0,1 end
	local reset=global_reset_effect_table[e][1]
	local rct=global_reset_effect_table[e][2]
	return reset,rct
end
function Effect.GetReset(e)
	return e:GLGetReset()
end

function Auxiliary.SetOperationResultAsLabel(op)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local res=op(e,tp,eg,ep,ev,re,r,rp)
				e:SetLabel(res)
				return res
			end
end

--Procs through numbers from 0 to ct and assigns a value depending on what number "i" is equal to.
--{...}: For example, if i==0 then the function will assign the value inserted as the 1st {...} param, if i==1 the 2nd {...} param will be assigned and so on
function Auxiliary.GLSetValueDependingOnNumber(i,ct,...)
	local f={...}
	if #f~=ct+1 then return 0 end
	for k=0,ct do
		if i==k then return f[k+1] end
	end
	return 0
end	

function Group.SelectUnselectCheck(g,e,tp,minc,maxc,rescon)
	return g:IsExists(Auxiliary.SelectUnselectLoop,1,nil,Group.CreateGroup(),g,e,tp,minc,maxc,rescon)
end

function Card.GLIsAbleToDrawFromExtra(c,p)
	return not Duel.IsPlayerAffectedByEffect(p,EFFECT_CANNOT_DRAW) and not c:IsHasEffect(EFFECT_CANNOT_TO_HAND)
end
function Card.GLGetLinkMarkerCount(c)
	local list={LINK_MARKER_BOTTOM_LEFT,LINK_MARKER_LEFT,LINK_MARKER_TOP_LEFT,LINK_MARKER_TOP_RIGHT,LINK_MARKER_BOTTOM_RIGHT,LINK_MARKER_BOTTOM}
	local ct=0
	for i=1,8 do
		if c:IsLinkMarker(list[i]) then
			ct=ct+1
		end
	end
	return ct
end
function Card.GLIsCanActivateLinkMarkers(c,val,...)
	local f={...}
	if not f[1] and c:GetLinkMarker()==8 then return false end
	local maxval=0
	local egroup={c:IsHasEffect(EFFECT_CANNOT_ACTIVATE_LMARKER)}
	for _,ce in ipairs(egroup) do
		if type(ce:GetValue())=="number" and ce:GetValue()>maxval then
			maxval=ce:GetValue()
		end
	end
	return c:GLGetLinkMarkerCount()<=8-val and (not c:IsHasEffect(EFFECT_CANNOT_ACTIVATE_LMARKER) or val<=maxval)
end

function Card.GLIsCanDeactivateLinkMarkers(c,val,...)
	local f={...}
	if not f[1] and c:GetLinkMarker()==0 then return false end
	local maxval=0
	local egroup={c:IsHasEffect(EFFECT_CANNOT_ACTIVATE_LMARKER)}
	for _,ce in ipairs(egroup) do
		if type(ce:GetValue())=="number" and ce:GetValue()>maxval then
			maxval=ce:GetValue()
		end
	end
	return c:GLGetLinkMarkerCount()>=val and (not c:IsHasEffect(EFFECT_CANNOT_DEACTIVATE_LMARKER) or val<=maxval)
end

function Card.GLGetSetCard(c)
	local val={}
	local setcode=0
	
	local egroup={c:IsHasEffect(EFFECT_ADD_SETCODE)}
	for _,ce in ipairs(egroup) do
		setcode=setcode|ce:GetValue()
	end
	
	
	if glitchy_archetype_table[c]~=nil and c:GetFlagEffect(777)>0 then
		setcode=setcode|glitchy_archetype_table[c]
	else
		local sc=0
		-- if c:IsHasEffect(c:IsHasEffect(EFFECT_CHANGE_SETCODE)) then
			-- local egroup2={c:IsHasEffect(EFFECT_CHANGE_SETCODE)}
			-- for _,ce in ipairs(egroup2) do
				-- setcode=ce:GetValue()
			-- end
		-- else
		for i=1,#ARCHETYPES do
			if c:IsOriginalSetCard(ARCHETYPES[i]) then
				table.insert(val,ARCHETYPES[i])
			end
		end
		for i=1,#CUSTOM_ARCHETYPES do
			if c:IsOriginalSetCard(CUSTOM_ARCHETYPES[i]) then
				table.insert(val,CUSTOM_ARCHETYPES[i])
			end
		end
		if #val>0 then
			for i=1,#val do
				sc=sc|val[i]
			end
		end
		glitchy_archetype_table[c]=sc
		setcode=setcode|sc
		c:RegisterFlagEffect(777,0,EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_UNCOPYABLE,1)
	end
	
	return setcode
end

function Card.IsHasNoArchetype(c)
	return c:GLGetSetCard()==0 or c:IsHasEffect(EFFECT_NO_ARCHETYPE)
end

function Card.GLGetLevel(c)
	if c:GetOriginalType()&TYPE_XYZ~=0 then return c:GetRank()
	elseif c:GetOriginalType()&TYPE_LINK~=0 then return c:GetLink()
	elseif c:GetOriginalType()&TYPE_EVOLUTE~=0 then return c:GetStage()
	elseif c:GetOriginalType()&TYPE_TIMELEAP~=0 then return c:GetFuture()
	elseif c:GetOriginalType()&TYPE_SPATIAL~=0 then return c:GetDimensionNo()
	else return c:GetLevel() end
end

function Card.GLGetOriginalLevel(c)
	if c:IsType(TYPE_XYZ) then return c:GetOriginalRank()
	elseif c:IsType(TYPE_LINK) then return c:GetOriginalLink()
	else return c:GetOriginalLevel() end
end

function Effect.GLString(e,id,...)
	local f={...}
	-- if #f>0 then
		-- e:SetDescription(aux.Stringid(id,f[1]))
	-- else
		e:SetDescription(aux.Stringid(e:GetOwner():GetOriginalCode(),id))
	--end
end

function Auxiliary.ActivateST(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	return e1
end

function Auxiliary.GetExceptionReset(loc)
	if loc&LOCATION_ONFIELD>0 then
		return RESET_TOFIELD
	elseif loc&LOCATION_GRAVE>0 then
		return RESET_TOGRAVE
	elseif loc&LOCATION_REMOVED>0 then
		return RESET_REMOVE+RESET_TEMP_REMOVE
	elseif loc&(LOCATION_DECK+LOCATION_EXTRA)>0 then
		return RESET_TODECK
	elseif loc&LOCATION_HAND>0 then
		return RESET_TOHAND
	else
		return 0
	end
end

function Auxiliary.DeckControlerFilter(c,p)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(p)
end
function Auxiliary.ShuffleCheck(g)
	for p=0,1 do
		if g:IsExists(aux.DeckControlerFilter,1,nil,p) then
			Duel.ShuffleDeck(p)
		end
	end
end

--Returns all the MMZ the arrows PRINTED on the card (c) point to, REGARDLESS of the card type (even if it is not an active Link Monster) or of the location it is in (MZONE/SZONE)
--If f is set to true, the function only returns the available zones (usable and unoccupied)
function Auxiliary.GLGetLinkedZoneManually(c,f)
	if c:GetOriginalType()&TYPE_LINK==0 or not c:IsLocation(LOCATION_MZONE+LOCATION_SZONE) then return 0 end
	local seq=c:GetSequence()
	local tlchk,tchk,trchk=false,false,false
	local xct=(seq>4) and true or false
	if c:IsLocation(LOCATION_MZONE) then
		if (seq>4 or seq==2 or seq==4) then tlchk=true end
		if (seq>4 or seq==1 or seq==3) then tchk=true end
		if (seq>4 or seq==0 or seq==2) then trchk=true end
	end
	local lk=(c:IsLocation(LOCATION_MZONE)) and c:GetLinkMarker() or c:GetOriginalLinkMarker()
	local zone=0
	local free=(f==true) and function(c,loc,sq,locp) local p=(locp~=nil) and 1-c:GetControler() or c:GetControler() local s=(locp~=nil and sq<5) and 4-sq or sq return Duel.CheckLocation(p,loc,s) end or false
	
	if lk&LINK_MARKER_BOTTOM_LEFT>0 and c:IsLocation(LOCATION_MZONE) and seq>0 then
		if xct then xct=(seq==5) and 1 or 3 end
		local base=(seq>4) and xct or seq
		local loct=(seq>4) and 0 or 8
		local floc=(seq>4) and LOCATION_MZONE or LOCATION_SZONE
		if not free or free(c,floc,base-1) then
			zone=zone|(0x1<<(base-1+loct))
		end
	end
	if lk&LINK_MARKER_BOTTOM>0 and c:IsLocation(LOCATION_MZONE) then
		if xct then xct=(seq==5) and 1 or 3 end
		local base=(type(xct)=="number") and xct or seq
		local loct=(seq>4) and 0 or 8
		local floc=(seq>4) and LOCATION_MZONE or LOCATION_SZONE
		if not free or free(c,floc,base) then
			zone=zone|(0x1<<(base+loct))
		end
	end
	if lk&LINK_MARKER_BOTTOM_RIGHT>0 and c:IsLocation(LOCATION_MZONE) and seq~=4 then
		if xct then xct=(seq==5) and 1 or 3 end
		local base=(type(xct)=="number") and xct or seq
		local loct=(seq>4) and 0 or 8
		local floc=(seq>4) and LOCATION_MZONE or LOCATION_SZONE
		if not free or free(c,floc,base+1) then
			zone=zone|(0x1<<(base+1+loct))
		end
	end
	if lk&LINK_MARKER_LEFT>0 and seq<5 and seq~=0 then
		local loct=(c:IsLocation(LOCATION_MZONE)) and 0 or 8
		local floc=(c:IsLocation(LOCATION_MZONE)) and LOCATION_MZONE or LOCATION_SZONE
		if not free or free(c,floc,seq-1) then
			zone=zone|(0x1<<(seq-1+loct))
		end
	end
	if lk&LINK_MARKER_RIGHT>0 and seq<5 and seq~=4 then
		local loct=(c:IsLocation(LOCATION_MZONE)) and 0 or 8
		local floc=(c:IsLocation(LOCATION_MZONE)) and LOCATION_MZONE or LOCATION_SZONE
		if not free or free(c,floc,seq+1) then
			zone=zone|(0x1<<(seq+1+loct))
		end
	end
	if lk&LINK_MARKER_TOP_LEFT>0 and ((c:IsLocation(LOCATION_SZONE) and seq>0) or tlchk) then
		local loct,locp
		if xct then
			xct=(seq==5) and 1 or 3
			loct=16
			locp=true
		end
		local base=(seq>4) and xct or seq
		if not loct then
			loct=0
		end
		local val=(seq>4) and 4-(base-1) or base-1
		local freeseq=(c:IsLocation(LOCATION_MZONE) and seq==2) and 5 or (c:IsLocation(LOCATION_MZONE) and seq==4) and 6 or base-1
		if not free or free(c,LOCATION_MZONE,base-1,locp) then
			if c:IsLocation(LOCATION_MZONE) and seq==2 then
				zone=zone|0x20
			elseif c:IsLocation(LOCATION_MZONE) and seq==4 then
				zone=zone|0x40
			else
				zone=zone|(0x1<<(val+loct))
			end
		end
	end
	if lk&LINK_MARKER_TOP>0 and (c:IsLocation(LOCATION_SZONE) or tchk) then
		local loct,locp
		if xct then
			xct=(seq==5) and 1 or 3
			loct=16
			locp=true
		end
		local base=(seq>4) and xct or seq
		if not loct then
			loct=0
		end
		local val=(seq>4) and 4-base or base
		local freeseq=(c:IsLocation(LOCATION_MZONE) and seq==1) and 5 or (c:IsLocation(LOCATION_MZONE) and seq==3) and 6 or base
		if not free or free(c,LOCATION_MZONE,freeseq,locp) then
			if c:IsLocation(LOCATION_MZONE) and seq==1 then
				zone=zone|0x20
			elseif c:IsLocation(LOCATION_MZONE) and seq==3 then
				zone=zone|0x40
			else
				zone=zone|(0x1<<(val+loct))
			end
		end
	end
	if lk&LINK_MARKER_TOP_RIGHT>0 and ((c:IsLocation(LOCATION_SZONE) and seq~=4) or trchk) then
		local loct,locp
		if xct then
			xct=(seq==5) and 1 or 3
			loct=16
			locp=true
		end
		local base=(seq>4) and xct or seq
		if not loct then
			loct=0
		end
		local val=(seq>4) and 4-(base+1) or base+1
		local freeseq=(c:IsLocation(LOCATION_MZONE) and seq==0) and 5 or (c:IsLocation(LOCATION_MZONE) and seq==2) and 6 or base+1
		if not free or free(c,LOCATION_MZONE,freeseq,locp) then
			if c:IsLocation(LOCATION_MZONE) and seq==0 then
				zone=zone|0x20
			elseif c:IsLocation(LOCATION_MZONE) and seq==2 then
				zone=zone|0x40
			else
				zone=zone|(0x1<<(val+loct))
			end
		end
	end
	return zone
end

--Custom Synchro Table to enable multi-material effects
-- local synchro_proc, synchro_mix_proc = Auxiliary.AddSynchroProcedure, Auxiliary.AddSynchroMixProcedure

-- SYNCHRO_MIX_FUNCTION_COUNT=3

-- Auxiliary.AddSynchroProcedure=function(c,f1,f2,minc,maxc)
	-- if c.extradeckproc==nil then
		-- local mt=getmetatable(c)
		-- mt.extradeckproc={}
	-- end
	-- local syn={"Synchro",f1,f2,minc,maxc}
	-- table.insert(c.extradeckproc,syn)
	-- if f1==nil then f1=aux.Tuner(nil) end
	-- if f2==nil then f2=false end
	-- Auxiliary.XSynchroProcedure(c,false,f2,minc,maxc,nil,aux.Tuner(f1))
-- end

-- Auxiliary.AddSynchroMixProcedure=function(c,f1,f2,f3,f4,minc,maxc,gc)
	-- if c.extradeckproc==nil then
		-- local mt=getmetatable(c)
		-- mt.extradeckproc={}
	-- end
	-- local syn={"SynchroMix",f1,f2,f3,f4,minc,maxc,gc}
	-- table.insert(c.extradeckproc,syn)
	-- Auxiliary.XSynchroProcedure(c,false,f4,minc,maxc,gc,f1,f2,f3)
	-- --synchro_mix_proc(c,f1,f2,f3,f4,minc,maxc,gc)
-- end

-- --Synchro monster, f1~f3 each 1 MONSTER + f4 min to max monsters
-- function Auxiliary.XSynchroProcedure(c,metacheck,f,minc,maxc,gc,...)
	-- local fx={...}
	-- if metacheck then
		-- if c.extradeckproc==nil then
			-- local mt=getmetatable(c)
			-- mt.extradeckproc={}
		-- end
		-- local syn={"XSynchro",f,minc,maxc,gc,table.unpack(fx)}
		-- table.insert(c.extradeckproc,syn)
	-- end
	-- if not minc then minc=1 end
	-- if not maxc then maxc=99 end
	-- local e1=Effect.CreateEffect(c)
	-- e1:SetDescription(1164)
	-- e1:SetType(EFFECT_TYPE_FIELD)
	-- e1:SetCode(EFFECT_SPSUMMON_PROC)
	-- e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- e1:SetRange(LOCATION_EXTRA)
	-- e1:SetCondition(Auxiliary.XSynMixCondition(f,minc,maxc,gc,table.unpack(fx)))
	-- e1:SetTarget(Auxiliary.XSynMixTarget(f,minc,maxc,gc,table.unpack(fx)))
	-- e1:SetOperation(Auxiliary.XSynMixOperation(f,minc,maxc,gc,table.unpack(fx)))
	-- e1:SetValue(SUMMON_TYPE_SYNCHRO)
	-- c:RegisterEffect(e1)
-- end
-- function Auxiliary.XSynMaterialFilter(c,syncard)
	-- if c:IsLocation(LOCATION_MZONE) then
		-- return c:IsFaceup() and c:IsCanBeSynchroMaterial(syncard)
	-- else
		-- if c:IsLocation(LOCATION_REMOVED) and not c:IsFaceup() then return false end
		-- local egroup={c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_EXTRA)}
		-- for _,ce in ipairs(egroup) do
			-- if ce and (not ce:GetTarget() or ce:GetTarget()(syncard)) and c:IsCanBeSynchroMaterial(syncard) then
				-- return true
			-- end
		-- end
		-- return false
	-- end
-- end
-- function Auxiliary.XGetSynMaterials(tp,syncard)
	-- local mg=Duel.GetMatchingGroup(Auxiliary.XSynMaterialFilter,tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_SZONE+LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA+LOCATION_REMOVED,nil,syncard)
	-- if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- local mg2=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND,0,nil,syncard)
		-- if mg2:GetCount()>0 then mg:Merge(mg2) end
	-- end
	-- return mg
-- end
-- function Auxiliary.XSynMixCondition(f,minc,maxc,gc,...)
	-- local fx={...}
	-- return	function(e,c,smat,mg1,min,max)
				-- if c==nil then return true end
				-- if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				-- local minc=minc
				-- local maxc=maxc
				-- if min then
					-- if min>minc then minc=min end
					-- if max<maxc then maxc=max end
					-- if minc>maxc then return false end
				-- end
				-- local tp=c:GetControler()
				-- local mg
				-- local mgchk=false
				-- if mg1 then
					-- mg=mg1
					-- mgchk=true
				-- else
					-- mg=Auxiliary.XGetSynMaterials(tp,c)
				-- end
				-- if smat~=nil then mg:AddCard(smat) end
				-- return mg:IsExists(Auxiliary.XSynMixFilterRecursive,1,nil,f,minc,maxc,c,mg,smat,gc,mgchk,nil,1,table.unpack(fx))
			-- end
-- end
-- function Auxiliary.XSynMixFilterRecursive(c,f,minc,maxc,syncard,mg,smat,gc,mgchk,exg,index,...)
	-- local fx={...}
	-- local exg=exg
	-- if exg==nil then
		-- exg=Group.CreateGroup()
		-- exg:KeepAlive()
	-- end
	-- if index>#fx then
		-- return mg:IsExists(Auxiliary.XSynMixFilterFinal,1,exg,f,minc,maxc,syncard,mg,smat,gc,mgchk,exg)
	-- else
		-- exg:AddCard(c)
		-- local indexskip,safelock=1,false
		-- if c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE) then
			-- local egroup={c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)}
			-- for _,ce in ipairs(egroup) do
				-- if safelock then break end
				-- if ce and (not ce:GetTarget() or ce:GetTarget()(syncard)) and ((type(ce:GetValue())=="function" and ce:GetValue()(c,f,minc,maxc,syncard)>1) or ce:GetValue()>1) then
					-- local skip=(type(ce:GetValue())=="function") and ce:GetValue()(c,f,minc,maxc,syncard) or ce:GetValue()
					-- local check=0
					-- for i=index,#fx do
						-- if fx[i]~=nil and (not fx[i] or fx[i](c,syncard)) then
							-- check=check+1
						-- end
					-- end
					-- if check>=skip then
						-- indexskip=indexskip+skip-1
						-- safelock=true
					-- end
				-- end
			-- end
		-- end
		-- local check=(fx[index]~=nil and (fx[index]==false or fx[index](c,syncard)) and mg:IsExists(Auxiliary.XSynMixFilterRecursive,1,exg,f,minc,maxc,syncard,mg,smat,gc,mgchk,exg,index+indexskip,table.unpack(fx)))
		-- exg:RemoveCard(c)
		-- return check
	-- end
-- end
-- function Auxiliary.XSynMixFilterFinal(c,f,minc,maxc,syncard,mg1,smat,gc,mgchk,exg)
	-- if f and not f(c,syncard) then return false end
	-- local sg=exg:Clone()
	-- sg:AddCard(c)
	-- local mg=mg1:Clone()
	-- if f then
		-- mg=mg:Filter(f,sg,syncard)
	-- else
		-- mg:Sub(sg)
	-- end
	-- local ctfix=1
	-- if c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE) then
		-- local egroup={c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)}
		-- local safelock=false
		-- for _,ce in ipairs(egroup) do
			-- if safelock then break end
			-- if ce and (not ce:GetTarget() or ce:GetTarget()(syncard)) and ((type(ce:GetValue())=="function" and ce:GetValue()(c,nil,minc,nil,syncard)>1) or ce:GetValue()>1) then
				-- local skip=(type(ce:GetValue())=="function") and ce:GetValue()(c,f,minc,maxc,syncard) or ce:GetValue()
				-- ctfix=ctfix+skip-1
				-- safelock=true
			-- end
		-- end
	-- end
	-- return Auxiliary.XSynMixCheck(mg,sg,minc-ctfix,maxc-ctfix,syncard,smat,gc,mgchk)
-- end
-- function Auxiliary.XSynMixCheck(mg,sg1,minc,maxc,syncard,smat,gc,mgchk)
	-- local tp=syncard:GetControler()
	-- local sg=Group.CreateGroup()
	-- --Debug.Message(tostring(minc).." "..tostring(syncard:GetCode()))
	-- if minc<=0 and Auxiliary.XSynMixCheckGoal(tp,sg1,0,0,syncard,sg,smat,gc,mgchk) then return true end
	-- if maxc==0 then return false end
	-- return mg:IsExists(Auxiliary.XSynMixCheckRecursive,1,nil,tp,sg,mg,0,minc,maxc,syncard,sg1,smat,gc,mgchk)
-- end
-- function Auxiliary.XSynMixCheckRecursive(c,tp,sg,mg,ct,minc,maxc,syncard,sg1,smat,gc,mgchk)
	-- sg:AddCard(c)
	-- local ctfix=1
	-- if c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE) then
		-- local egroup={c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)}
		-- local safelock=false
		-- for _,ce in ipairs(egroup) do
			-- if safelock then break end
			-- if ce and (not ce:GetTarget() or ce:GetTarget()(syncard)) and ((type(ce:GetValue())=="function" and ce:GetValue()(c,nil,minc,nil,syncard)>1) or ce:GetValue()>1) then
				-- local skip=(type(ce:GetValue())=="function") and ce:GetValue()(c,f,minc,maxc,syncard) or ce:GetValue()
				-- ctfix=ctfix+skip-1
				-- safelock=true
			-- end
		-- end
	-- end
	-- ct=ct+ctfix
	-- local res=Auxiliary.XSynMixCheckGoal(tp,sg,minc,ct,syncard,sg1,smat,gc,mgchk)
		-- or (ct<maxc and mg:IsExists(Auxiliary.XSynMixCheckRecursive,1,sg,tp,sg,mg,ct,minc,maxc,syncard,sg1,smat,gc,mgchk))
	-- sg:RemoveCard(c)
	-- ct=ct-ctfix
	-- return res
-- end
-- function Auxiliary.XSynMixCheckGoal(tp,sg,minc,ct,syncard,sg1,smat,gc,mgchk)
	-- if ct<minc then return false end
	-- local g=sg:Clone()
	-- g:Merge(sg1)
	-- if Duel.GetLocationCountFromEx(tp,tp,g,syncard)<=0 then return false end
	-- if gc and not gc(g) then return false end
	-- if smat and not g:IsContains(smat) then return false end
	-- if not Auxiliary.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL) then return false end
	
	-- -- local ctfix=0
	-- -- local gg=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MATERIAL_MULTIPLE)
	-- -- if #gg>0 then
		-- -- for c in aux.Next(gg) do
			-- -- if c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE) then
				-- -- local egroup={c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)}
				-- -- local safelock=false
				-- -- for _,ce in ipairs(egroup) do
					-- -- if safelock then break end
					-- -- if ce and (not ce:GetTarget() or ce:GetTarget()(syncard)) and ((type(ce:GetValue())=="function" and ce:GetValue()(c,nil,minc,nil,syncard)>1) or ce:GetValue()>1) then
						-- -- local skip=(type(ce:GetValue())=="function") and ce:GetValue()(c,f,minc,maxc,syncard) or ce:GetValue()
						-- -- ctfix=ctfix+skip-1
						-- -- safelock=true
					-- -- end
				-- -- end
			-- -- end
		-- -- end
	-- -- end
			
	-- if not g:CheckWithSumEqual(Card.GetSynchroLevel,syncard:GetLevel(),g:GetCount(),g:GetCount(),syncard)
		-- and (not g:IsExists(Card.IsHasEffect,1,nil,89818984)
		-- or not g:CheckWithSumEqual(Auxiliary.GetSynchroLevelFlowerCardian,syncard:GetLevel(),g:GetCount(),g:GetCount(),syncard))
		-- then return false end
	-- local hg=g:Filter(Card.IsLocation,nil,LOCATION_HAND):Filter(Card.IsControler,nil,tp)
	-- local hct=hg:GetCount()
	-- if hct>0 and not mgchk then
		-- local found=false
		-- for c in aux.Next(g) do
			-- local he,hf,hmin,hmax=c:GetHandSynchro()
			-- if he then
				-- found=true
				-- if hf and hg:IsExists(Auxiliary.SynLimitFilter,1,c,hf,he,syncard) then return false end
				-- if (hmin and hct<hmin) or (hmax and hct>hmax) then return false end
			-- end
		-- end
		-- if not found then return false end
	-- end
	-- local eg1=g:Filter(Card.IsLocation,nil,LOCATION_SZONE+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA+LOCATION_REMOVED):Filter(Card.IsControler,nil,tp):Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MATERIAL_EXTRA)
	-- local eg2=g:Filter(Card.IsLocation,nil,LOCATION_SZONE+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA+LOCATION_REMOVED+LOCATION_HAND):Filter(Card.IsControler,nil,1-tp):Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MATERIAL_EXTRA)
	-- eg1:Merge(eg2)
	-- local ect=eg1:GetCount()
	-- if ect>0 and not mgchk then
		-- local found=false
		-- for c in aux.Next(g) do
			-- local egroup={c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_EXTRA)}
			-- local found=false
			-- for _,ce in ipairs(egroup) do
				-- if ce then
					-- local hf,hmin,hmax=ce:GetValue(),target_range_table[ce][1],target_range_table[ce][2]
					-- found=true
					-- if hf and hg:IsExists(Auxiliary.SynLimitFilter,1,c,hf,ce,syncard) then return false end
					-- if (hmin and ect<hmin) or (hmax and ect>hmax) then return false end
				-- end
			-- end
		-- end
		-- if not found then return false end
	-- end
	-- for c in aux.Next(g) do
		-- local le,lf,lloc,lmin,lmax=c:GetTunerLimit()
		-- if le then
			-- local lct=g:GetCount()-1
			-- if lloc then
				-- local llct=g:FilterCount(Card.IsLocation,c,lloc)
				-- if llct~=lct then return false end
			-- end
			-- if lf and g:IsExists(Auxiliary.SynLimitFilter,1,c,lf,le,syncard) then return false end
			-- if (lmin and lct<lmin) or (lmax and lct>lmax) then return false end
		-- end
	-- end
	-- return true
-- end
-- function Auxiliary.XSynMixTarget(f,minc,maxc,gc,...)
	-- local fx={...}
	-- return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg1,min,max)
				-- local minc=minc
				-- local maxc=maxc
				-- if min then
					-- if min>minc then minc=min end
					-- if max<maxc then maxc=max end
					-- if minc>maxc then return false end
				-- end
				-- local g=Group.CreateGroup()
				-- g:KeepAlive()
				-- local mg
				-- if mg1 then
					-- mg=mg1
				-- else
					-- mg=Auxiliary.XGetSynMaterials(tp,c)
				-- end
				-- if smat~=nil then mg:AddCard(smat) end
				-- if #fx>0 then
					-- local fct=#fx
					-- for index=1,#fx do
						-- if index>fct then break end
						-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
						-- local cc=mg:FilterSelect(tp,Auxiliary.XSynMixFilterRecursive,1,1,g,f,minc,maxc,c,mg,smat,gc,nil,g,index,table.unpack(fx)):GetFirst()
						-- local indexskip,safelock=1,false
						-- if cc:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE) then
							-- local egroup={cc:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)}
							-- for _,ce in ipairs(egroup) do
								-- if safelock then break end
								-- if ce and (not ce:GetTarget() or ce:GetTarget()(c)) and ((type(ce:GetValue())=="function" and ce:GetValue()(cc,f,minc,maxc,c)>1) or ce:GetValue()>1) then
									-- local skip=(type(ce:GetValue())=="function") and ce:GetValue()(cc,f,minc,maxc,c) or ce:GetValue()
									-- local check=0
									-- for i=1,#fx do
										-- if fx[i]~=nil and (not fx[i] or fx[i](cc,c)) then
											-- check=check+1
										-- end
									-- end
									-- if check>=skip then
										-- fct=fct-skip+1
										-- safelock=true
									-- end
								-- end
							-- end
						-- end
						-- g:AddCard(cc)
					-- end
				-- end
				-- local gf=Group.CreateGroup()
				-- local fct=maxc-1
				-- for i=0,maxc-1 do
					-- if i>fct then break end
					-- local mg2=mg:Clone()
					-- if f then
						-- mg2=mg2:Filter(f,g,c)
					-- else
						-- mg2:Sub(g)
					-- end
					-- local cg=mg2:Filter(Auxiliary.XSynMixCheckRecursive,gf,tp,gf,mg2,i,minc,maxc,c,g,smat,gc)
					-- if cg:GetCount()==0 then break end
					-- local minct=1
					-- if Auxiliary.SynMixCheckGoal(tp,gf,minc,i,c,g,smat,gc) then
						-- minct=0
					-- end
					-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
					-- local tg=cg:Select(tp,minct,1,nil)
					-- local cc=tg:GetFirst()
					-- local indexskip,safelock=1,false
					-- if cc:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE) then
						-- local egroup={cc:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)}
						-- for _,ce in ipairs(egroup) do
							-- if safelock then break end
							-- if ce and (not ce:GetTarget() or ce:GetTarget()(c)) and ((type(ce:GetValue())=="function" and ce:GetValue()(cc,f,minc,maxc,c)>1) or ce:GetValue()>1) then
								-- local skip=(type(ce:GetValue())=="function") and ce:GetValue()(cc,f,minc,maxc,c) or ce:GetValue()
								-- fct=fct-skip+1
								-- safelock=true
							-- end
						-- end
					-- end
					-- if tg:GetCount()==0 then break end
					-- gf:Merge(tg)
				-- end
				-- g:Merge(gf)
				-- if g:GetCount()>0 then
					-- g:KeepAlive()
					-- e:SetLabelObject(g)
					-- return true
				-- else return false end
			-- end
-- end
-- function Auxiliary.XSynMixOperation(f,minct,maxc,gc,...)
	-- return	function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg,min,max)
				-- local g=e:GetLabelObject()
				-- c:SetMaterial(g)
				-- Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
				-- g:DeleteGroup()
			-- end
-- end
-----------------

--EFFECT TABLES
GLOBAL_EFFECT_RESET	= 92839884
global_override_reason_effect_check = false
if not global_manually_resetted_effects_table then global_manually_resetted_effects_table={} end
if not global_resetted_card_effects_table then global_resetted_card_effects_table={} end
if not global_resetted_duel_effects_table then global_resetted_duel_effects_table={} end

local _Reset = Effect.Reset

Effect.Reset = function(e)
	if e:GLGetReset()==0 then
		global_manually_resetted_effects_table[e]=true
		return _Reset(e)
	else
		local reset1={e:GetHandler():IsHasEffect(GLOBAL_EFFECT_RESET)}
		local reset2={Duel.IsPlayerAffectedByEffect(e:GetOwnerPlayer(),GLOBAL_EFFECT_RESET)}
		for _,r in ipairs(reset1) do
			local obj=r:GetLabelObject()
			if obj and obj==e then
				_Reset(r)
			end
		end
		for _,r in ipairs(reset2) do
			local obj=r:GetLabelObject()
			if obj and obj==e then
				_Reset(r)
			end
		end
		
		return _Reset(e)
	end
end
function Effect.WasReset(e,c)
	if global_manually_resetted_effects_table[e]==true then
		global_manually_resetted_effects_table[e]=nil
		return true
	end
	if e:GLGetReset()==0 then return false end
	if not c then
		if e:IsHasProperty(EFFECT_FLAG_FIELD_ONLY) then
			c=e:GetOwnerPlayer()
		else
			c=e:GetHandler()
		end
	end
	local reset
	if aux.GetValueType(c)=="Card" then
		reset={c:IsHasEffect(GLOBAL_EFFECT_RESET)}
	else
		reset={Duel.IsPlayerAffectedByEffect(e:GetOwnerPlayer(),GLOBAL_EFFECT_RESET)}
	end
	for _,r in ipairs(reset) do
		local obj=r:GetLabelObject()
		if obj and obj==e then
			return false
		end
	end
	
	return true
end
function Auxiliary.MarkResettedEffect(c,pos)
	if aux.GetValueType(c)=="Card" then
		global_resetted_card_effects_table[c]=pos
	else
		global_resetted_duel_effects_table[c]=pos
	end
end
function Auxiliary.DeleteResettedEffects(c)
	if aux.GetValueType(c)=="Card" and global_resetted_card_effects_table[c] then
		local pos=global_resetted_card_effects_table[c]
		if pos and pos~=0 then
			table.remove(global_card_effect_table[c],pos)
		end
		global_resetted_card_effects_table[c]=0
	else
		local pos=global_resetted_duel_effects_table[c]
		if pos and pos~=0 then
			table.remove(global_duel_effect_table[c],pos)
		end
		global_resetted_duel_effects_table[c]=0
	end
end

--Global Card Effect Table
EVENT_CHAIN_CREATED = 39419

Auxiliary.AuraEffects={}

Auxiliary.ContinuousEffects={}

Auxiliary.SpSummonProcCard  = nil
Auxiliary.SpSummonProcGCard = nil
Auxiliary.PreventCannotApplyConditionCheckLoop = false
FLAG_SPSUMMON_PROC = 62613309

function Card.GetEffects(c)
	local eset=global_card_effect_table[c]
	if not eset then return {} end
	local ct=#eset
	for i = ct,1,-1 do
		local e=eset[i]
		if e and e:WasReset(c) then
			table.remove(global_card_effect_table[c],i)
		end
	end
	return global_card_effect_table[c]
end
function Duel.GetEffects(p)
	local eset=global_duel_effect_table[p]
	if not eset then return {} end
	local ct=#eset
	for i = ct,1,-1 do
		local e=eset[i]
		if e and e:WasReset(p) then
			table.remove(global_duel_effect_table[p],i)
			local typ,code=e:GetType(),e:GetCode()
			if typ&EFFECT_TYPE_ACTIONS==0 then
				for i=#aux.AuraEffects[code],1,-1 do
					if aux.AuraEffects[code][i]==e then
						table.remove(aux.AuraEffects[code],i)
					end
				end
			end
			if typ&EFFECT_TYPE_CONTINUOUS~=0 then
				for i=#aux.ContinuousEffects[code],1,-1 do
					if aux.ContinuousEffects[code][i]==e then
						table.remove(aux.ContinuousEffects[code],i)
					end
				end
			end
		end
	end
	return global_duel_effect_table[p]
end
function Duel.GetAuraEffects(code)
	local eset=aux.AuraEffects[code]
	if not eset then return {} end
	local ct=#eset
	for i = ct,1,-1 do
		local e=eset[i]
		if e and e:WasReset() then
			table.remove(aux.AuraEffects[code],i)
		end
	end
	return aux.AuraEffects[code]
end

if not global_card_effect_table_global_check then
	global_card_effect_table_global_check=true
	global_card_effect_table={}
	Card.register_global_card_effect_table = Card.RegisterEffect
	function Card:RegisterEffect(e,forced)
		if not global_card_effect_table[self] then global_card_effect_table[self]={} end
		table.insert(global_card_effect_table[self],e)
		-- local cid=self:GetOriginalCode()
		
		-- if #global_card_effect_table[self]==1 then
			-- local mt=getmetatable(self)
			-- if LISTED_NAMES[cid] and not self.checked_card_code_list then
				-- if self.card_code_list==nil then
					-- mt.card_code_list={}
					-- for _,code in ipairs(LISTED_NAMES[cid]) do
						-- if code==0 then
							-- mt.card_code_list[cid]=true
						-- else
							-- mt.card_code_list[code]=true
						-- end
					-- end
				-- else
					-- for _,code in ipairs(LISTED_NAMES[cid]) do
						-- if code==0 then
							-- self.card_code_list[cid]=true
						-- else
							-- self.card_code_list[code]=true
						-- end
					-- end
				-- end
				-- mt.checked_card_code_list=true
			-- end
		-- end
		
		local reset,rct=e:GLGetReset()
		if reset~=0 then 					
			local r=Effect.CreateEffect(self)
			r:SetType(EFFECT_TYPE_SINGLE)
			r:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			r:SetCode(GLOBAL_EFFECT_RESET)
			r:SetLabelObject(e)
			r:SetReset(reset,rct)
			Card.register_global_card_effect_table(self,r,true)							
		end
		
		local typ,code=e:GetType(),e:GetCode()
		
		local IsSingleOrField=typ==EFFECT_TYPE_SINGLE or typ==EFFECT_TYPE_FIELD
		local IsInherentSummonProc=code==EFFECT_SPSUMMON_PROC or code==EFFECT_SPSUMMON_PROC_G
		local IsHasExceptionType=typ==EFFECT_TYPE_XMATERIAL or typ==EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD or typ&EFFECT_TYPE_GRANT~=0
		
		--IMPLEMENT EFFECT_CANNOT_APPLY
		if (typ&(EFFECT_TYPE_ACTIONS)==0 or typ&EFFECT_TYPE_CONTINUOUS==EFFECT_TYPE_CONTINUOUS) and (typ~=EFFECT_TYPE_SINGLE or e:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)) and (not e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) or not e:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE)) then
			local cond=e:GetCondition()
			local newcond =	function(E,...)
								local x={...}
								local tp=(#x>0 and type(x[1])=="number" and (x[1]==0 or x[1]==1)) and x[1] or E:GetHandlerPlayer()
								
								local c=E:GetHandler()
								local looping=aux.PreventCannotApplyConditionCheckLoop
								if not aux.PreventCannotApplyConditionCheckLoop then
									aux.PreventCannotApplyConditionCheckLoop=true
								end
								if not looping then
									if c:IsHasEffect(EFFECT_CANNOT_APPLY) then
										for _,ce in ipairs({c:IsHasEffect(EFFECT_CANNOT_APPLY)}) do
											if ce~=E then
												aux.PreventCannotApplyConditionCheckLoop=false
												return false
											end
										end
									end
								
									if Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_APPLY) then
										for _,ce in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_APPLY)}) do
											local val=ce:GetValue()
											if ce~=E and (not val or val(ce,E,tp,c)) then
												aux.PreventCannotApplyConditionCheckLoop=false
												return false
											end
										end
									end
									aux.PreventCannotApplyConditionCheckLoop=false
								end
								return not cond or cond(E,...)
							end
			e:SetCondition(newcond)
		end
		
		--ADD CONTINUOUS EFFECTS TO TABLE
		if typ&EFFECT_TYPE_CONTINUOUS~=0 then
			if not aux.ContinuousEffects[code] then
				aux.ContinuousEffects[code]={}
			end
			table.insert(aux.ContinuousEffects[code],e)
		end
		
		--MODIFY PASSIVE EFFECTS
		if typ&(EFFECT_TYPE_ACTIONS)==0 then
			if not aux.AuraEffects[code] then
				aux.AuraEffects[code]={}
			end
			table.insert(aux.AuraEffects[code],e)
			local e = e:IsHasType(EFFECT_TYPE_GRANT) and e:GetLabelObject() or e
			
			if code==EFFECT_SPSUMMON_PROC then
				local cond=e:GetCondition()
				if cond then
					e:SetCondition(function(E,C,...)
						if C==nil then return true end
						aux.SpSummonProcCard=C
						aux.SpSummonProcGCard=nil
						local res=cond(E,C,...)
						aux.SpSummonProcCard=nil
						return res
					end)
				end
				
				local op=e:GetOperation()
				if not op then
					e:SetOperation(function(E,TP,EG,EP,EV,RE,R,RP,C)
						C:RegisterFlagEffect(FLAG_SPSUMMON_PROC,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1)
					end)
				else
					e:SetOperation(function(E,TP,EG,EP,EV,RE,R,RP,C,...)
						C:RegisterFlagEffect(FLAG_SPSUMMON_PROC,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1)
						return op(E,TP,EG,EP,EV,RE,R,RP,C,...)
					end)
				end
				
				local val=e:GetValue()
				if not val then
					e:SetValue(function(E,C)
						aux.SpSummonProcCard=C
						aux.SpSummonProcGCard=nil
						local sumtype,zones=nil,0xff
						return sumtype,zones
					end)
				elseif type(val)=="number" then
					e:SetValue(function(E,C)
						aux.SpSummonProcCard=C
						aux.SpSummonProcGCard=nil
						local sumtype,zones=val,0xff
						return sumtype,zones
					end)
				elseif type(val)=="function" then
					e:SetValue(function(E,C,...)
						aux.SpSummonProcCard=C
						aux.SpSummonProcGCard=nil
						local sumtype,zones=val(E,C,...)
						return sumtype,zones
					end)
				end
			
			elseif code==EFFECT_SPSUMMON_PROC_G then
				local op=e:GetOperation()
				if op then
					e:SetOperation(function(E,TP,EG,EP,EV,RE,R,RP,C,SG,OG,...)
						aux.SpSummonProcGCard=C
						local res=op(E,TP,EG,EP,EV,RE,R,RP,C,SG,OG,...)
						return res
					end)
				end
			
			elseif code==EFFECT_UPDATE_LEVEL or code==EFFECT_CHANGE_LEVEL then
				local ce=e:Clone()
				if code==EFFECT_UPDATE_LEVEL then
					ce:SetCode(EFFECT_UPDATE_RANK)
				else
					ce:SetCode(EFFECT_CHANGE_RANK)
				end
				if e:IsHasType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_XMATERIAL) then
					local cond=e:GetCondition()
					ce:SetCondition(function(eff) return (not cond or cond(eff)) and eff:GetHandler():IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) end)
				elseif e:IsHasType(EFFECT_TYPE_EQUIP) then
					local cond=e:GetCondition()
					ce:SetCondition(function(eff) return (not cond or cond(eff)) and eff:GetHandler():GetEquipTarget():IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) end)
				elseif e:IsHasType(EFFECT_TYPE_FIELD) then
					local tg=e:GetTarget()
					ce:SetTarget(function(eff,c) return (not tg or tg(eff,c)) and c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) end)
				end
				Card.register_global_card_effect_table(self,ce,forced)
			
			elseif code==EFFECT_DISABLE or code==EFFECT_DISABLE_EFFECT or code==EFFECT_DISABLE_CHAIN or code==EFFECT_DISABLE_TRAPMONSTER then
				if typ==EFFECT_TYPE_SINGLE then
					local cond=e:GetCondition()
					if not cond then
						e:SetCondition(aux.GlitchyCannotDisableCon())
					else
						e:SetCondition(aux.GlitchyCannotDisableCon(cond))
					end
				elseif typ==EFFECT_TYPE_FIELD then
					local tg=e:GetTarget()
					if not tg then
						e:SetTarget(aux.GlitchyCannotDisable())
					else
						e:SetTarget(aux.GlitchyCannotDisable(tg))
					end
				end
				
			elseif code==EFFECT_EXTRA_SUMMON_COUNT or code==EFFECT_EXTRA_SET_COUNT then
				local s,o=e:GLGetTargetRange()
				if s~=0 and s&LOCATION_GRAVE==0 then
					s=s|LOCATION_GRAVE
				end
				if o~=0 and o&LOCATION_GRAVE==0 then
					o=o|LOCATION_GRAVE
				end
				e:SetTargetRange(s,o)
				
			elseif code==EFFECT_UPDATE_ATTACK or code==EFFECT_SET_ATTACK or code==EFFECT_SET_ATTACK_FINAL or code==EFFECT_SWAP_AD then
				if e:IsHasType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_XMATERIAL) then
					if e:IsHasType(EFFECT_TYPE_SINGLE) and self:IsHasEffect(EFFECT_GLITCHY_CANNOT_CHANGE_ATK) then
						for _,ce in ipairs({self:IsHasEffect(EFFECT_GLITCHY_CANNOT_CHANGE_ATK)}) do
							if ce and aux.GetValueType(ce)=="Effect" and ce.GetLabel then
								local val=ce:GetValue()
								if not val or val(ce,e,REASON_EFFECT) then
									e:Reset()
									return false
								end
							end
						end
					end
					local cond=e:GetCondition()
					local newcond =	function(e,...)
										if code==EFFECT_UPDATE_ATTACK or code==EFFECT_SET_ATTACK or code==EFFECT_SET_ATTACK_FINAL or code==EFFECT_SWAP_AD then
											for _,ce in ipairs({e:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_CHANGE_ATK)}) do
												if ce and aux.GetValueType(ce)=="Effect" and ce.GetLabel then
													local val=ce:GetValue()
													if not val or val(ce,e,REASON_EFFECT) then
														return false
													end
												end
											end
										end
										return not cond or cond(e,...)
									end
					e:SetCondition(newcond)
				elseif e:IsHasType(EFFECT_TYPE_EQUIP) then
					local cond=e:GetCondition()
					local newcond =	function(e,...)
										if code==EFFECT_UPDATE_ATTACK or code==EFFECT_SET_ATTACK or code==EFFECT_SET_ATTACK_FINAL or code==EFFECT_SWAP_AD then
											for _,ce in ipairs({e:GetHandler():GetEquipTarget():IsHasEffect(EFFECT_GLITCHY_CANNOT_CHANGE_ATK)}) do
												if ce and aux.GetValueType(ce)=="Effect" and ce.GetLabel then
													local val=ce:GetValue()
													if not val or val(ce,e,REASON_EFFECT) then
														return false
													end
												end
											end
										end
										return not cond or cond(e,...)
									end
					e:SetCondition(newcond)
				elseif e:IsHasType(EFFECT_TYPE_FIELD) then
					local tg=e:GetTarget()
					local newtarg =	function(e,c,...)
										if code==EFFECT_UPDATE_ATTACK or code==EFFECT_SET_ATTACK or code==EFFECT_SET_ATTACK_FINAL or code==EFFECT_SWAP_AD then
											for _,ce in ipairs({c:IsHasEffect(EFFECT_GLITCHY_CANNOT_CHANGE_ATK)}) do
												if ce and aux.GetValueType(ce)=="Effect" and ce.GetLabel then
													local val=ce:GetValue()
													if not val or val(ce,e,REASON_EFFECT) then
														return false
													end
												end
											end
										end
										return not tg or tg(e,c,...)
									end
					e:SetTarget(newtarg)
				end
			end
		end
		
		local condition,cost,tg,op,val=e:GetCondition(),e:GetCost(),e:GetTarget(),e:GetOperation(),e:GetValue()
		if condition and not IsHasExceptionType then	
			local newcon =	function(...)
								local x={...}
								local previous_sre=self_reference_effect
								self_reference_effect=x[1]
								current_triggering_player = (#x>1 and not IsSingleOrField) and x[2] or x[1]:GetHandlerPlayer()
								if global_override_reason_effect_check then
									current_reason_effect = #x>=6 and x[6] or nil
									if aux.GetValueType(current_reason_effect)=="Effect" and current_reason_effect:IsHasCheatCode(GECC_OVERRIDE_REASON_EFFECT) then
										x[6]=current_reason_effect:GetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT)
										current_reason_effect=x[6]
									end
								end
								local res=condition(table.unpack(x))
								self_reference_effect=previous_sre
								return res
							end
			e:SetCondition(newcon)
		end
		if cost and not IsHasExceptionType then
			local newcost =	function(...)
								local x={...}
								local previous_sre=self_reference_effect
								self_reference_effect=x[1]
								current_triggering_player = (#x>1 and not IsSingleOrField) and x[2] or x[1]:GetHandlerPlayer()
								if global_override_reason_effect_check then
									current_reason_effect = #x>=6 and x[6] or nil
									if aux.GetValueType(current_reason_effect)=="Effect" and current_reason_effect:IsHasCheatCode(GECC_OVERRIDE_REASON_EFFECT) then
										x[6]=current_reason_effect:GetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT)
										current_reason_effect=x[6]
									end
								end
								if #x>=9 and x[9]~=0 then
									Duel.RaiseEvent(x[1]:GetHandler(),EVENT_CHAIN_CREATED,x[1],0,x[2],x[2],Duel.GetCurrentChain())
								end
								local res=cost(table.unpack(x))
								self_reference_effect=previous_sre
								return res
							end
			e:SetCost(newcost)
		end
		if tg and not IsHasExceptionType then
			local newtg =	function(...)
								local x={...}
								local previous_sre=self_reference_effect
								self_reference_effect=x[1]
								current_triggering_player = (#x>1 and not IsSingleOrField) and x[2] or x[1]:GetHandlerPlayer()
								if global_override_reason_effect_check then
									current_reason_effect = #x>=6 and x[6] or nil
									if aux.GetValueType(current_reason_effect)=="Effect" and current_reason_effect:IsHasCheatCode(GECC_OVERRIDE_REASON_EFFECT) then
										x[6]=current_reason_effect:GetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT)
										current_reason_effect=x[6]
									end
								end
								if #x>=9 and x[9]~=0 and (#x<10 or not x[10]) and (not x[1]:GetCost() or not x[1]:IsCostChecked()) then
									Duel.RaiseEvent(x[1]:GetHandler(),EVENT_CHAIN_CREATED,x[1],0,x[2],x[2],Duel.GetCurrentChain())
								end
								local res=tg(table.unpack(x))
								self_reference_effect=previous_sre
								return res
							end
			e:SetTarget(newtg)
		end
		if op and not IsHasExceptionType then
			local newop =	function(...)
								local x={...}
								local previous_sre=self_reference_effect
								self_reference_effect = x[1]
								current_triggering_player = (#x>1 and not IsSingleOrField) and x[2] or x[1]:GetHandlerPlayer()
								if global_override_reason_effect_check then
									current_reason_effect = #x>=6 and x[6] or nil
									if aux.GetValueType(current_reason_effect)=="Effect" and current_reason_effect:IsHasCheatCode(GECC_OVERRIDE_REASON_EFFECT) then
										x[6]=current_reason_effect:GetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT)
										current_reason_effect=x[6]
									end
								end
								local res=op(table.unpack(x))
								self_reference_effect=previous_sre
								return res
							end
			e:SetOperation(newop)
		end
		if val then
			if type(val)=="function" and not IsHasExceptionType then
				local newval =	function(...)
									local x={...}
									local previous_sre=self_reference_effect
									if aux.GetValueType(x[1])=="Effect" then
										self_reference_effect = x[1]
										current_triggering_player = self_reference_effect:GetHandlerPlayer()
									end
									local res={val(...)}
									self_reference_effect=previous_sre
									return table.unpack(res)
								end
				e:SetValue(newval)
				
			elseif (code==EFFECT_CHANGE_CODE or code==EFFECT_CHANGE_CODE) and e:GetOwner():IsHasEffect(EFFECT_GLITCHY_HACK_CODE) then
				local ceg={e:GetOwner():IsHasEffect(EFFECT_GLITCHY_HACK_CODE)}
				local ce=ceg[#ceg]
				local val=ce:GetValue()
				local re=ce:GetLabelObject()
				if val and (not re or re and self_reference_effect and self_reference_effect==re) then
					e:SetValue(val)
				end
			end
		end
		
		return Card.register_global_card_effect_table(self,e,forced)
	end
end

function Auxiliary.OperationRegistrationProcedure(e,tp,eg,ep,ev,re,r,rp)
	self_reference_effect = e
	current_triggering_player = tp
	if global_override_reason_effect_check then
		current_reason_effect = re
		if aux.GetValueType(current_reason_effect)=="Effect" and current_reason_effect:IsHasCheatCode(GECC_OVERRIDE_REASON_EFFECT) then
			re=current_reason_effect:GetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT)
			current_reason_effect=re
		end
	end
	return e,tp,eg,ep,ev,re,r,rp
end
function Auxiliary.EndRegistrationProcedure(e,tp,eg,ep,ev,re,r,rp)
	self_reference_effect=previous_sre
end

--Global Card Effect Table (for Duel.RegisterEffect)
if not global_duel_effect_table_global_check then
	global_duel_effect_table_global_check=true
	global_duel_effect_table={}
	Duel.register_global_duel_effect_table = Duel.RegisterEffect
	Duel.RegisterEffect = function(e,tp)
							if not global_duel_effect_table[tp] then global_duel_effect_table[tp]={} end
							table.insert(global_duel_effect_table[tp],e)
							
							local reset,rct=e:GLGetReset()
							if reset~=0 then 
								if not global_reset_duel_effect_table then
									global_reset_duel_effect_table={}
								end							
								local r=Effect.CreateEffect(e:GetOwner())
								r:SetType(EFFECT_TYPE_FIELD)
								r:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
								r:SetCode(GLOBAL_EFFECT_RESET)
								r:SetTargetRange(1,0)
								r:SetLabelObject(e)
								r:SetReset(reset,rct)
								r:GetOwnerPlayer(tp)
								Duel.register_global_duel_effect_table(r,tp)
								global_reset_duel_effect_table[e]=true								
							end
							
							local typ,code=e:GetType(),e:GetCode()
							
							local IsSingleOrField=typ==EFFECT_TYPE_SINGLE or typ==EFFECT_TYPE_FIELD
							local IsInherentSummonProc=code==EFFECT_SPSUMMON_PROC or code==EFFECT_SPSUMMON_PROC_G
							local IsHasExceptionType=typ==EFFECT_TYPE_XMATERIAL or typ==EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD or typ&EFFECT_TYPE_GRANT~=0
							
							--ADD CONTINUOUS EFFECTS TO TABLE
							if typ&EFFECT_TYPE_CONTINUOUS~=0 then
								if not aux.ContinuousEffects[code] then
									aux.ContinuousEffects[code]={}
								end
								table.insert(aux.ContinuousEffects[code],e)
							end
							
							if typ&(EFFECT_TYPE_ACTIONS)==0 then
								if not aux.AuraEffects[code] then
									aux.AuraEffects[code]={}
								end
								table.insert(aux.AuraEffects[code],e)
								local e = e:IsHasType(EFFECT_TYPE_GRANT) and e:GetLabelObject() or e
								
								if code==EFFECT_UPDATE_LEVEL or code==EFFECT_CHANGE_LEVEL then
									local ce=e:Clone()
									if code==EFFECT_UPDATE_LEVEL then
										ce:SetCode(EFFECT_UPDATE_RANK)
									else
										ce:SetCode(EFFECT_CHANGE_RANK)
									end
									if e:IsHasType(EFFECT_TYPE_FIELD) then
										local tg=e:GetTarget()
										ce:SetTarget(function(eff,c) return (not tg or tg(eff,c)) and c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY) end)
									end
									Duel.register_global_duel_effect_table(ce,tp)	
								end
									
								if code==EFFECT_EXTRA_SUMMON_COUNT or code==EFFECT_EXTRA_SET_COUNT then
									local s,o=e:GLGetTargetRange()
									if s and s~=0 and s&LOCATION_GRAVE==0 then
										s=s|LOCATION_GRAVE
									end
									if o and o~=0 and o&LOCATION_GRAVE==0 then
										o=o|LOCATION_GRAVE
									end
								
								elseif code==EFFECT_UPDATE_ATTACK or code==EFFECT_SET_ATTACK or code==EFFECT_SET_ATTACK_FINAL or code==EFFECT_SWAP_AD then
									if e:IsHasType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_XMATERIAL) then
										local cond=e:GetCondition()
										local newcond =	function(e,...)
															if code==EFFECT_UPDATE_ATTACK or code==EFFECT_SET_ATTACK or code==EFFECT_SET_ATTACK_FINAL or code==EFFECT_SWAP_AD then
																for _,ce in ipairs({e:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_CHANGE_ATK)}) do
																	if ce and aux.GetValueType(ce)=="Effect" and ce.GetLabel then
																		local val=ce:GetValue()
																		if not val or val(ce,e,REASON_EFFECT) then
																			return false
																		end
																	end
																end
															end
															return not cond or cond(e,...)
														end
										e:SetCondition(newcond)
									elseif e:IsHasType(EFFECT_TYPE_EQUIP) then
										local cond=e:GetCondition()
										local newcond =	function(e,...)
															if code==EFFECT_UPDATE_ATTACK or code==EFFECT_SET_ATTACK or code==EFFECT_SET_ATTACK_FINAL or code==EFFECT_SWAP_AD then
																for _,ce in ipairs({e:GetHandler():GetEquipTarget():IsHasEffect(EFFECT_GLITCHY_CANNOT_CHANGE_ATK)}) do
																	if ce and aux.GetValueType(ce)=="Effect" and ce.GetLabel then
																		local val=ce:GetValue()
																		if not val or val(ce,e,REASON_EFFECT) then
																			return false
																		end
																	end
																end
															end
															return not cond or cond(e,...)
														end
										e:SetCondition(newcond)
									elseif e:IsHasType(EFFECT_TYPE_FIELD) then
										local tg=e:GetTarget()
										local newtarg =	function(e,c,...)
															if code==EFFECT_UPDATE_ATTACK or code==EFFECT_SET_ATTACK or code==EFFECT_SET_ATTACK_FINAL or code==EFFECT_SWAP_AD then
																for _,ce in ipairs({c:IsHasEffect(EFFECT_GLITCHY_CANNOT_CHANGE_ATK)}) do
																	if ce and aux.GetValueType(ce)=="Effect" and ce.GetLabel then
																		local val=ce:GetValue()
																		if not val or val(ce,e,REASON_EFFECT) then
																			return false
																		end
																	end
																end
															end
															return not tg or tg(e,c,...)
														end
										e:SetTarget(newtarg)
									end
								end
							end
							
							
							local condition,cost,tg,op,val = e:GetCondition(),e:GetCost(),e:GetTarget(),e:GetOperation(),e:GetValue()
							if condition and not IsHasExceptionType then
								local newcon =	function(...)
													local x={...}
													local previous_sre=self_reference_effect
													self_reference_effect=x[1]
													current_triggering_player = (#x>1 and not IsSingleOrField) and x[2] or x[1]:GetHandlerPlayer()
													if global_override_reason_effect_check then
														current_reason_effect = #x>=6 and x[6] or nil
														if aux.GetValueType(current_reason_effect)=="Effect" and current_reason_effect:IsHasCheatCode(GECC_OVERRIDE_REASON_EFFECT) then
															x[6]=current_reason_effect:GetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT)
															current_reason_effect=x[6]
														end
													end
													local res=condition(table.unpack(x))
													self_reference_effect=previous_sre
													return res
												end
								e:SetCondition(newcon)
							end
							if cost and not IsHasExceptionType then
								local newcost =	function(...)
													local x={...}
													local previous_sre=self_reference_effect
													self_reference_effect=x[1]
													current_triggering_player = (#x>1 and not IsSingleOrField) and x[2] or x[1]:GetHandlerPlayer()
													if global_override_reason_effect_check then
														current_reason_effect = #x>=6 and x[6] or nil
														if aux.GetValueType(current_reason_effect)=="Effect" and current_reason_effect:IsHasCheatCode(GECC_OVERRIDE_REASON_EFFECT) then
															x[6]=current_reason_effect:GetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT)
															current_reason_effect=x[6]
														end
													end
													local res=cost(table.unpack(x))
													self_reference_effect=previous_sre
													return res
												end
								e:SetCost(newcost)
							end
							if tg and not IsHasExceptionType then
								local newtg =	function(...)
													local x={...}
													local previous_sre=self_reference_effect
													self_reference_effect=x[1]
													current_triggering_player = (#x>1 and not IsSingleOrField) and x[2] or x[1]:GetHandlerPlayer()
													if global_override_reason_effect_check then
														current_reason_effect = #x>=6 and x[6] or nil
														if aux.GetValueType(current_reason_effect)=="Effect" and current_reason_effect:IsHasCheatCode(GECC_OVERRIDE_REASON_EFFECT) then
															x[6]=current_reason_effect:GetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT)
															current_reason_effect=x[6]
														end
													end
													local res=tg(table.unpack(x))
													self_reference_effect=previous_sre
													return res
												end
								e:SetTarget(newtg)
							end
							if op and not IsHasExceptionType then
								local newop =	function(...)
													local x={...}
													local previous_sre=self_reference_effect
													self_reference_effect=x[1]
													current_triggering_player = (#x>1 and not IsSingleOrField) and x[2] or x[1]:GetHandlerPlayer()
													if global_override_reason_effect_check then
														current_reason_effect = #x>=6 and x[6] or nil
														if aux.GetValueType(current_reason_effect)=="Effect" and current_reason_effect:IsHasCheatCode(GECC_OVERRIDE_REASON_EFFECT) then
															x[6]=current_reason_effect:GetCheatCodeValue(GECC_OVERRIDE_REASON_EFFECT)
															current_reason_effect=x[6]
														end
													end
													local res=op(table.unpack(x))
													self_reference_effect=previous_sre
													return res
												end
								e:SetOperation(newop)
							end
							if val then
								if type(val)=="function" and not IsHasExceptionType then
									local newval =	function(...)
														local x={...}
														local previous_sre=self_reference_effect
														if aux.GetValueType(x[1])=="Effect" then
															self_reference_effect = x[1]
															current_triggering_player = self_reference_effect:GetHandlerPlayer()
														end
														local res={val(...)}
														self_reference_effect=previous_sre
														return table.unpack(res)
													end
									e:SetValue(newval)
								
								elseif (code==EFFECT_CHANGE_CODE or code==EFFECT_CHANGE_CODE) and e:GetOwner():IsHasEffect(EFFECT_GLITCHY_HACK_CODE) then
									local ceg={e:GetOwner():IsHasEffect(EFFECT_GLITCHY_HACK_CODE)}
									local ce=ceg[#ceg]
									local val=ce:GetValue()
									local re=ce:GetLabelObject()
									if val and (not re or re and self_reference_effect and self_reference_effect==re) then
										e:SetValue(val)
									end
								end
							end
							
							return Duel.register_global_duel_effect_table(e,tp)	
	end
end


----------------------------------------------------------------------------------------------------------------
--AUXS AND FUNCTIONS PORTED FROM EDOPRO (CAN BE EXPANDED FOR FACILITATING SCRIPT COMPATIBILITY BETWEEN THE SIMS)
----------------------------------------------------------------------------------------------------------------
function Card.HasLevel(c,general)
	if c:IsType(TYPE_MONSTER) then
		return (not c:IsOriginalType(TYPE_XYZ|TYPE_LINK|TYPE_TIMELEAP) or c:IsHasEffect(EFFECT_GRANT_LEVEL) or c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY))
			and not c:IsStatus(STATUS_NO_LEVEL)
	elseif general and c:IsOriginalType(TYPE_MONSTER) then
		return not (c:IsOriginalType(TYPE_XYZ|TYPE_LINK|TYPE_TIMELEAP) or c:IsStatus(STATUS_NO_LEVEL))
	end
	return false
end
function Card.CanAttack(c)
	return c:IsAttackable()
end

function Auxiliary.RegisterClientHint(card,property,tp,player1,player2,str,reset,ct)
	if not card then return end
	property=property or 0
	reset=reset or 0
	local eff=Effect.CreateEffect(card)
	eff:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT|property)
	eff:SetTargetRange(player1,player2)
	if str then
		eff:SetDescription(str)
	else
		eff:SetDescription(aux.Stringid(card:GetOriginalCode(),1))
	end
	eff:SetReset(RESET_PHASE+PHASE_END|reset,ct or 1)
	Duel.RegisterEffect(eff,tp)
	return eff
end
function Auxiliary.FilterBoolFunctionEx(f,value)
	return	function(target,scard,sumtype,tp)
				return f(target,value,scard,sumtype,tp)
			end
end
function Auxiliary.FilterBoolFunctionEx2(f,...)
	local params={...}
	return	function(target,scard,sumtype,tp)
				return f(target,scard,sumtype,tp,table.unpack(params))
			end
end
function Auxiliary.GlobalCheck(s,func)
	if not s.global_check then
		s.global_check=true
		func()
	end
end
--[[
Function to perform "Either add it to the hand or do X"
-card: affected card or group of cards to be moved;
-player: player performing the operation
-check: condition for the secondary action, if not provided the default action is "Send it to the GY";
oper: secondary action;
str: string to be used in the secondary option
]]
function Auxiliary.ToHandOrElse(card,player,check,oper,str,...)
	if card then
		if not check then check=Card.IsAbleToGrave end
		if not oper then oper=aux.thoeSend end
		if not str then str=1191 end
		local b1,b2=true,true
		if type(card)=="Group" then
			for ctg in aux.Next(card) do
				if not ctg:IsAbleToHand() then
					b1=false
				end
				if not check(ctg,...) then
					b2=false
				end
			end
		else
			b1=card:IsAbleToHand()
			b2=check(card,...)
		end
		local opt
		if b1 and b2 then
			opt=Duel.SelectOption(player,1190,str)
		elseif b1 then
			opt=Duel.SelectOption(player,1190)
		else
			opt=Duel.SelectOption(player,str)+1
		end
		if opt==0 then
			local res=Duel.SendtoHand(card,nil,REASON_EFFECT)
			if res~=0 then Duel.ConfirmCards(1-player,card) end
			return res
		else
			return oper(card,...)
		end
	end
end
function Auxiliary.thoeSend(card)
	return Duel.SendtoGrave(card,REASON_EFFECT)
end
--register for "Equip to this card by its effect"
function Auxiliary.EquipByEffectAndLimitRegister(c,e,tp,tc,code,mustbefaceup)
	local up=false or mustbefaceup
	if not Duel.Equip(tp,tc,c,up) then return false end
	--Add Equip limit
	if code then
		tc:RegisterFlagEffect(code,RESET_EVENT+RESETS_STANDARD,0,0)
	end
	local te=e:GetLabelObject()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(Auxiliary.EquipByEffectLimit)
	e1:SetLabelObject(te)
	tc:RegisterEffect(e1)
	return true
end
--check for Eyes Restrict equip limit
function Auxiliary.AddEREquipLimit(c,con,equipval,equipop,linkedeff,prop,resetflag,resetcount)
	local finalprop=EFFECT_FLAG_CANNOT_DISABLE
	if prop~=nil then
		finalprop=finalprop|prop
	end
	local e1=Effect.CreateEffect(c)
	if con then
		e1:SetCondition(con)
	end
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(finalprop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
	e1:SetCode(89785779)
	e1:SetLabelObject(linkedeff)
	if resetflag and resetcount then
		e1:SetReset(resetflag,resetcount)
	elseif resetflag then
		e1:SetReset(resetflag)
	end
	e1:SetValue(function(ec,c,tp) return equipval(ec,c,tp) end)
	e1:SetOperation(function(c,e,tp,tc) equipop(c,e,tp,tc) end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(finalprop&~EFFECT_FLAG_CANNOT_DISABLE,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
	e2:SetCode(89785779+EFFECT_EQUIP_LIMIT)
	if resetflag and resetcount then
		e2:SetReset(resetflag,resetcount)
	elseif resetflag then
		e2:SetReset(resetflag)
	end
	c:RegisterEffect(e2)
	linkedeff:SetLabelObject(e2)
end
--Checks whether the card is located at any of the sequences passed as arguments.
function Card.IsSequence(c,...)
	local arg={...}
	local seq=c:GetSequence()
	for _,v in ipairs(arg) do
		if seq==v then return true end
	end
	return false
end
--Used for checking the zone of a card (zone is the zone, tp is referencial player)
function Auxiliary.IsZone(c,zone,tp)
	local rzone = c:IsControler(tp) and (1 <<c:GetSequence()) or (1 << (16+c:GetSequence()))
	if c:IsSequence(5,6) then
		rzone = rzone | (c:IsControler(tp) and (1 << (16 + 11 - c:GetSequence())) or (1 << (11 - c:GetSequence())))
	end
	return (rzone & zone) > 0
end
function Card.IsInMainMZone(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 and (not tp or c:IsControler(tp))
end
function Card.IsInExtraMZone(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()>4 and (not tp or c:IsControler(tp))
end

function Duel.GetTargetCards()
	return Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToChain,nil)
end

function Auxiliary.ReleaseCostFilter(c,f,...)
	return c:IsFaceup() and c:IsReleasable() and c:IsHasEffect(59160188) 
		and (not f or f(c,table.unpack({...})))
end
function Auxiliary.ReleaseCheckSingleUse(sg,tp,exg)
	return #sg-#(sg-exg)<=1
end
function Auxiliary.ReleaseCheckMMZ(sg,tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		or sg:IsExists(aux.FilterBoolFunction(Card.IsInMainMZone,tp),1,nil)
end
function Auxiliary.ReleaseCheckTarget(sg,tp,exg,dg)
	return dg:IsExists(aux.TRUE,1,sg)
end
function Auxiliary.RelCheckRecursive(c,tp,sg,mg,exg,mustg,ct,minc,specialchk,...)
	sg:AddCard(c)
	ct=ct+1
	local res=Auxiliary.RelCheckGoal(tp,sg,exg,mustg,ct,minc,specialchk,table.unpack({...})) 
		or (ct<minc and mg:IsExists(Auxiliary.RelCheckRecursive,1,sg,tp,sg,mg,exg,mustg,ct,minc,specialchk,table.unpack({...})))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end		
function Auxiliary.RelCheckGoal(tp,sg,exg,mustg,ct,minc,specialchk,...)
	return ct>=minc and (not specialchk or specialchk(sg,tp,exg,table.unpack({...}))) and sg:Includes(mustg)
end
function Duel.CheckReleaseGroupCost(tp,f,ct,use_hand,specialchk,ex,...)
	local params={...}
	if not ex then ex=Group.CreateGroup() end
	if not specialchk then specialchk=Auxiliary.ReleaseCheckSingleUse else specialchk=Auxiliary.AND(specialchk,Auxiliary.ReleaseCheckSingleUse) end
	local g=Duel.GetReleaseGroup(tp,use_hand)
	if f then
		g=g:Filter(f,ex,table.unpack(params))
	else
		g=g-ex
	end
	local exg=Duel.GetMatchingGroup(Auxiliary.ReleaseCostFilter,tp,0,LOCATION_MZONE,g+ex,f,table.unpack(params))
	local mustg=g:Filter(function(c,tp)return c:IsHasEffect(EFFECT_EXTRA_RELEASE) and c:IsControler(1-tp)end,nil,tp)
	local mg=g+exg
	local sg=Group.CreateGroup()
	return mg:Includes(mustg) and mg:IsExists(Auxiliary.RelCheckRecursive,1,nil,tp,sg,mg,exg,mustg,0,ct,specialchk,table.unpack({...}))
end
function Duel.SelectReleaseGroupCost(tp,f,minc,maxc,use_hand,specialchk,ex,...)
	local params={...}
	if not ex then ex=Group.CreateGroup() end
	if not specialchk then specialchk=Auxiliary.ReleaseCheckSingleUse else specialchk=Auxiliary.AND(specialchk,Auxiliary.ReleaseCheckSingleUse) end
	local g=Duel.GetReleaseGroup(tp,use_hand)
	if f then
		g=g:Filter(f,ex,table.unpack(params))
	else
		g=g-ex
	end
	local exg=Duel.GetMatchingGroup(Auxiliary.ReleaseCostFilter,tp,0,LOCATION_MZONE,g+ex,f,table.unpack(params))
	local mg=g+exg
	local mustg=g:Filter(function(c,tp)return c:IsHasEffect(EFFECT_EXTRA_RELEASE) and c:IsControler(1-tp)end,nil,tp)
	local sg=Group.CreateGroup()
	local cancel=false
	sg:Merge(mustg)
	while #sg<maxc do
		local cg=mg:Filter(Auxiliary.RelCheckRecursive,sg,tp,sg,mg,exg,mustg,#sg,minc,specialchk,table.unpack({...}))
		if #cg==0 then break end
		cancel=#sg>=minc and #sg<=maxc and Auxiliary.RelCheckGoal(tp,sg,exg,mustg,#sg,minc,specialchk,table.unpack({...}))
		local tc=Group.SelectUnselect(cg,sg,tp,cancel,cancel,1,1)
		if not tc then break end
		if #mustg==0 or not mustg:IsContains(tc) then
			if not sg:IsContains(tc) then
				sg=sg+tc
			else
				sg=sg-tc
			end
		end
	end
	if #sg==0 then return sg end
	if #sg~=#(sg-exg) then
		--LoD is reset for the rest of the turn
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		Duel.Hint(HINT_CARD,0,fc:GetCode())
		fc:RegisterFlagEffect(59160188,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
	return sg
end
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--EDOPRO IMPORT: UNION PROCEDURE
--Procedure for Union monster equip/unequip
--c: Union monster
--f: Potential targets
--oldequip: Uses old rules for number of monster equiped (A monster can only by equipped with 1 Union monster at a time.)
--oldprotect: Uses old rules for destroy replacement (If the equipped monster would be destroyed, destroy this card instead.)
function Auxiliary.AddUnionProcedure(c,f,oldequip,oldprotect,range,quick)
	if oldprotect == nil then oldprotect = oldequip end
	local range = range and range or LOCATION_MZONE
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1068)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	if quick then
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
	else
		e1:SetType(EFFECT_TYPE_IGNITION)
	end
	e1:SetRange(range)
	e1:SetTarget(Auxiliary.UnionTarget(f,oldequip))
	e1:SetOperation(Auxiliary.UnionOperation(f))
	c:RegisterEffect(e1)
	--unequip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	if quick then
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
	else
		e2:SetType(EFFECT_TYPE_IGNITION)
	end
	e2:SetRange(LOCATION_SZONE)
	if oldequip then
		e2:SetCondition(Auxiliary.IsUnionState)
	end
	e2:SetTarget(Auxiliary.UnionSumTarget(oldequip))
	e2:SetOperation(Auxiliary.UnionSumOperation(oldequip))
	c:RegisterEffect(e2)
	--destroy sub
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	if oldprotect then
		e3:SetCondition(Auxiliary.IsUnionState)
	end
	e3:SetValue(Auxiliary.UnionReplace(oldprotect))
	c:RegisterEffect(e3)
	--eqlimit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UNION_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(Auxiliary.UnionLimit(f))
	c:RegisterEffect(e4)
	--auxiliary function compatibility
	if oldequip then
		local m=c:GetMetatable()
		m.old_union=true
	end
	return e1,e2,e3,e4
end
if not Card.CheckUnionTarget then
	Card.CheckUnionTarget=function(c,target)
		local ct1,ct2=c:GetUnionCount()
		return c:IsHasEffect(EFFECT_UNION_LIMIT) and (((not c:IsHasEffect(EFFECT_OLDUNION_STATUS)) or ct1 == 0)
			and ((not c:IsHasEffect(EFFECT_UNION_STATUS)) or ct2 == 0))
	
	end
end
function Auxiliary.UnionFilter(c,f,oldrule)
	local ct1,ct2=c:GetUnionCount()
	if c:IsFaceup() and (not f or f(c)) then
		if oldrule then
			return ct1==0
		else
			return ct2==0
		end
	else
		return false
	end
end
function Auxiliary.UnionTarget(f,oldrule)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local c=e:GetHandler()
		local code=c:GetOriginalCode()
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and Auxiliary.UnionFilter(c,f,oldrule) end
		if chk==0 then return e:GetHandler():GetFlagEffect(code)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingTarget(Auxiliary.UnionFilter,tp,LOCATION_MZONE,0,1,c,f,oldrule) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectTarget(tp,Auxiliary.UnionFilter,tp,LOCATION_MZONE,0,1,1,c,f,oldrule)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
		c:RegisterFlagEffect(code,RESET_EVENT+(RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE)+RESET_PHASE+PHASE_END,0,1)
	end
end
function Auxiliary.UnionOperation(f)
	return function (e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local tc=Duel.GetFirstTarget()
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		if not tc:IsRelateToEffect(e) or (f and not f(tc)) then
			Duel.SendtoGrave(c,REASON_EFFECT)
			return
		end
		if not Duel.Equip(tp,c,tc,false) then return end
		aux.SetUnionState(c)
	end
end
function Auxiliary.UnionSumTarget(oldrule)
	return function (e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local code=c:GetOriginalCode()
		local pos=POS_FACEUP
		if oldrule then pos=POS_FACEUP_ATTACK end
		if chk==0 then return c:GetFlagEffect(code)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,pos) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
		c:RegisterFlagEffect(code,RESET_EVENT+(RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE)+RESET_PHASE+PHASE_END,0,1)
	end
end
function Auxiliary.UnionSumOperation(oldrule)
	return function (e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		local pos=POS_FACEUP
		if oldrule then pos=POS_FACEUP_ATTACK end
		if Duel.SpecialSummon(c,0,tp,tp,true,false,pos)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
			and c:IsCanBeSpecialSummoned(e,0,tp,true,false,pos) then
			Duel.SendtoGrave(c,REASON_RULE)
		end
	end
end
function Auxiliary.UnionReplace(oldrule)
	return function (e,re,r,rp)
		if oldrule then
			return (r&REASON_BATTLE)~=0
		else
			return (r&REASON_BATTLE)~=0 or (r&REASON_EFFECT)~=0
		end
	end
end
function Auxiliary.UnionLimit(f)
	return function (e,c)
		return (not f or f(c)) or e:GetHandler():GetEquipTarget()==c
	end
end