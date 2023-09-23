--Custom Categories
CATEGORY_ZONE		  				= 0x1
CATEGORY_DISABLE_ZONE 				= 0x2
CATEGORY_PLACE_AS_CONTINUOUS_TRAP	= 0x4
CATEGORY_REDIRECT_ATTACK			= 0x8
CATEGORY_SET						= 0x10
CATEGORY_ACTIVATE					= 0x20
CATEGORY_ATTACH						= 0x40
CATEGORY_DETACH						= 0x80
CATEGORY_UPDATE_ATTRIBUTE			= 0x100
CATEGORY_UPDATE_RACE				= 0x200
CATEGORY_UPDATE_SETCODE				= 0x400
CATEGORY_LVCHANGE					= 0x800
CATEGORY_PAYLP						= 0x1000
CATEGORY_ACTIVATES_ON_NORMAL_SET	= 0x2000

CATEGORIES_ATKDEF			=	CATEGORY_ATKCHANGE|CATEGORY_DEFCHANGE
CATEGORIES_SEARCH 			= 	CATEGORY_SEARCH|CATEGORY_TOHAND
CATEGORIES_FUSION_SUMMON 	= 	CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON
CATEGORIES_TOKEN 			= 	CATEGORY_SPECIAL_SUMMON|CATEGORY_TOKEN

CATEGORY_FLAG_SELF					= 0x1
CATEGORY_FLAG_DELAYED_RESOLUTION	= 0x2

--Custom Effects
EFFECT_SET_SPSUMMON_LIMIT			= 39503

--Archetypes
ARCHE_CRYSTRON						= 0xea
ARCHE_GALAXY						= 0x7b
ARCHE_GALAXY_EYES					= 0x107b
ARCHE_NUMBER						= 0x48
ARCHE_NUMBER_C						= 0x1048
ARCHE_NUMBER_C39					= 0x5048
ARCHE_PHOTON						= 0x55
ARCHE_RUM							= 0x95
ARCHE_UTOPIA						= 0x107f
ARCHE_ZW							= 0x107e

--Custom Archetypes
CUSTOM_ARCHE_ZERO_HERO				= 0x1

--Custom Cards
ARCHE_FUSION		= 0x46
ARCHE_PANDEMONIUM	= 0xf80
ARCHE_BIGBANG		= 0xbba
ARCHE_HYPERDRIVE	= 0x660

ARCHE_ABYSSLYM			= 0x49c
ARCHE_AEONSTRIDE		= 0xae0
ARCHE_BOMBER_GOBLIN		= 0x30ac
ARCHE_DOOMSDAY_ARTIFICE	= 0x3a6
ARCHE_DREAMY_FOREST		= 0xd43
ARCHE_DREARY_FOREST		= 0xd44
ARCHE_FLIBBERTY			= 0x855
ARCHE_FROM_THE_DARK		= 0x2ed
ARCHE_GOLDEN_SKIES		= 0x528
ARCHE_GRENADE_TYPE		= 0x302
ARCHE_IDOLESCENT		= 0x5a3
ARCHE_LEYLAH			= 0xd45
ARCHE_LIFEWEAVER		= 0x5a5
ARCHE_METALURGOS		= 0x5a4
ARCHE_MMS				= 0xd71
ARCHE_NUMBER_I			= 0x2048
ARCHE_NUMBER_I39		= 0x6048
ARCHE_NUMBER_IC39		= 0xa048
ARCHE_ORIGIN_DRAGON		= 0xfc1
ARCHE_OSCURION			= 0x5a6
ARCHE_TRAPPIT			= 0x54a
ARCHE_VAISSEAU			= 0x4a8
ARCHE_ZEROST			= 0x1e4

CARD_DESPAIR_FROM_THE_DARK				= 71200730
CARD_NUMBER_39_UTOPIA					= 84013237
CARD_ROTA								= 32807846

CARD_CHEVALIER_DU_VAISSEAU				= 100000032
CARD_GOLDEN_SKIES_TREASURE				= 11111040
CARD_GOLDEN_SKIES_TREASURE_OF_WELFARE	= 11111029
CARD_IN_THE_FOREST_BLACK_AS_MY_MEMORY	= 1
CARD_LIMIERRE							= 19936278
CARD_METALURGOS_CONDUCTION				= 11110608
CARD_MMS_JACKLYN_ALLTRADES				= 19905907
CARD_MMS_SHERLOCK_HOLMES				= 19905908
CARD_OSCURION_TYPE0						= 11110633
CARD_OSCURION_TYPE2						= 11110634
CARD_REVERIE_DU_VAISSEAU				= 100000039
CARD_ROI_DU_VAISSEAU					= 100000035
CARD_RUM_DREAM_DISTILL_FORCE			= 39518
CARD_STARFORCE_KNIGHT					= 39301
CARD_THE_ORIGIN_OF_DRAGONS				= 20157309
CARD_ZERO_HERO_MAGMA_MAN				= 30409
CARD_ZEROST_BEAST_ZEROTL 				= 100000025

TOKEN_CRYSTRON							= 55326323
TOKEN_DRAGON_EGG						= 20157305
TOKEN_NEBULA							= 218201917
TOKEN_RIVAL								= 11110646

--Custom Counters
COUNTER_CHRONUS						= 0x1ae0
COUNTER_ICE_PRISON					= 0x1301
COUNTER_ENGAGED_MASS				= 0xe67
COUNTER_SORROW						= 0xd44
COUNTER_JOY							= 0xd43

--Desc
STRING_CANNOT_CHANGE_POSITION 					= 	700
STRING_CANNOT_TRIGGER							=	701
STRING_BANISH_REDIRECT							=	702
STRING_CANNOT_BE_DESTROYED_BY_BATTLE			=	703
STRING_CANNOT_BE_DESTROYED_BY_EFFECT			=	704
STRING_CANNOT_ATTACK							=	705
STRING_TREATED_AS_TUNER							=	706
STRING_UNAFFECTED_BY_OPPONENT_EFFECT			=	707
STRING_TEMPORARILY_BANISHED						=   708
STRING_INCREASE_DICE_RESULT						=   709
STRING_DECREASE_DICE_RESULT						=   710
STRING_IGNORE_BATTLE_TARGET						=	711
STRING_FAST_ACTIVATION							=	712
STRING_GAINED_ADDITIONAL_ATTACK					=	713
STRING_SHUFFLE_INTO_DECK_REDIRECT				=	714
STRING_CANNOT_BE_TARGETED_BY_OPPONENT_EFFECT	=	715
STRING_CANNOT_BE_DESTROYED_BY_OPPONENT_EFFECT	=	716
STRING_INCREASE									=	721
STRING_DECREASE 								=	722
STRING_ACTIVATE_PENDULUM						=	723
STRING_RETURN_TO_FIELD							=	724
STRING_LINK_MARKER_BOTTOM_LEFT					=	725
STRING_LINK_MARKER_BOTTOM						=	726
STRING_LINK_MARKER_BOTTOM_RIGHT					=	727
STRING_LINK_MARKER_LEFT							=	728
STRING_LINK_MARKER_RIGHT						=	729
STRING_LINK_MARKER_TOP_LEFT						=	730
STRING_LINK_MARKER_TOP							=	731
STRING_LINK_MARKER_TOP_RIGHT					=	732
STRING_CANNOT_BE_FUSION_MATERIAL				=	733
STRING_CANNOT_BE_RITUAL_MATERIAL				=	734
STRING_CANNOT_BE_SYNCHRO_MATERIAL				=	735
STRING_CANNOT_BE_XYZ_MATERIAL					=	736
STRING_CANNOT_BE_LINK_MATERIAL					=	737
STRING_CANNOT_BE_BIGBANG_MATERIAL				=	738
STRING_CANNOT_BE_TIMELEAP_MATERIAL				=	739
STRING_CANNOT_BE_TRIBUTED						=	740
STRING_CANNOT_BE_MATERIAL						=	741
STRING_CAN_BE_TREATED_AS_TUNER					=	742
STRING_UNAFFECTED_BY_OTHER_EFFECT				=	743
STRING_REGULAR_TIMELEAP_SUMMON					=	744
STRING_CANNOT_DIRECT_ATTACK						=	745
STRING_ATK										=	746
STRING_DEF										=	747

STRING_ASK_REPLACE_UPDATE_ENERGY_COST	= 	900
STRING_ASK_ENGAGE						=	901
STRING_ASK_UPDATE_ENERGY				=	902
STRING_ASK_IGNORE_OVERDRIVE_COST		= 	903
STRING_ASK_DISABLE						= 	904
STRING_ASK_ATKCHANGE					= 	905
STRING_ASK_SEARCH						= 	906
STRING_ASK_PLACE_IN_PZONE				=	907
STRING_ASK_PLACE_COUNTER				=	908
STRING_ASK_BANISH						=	909
STRING_EXCLUDE_AI						=	910
STRING_ASK_DISCARD						=	911
STRING_ASK_REVEAL						=	912
STRING_ASK_SEND_TO_GY					=	913
STRING_ASK_SPSUMMON						=	914
STRING_ASK_DRAW							=	915
STRING_ASK_SUMMON						=	916
STRING_ASK_EXCAVATE						=	917
STRING_ASK_TO_EXTRA						=	918

STRING_SEND_TO_EXTRA					=	1006
STRING_BANISH							=	1102
STRING_SPECIAL_SUMMON					=	1152
STRING_PLACE_IN_PZONE					=	1160
STRING_ADD_TO_HAND						=	1190
STRING_SEND_TO_GY						=	1191
STRING_SET								=	1153

STRING_INPUT_ENERGY						=	2000
STRING_INPUT_LEVEL						=	2001
STRING_INPUT_DICE_ROLL					=	2002
STRING_INPUT_NONNEGATIVE_NUMBER			=	2003
STRING_INPUT_NEGATIVE_NUMBER			=	2004

HINTMSG_ENERGY							=	2100
HINTMSG_TRANSFORM						=	2101
HINTMSG_TOEXTRA							=	2102
HINTMSG_FLIPSUMMON						=	2103
HINTMSG_ATTACH							=	2104
HINTMSG_ATTACHTO						=	2105

--Locations
LOCATION_ENGAGED	=	0x1000

--Rating types
RATING_LEVEL	 = 	0x1
RATING_RANK		=	0x2
RATING_LINK		=	0x4
RATING_FUTURE	=	0x8

--Stat types
STAT_ATTACK  = 0x1
STAT_DEFENSE = 0x2

--COIN RESULTS
COIN_HEADS = 1
COIN_TAILS = 0

--Effects
GLOBAL_EFFECT_RESET	=	10203040

--Properties
EFFECT_FLAG_DD = EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL
EFFECT_FLAG_DDD = EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL

--zone constants
EXTRA_MONSTER_ZONE=0x60

--resets
RESETS_REDIRECT_FIELD 			= 0x047e0000
RESETS_STANDARD_DISABLE			= RESETS_STANDARD|RESET_DISABLE
RESETS_STANDARD_UNION 			= RESETS_STANDARD&(~(RESET_TOFIELD|RESET_LEAVE))
RESETS_STANDARD_TOFIELD 		= RESETS_STANDARD&(~(RESET_TOFIELD))
RESETS_STANDARD_EXC_GRAVE 		= RESETS_STANDARD&~(RESET_LEAVE|RESET_TOGRAVE)

--timings
RELEVANT_TIMINGS = TIMINGS_CHECK_MONSTER|TIMING_MAIN_END|TIMING_END_PHASE

--win
WIN_REASON_CUSTOM = 0xff

--constants aliases
TYPE_ST			= TYPE_SPELL|TYPE_TRAP
TYPE_GEMINI		= TYPE_DUAL

ATTRIBUTES_CHAOS = ATTRIBUTE_LIGHT|ATTRIBUTE_DARK

RACES_BEASTS = RACE_BEAST|RACE_BEASTWARRIOR|RACE_WINDBEAST

LOCATION_ALL = LOCATION_DECK|LOCATION_HAND|LOCATION_MZONE|LOCATION_SZONE|LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_EXTRA
LOCATION_GB  = LOCATION_GRAVE|LOCATION_REMOVED

LINK_MARKER_ALL = 0x1ef

MAX_RATING = 14

REASON_EXCAVATE	= REASON_REVEAL

RESET_TURN_SELF = RESET_SELF_TURN
RESET_TURN_OPPO = RESET_OPPO_TURN

--AnnounceNumber
local _AnnounceNumber = Duel.AnnounceNumber

Duel.AnnounceNumber = function(p,n1,...)
	local x={...}
	table.insert(x,1,n1)
	local negatives={}
	for i=#x,1,-1 do
		local n=x[i]
		if n<0 then
			table.insert(negatives,n*-1)
			table.remove(x,i)
		end
	end
	
	if #negatives==0 then
		return _AnnounceNumber(p,n1,...)
	else
		local opt=aux.Option(p,false,false,{#x>0,STRING_INPUT_NONNEGATIVE_NUMBER},{true,STRING_INPUT_NEGATIVE_NUMBER})
		if opt==0 then
			return _AnnounceNumber(p,table.unpack(x))
		elseif opt==1 then
			local ct1,ct2=_AnnounceNumber(p,table.unpack(negatives))
			return ct1*-1,ct2
		end
		return false
	end
end

function Duel.AnnounceNumberMinMax(p,min,max,f)
	local tab={}
	for i=min,max do
		if not f or f(i) then
			table.insert(tab,i)
		end
	end
	return Duel.AnnounceNumber(p,table.unpack(tab))
end
--Shortcuts
function Duel.IsExists(target,f,tp,loc1,loc2,min,exc,...)
	if aux.GetValueType(target)~="boolean" then Debug.Message("Duel.IsExists: First argument should be boolean") return false end
	local func = (target==true) and Duel.IsExistingTarget or Duel.IsExistingMatchingCard
	
	return func(f,tp,loc1,loc2,min,exc,...)
end
function Duel.Select(hint,target,tp,f,pov,loc1,loc2,min,max,exc,...)
	if aux.GetValueType(target)~="boolean" then return false end
	local func = (target==true) and Duel.SelectTarget or Duel.SelectMatchingCard
	local hint = hint or HINTMSG_TARGET
	
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	local g=func(tp,f,pov,loc1,loc2,min,max,exc,...)
	return g
end
function Duel.Group(f,tp,loc1,loc2,exc,...)
	local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,...)
	return g
end
function Duel.HintMessage(tp,msg)
	return Duel.Hint(HINT_SELECTMSG,tp,msg)
end
function Auxiliary.Necro(f)
	return aux.NecroValleyFilter(f)
end
function Card.Activation(c,oath)
	local e1=Effect.CreateEffect(c)
	if c:IsOriginalType(TYPE_PENDULUM) then
		e1:SetDescription(STRING_ACTIVATE_PENDULUM)
	end
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	if oath then
		e1:HOPT(true)
	end
	c:RegisterEffect(e1)
	return e1
end
function Effect.SetFunctions(e,cond,cost,tg,op,val)
	if cond then
		e:SetCondition(cond)
	end
	if cost then
		e:SetCost(cost)
	end
	if tg then
		e:SetTarget(tg)
	end
	if op then
		e:SetOperation(op)
	end
	if val then
		e:SetValue(val)
	end
end
--[[Effect.Evaluate
Get the value of an effect. If the effect has a function as value, it calculates the value of the function
]]
function Effect.Evaluate(e,...)
	local extraargs={...}
	local val=e:GetValue()
	if not val then return false end
	if type(val)=="function" then
		local results={val(e,table.unpack(extraargs))}
		return table.unpack(results)
	else
		return val
	end
end

--Custom Categories
if not global_effect_category_table_global_check then
	global_effect_category_table_global_check=true
	global_effect_category_table={}
	global_effect_info_table={}
	global_additional_info_table={}
	global_possible_info_table={}
end
function Effect.SetCustomCategory(e,cat,flags)
	if not cat then cat=0 end
	if not flags then flags=0 end
	if not global_effect_category_table[e] then global_effect_category_table[e]={} end
	global_effect_category_table[e][1]=cat
	global_effect_category_table[e][2]=flags
end
function Effect.GetCustomCategory(e)
	if not global_effect_category_table[e] then return 0,0 end
	return global_effect_category_table[e][1], global_effect_category_table[e][2]
end
function Effect.IsHasCustomCategory(e,cat1,cat2)
	local ocat1,ocat2=e:GetCustomCategory()
	return (cat1 and ocat1&cat1>0) or (cat2 and ocat2&cat2>0)
end

--New Operation Infos
function Duel.SetCustomOperationInfo(ch,cat,g,ct,p,val,...)
	local extra={...}
	local chain = ch==0 and Duel.GetCurrentChain() or ch
	if not global_effect_info_table[chain] or #global_effect_info_table[chain]>0 then
		global_effect_info_table[chain]={}
	end
	table.insert(global_effect_info_table[chain],{cat,g,ct,p,val,table.unpack(extra)})
end
function Duel.SetPossibleOperationInfo(ch,cat,g,ct,p,val,...)
	local extra={...}
	local chain = ch==0 and Duel.GetCurrentChain() or ch
	if not global_possible_info_table[chain] or #global_possible_info_table[chain]>0 then
		global_possible_info_table[chain]={}
	end
	table.insert(global_possible_info_table[chain],{cat,g,ct,p,val,table.unpack(extra)})
end
function Duel.SetAdditionalOperationInfo(ch,cat,g,ct,p,val,...)
	local extra={...}
	local chain = ch==0 and Duel.GetCurrentChain() or ch
	if not global_additional_info_table[chain] or #global_additional_info_table[chain]>0 then
		global_additional_info_table[chain]={}
	end
	table.insert(global_additional_info_table[chain],{cat,g,ct,p,val,table.unpack(extra)})
end

--Card Actions
function Duel.Attach(c,xyz)
	if aux.GetValueType(c)=="Card" then
		local og=c:GetOverlayGroup()
		if og:GetCount()>0 then
			Duel.SendtoGrave(og,REASON_RULE)
		end
		Duel.Overlay(xyz,Group.FromCards(c))
		return xyz:GetOverlayGroup():IsContains(c)
			
	elseif aux.GetValueType(c)=="Group" then
		for tc in aux.Next(c) do
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				Duel.SendtoGrave(og,REASON_RULE)
			end
		end
		Duel.Overlay(xyz,c)
		return c:FilterCount(function (card,group) return group:IsContains(card) end, nil, xyz:GetOverlayGroup())
	end
end

function Duel.Banish(g,pos,r)
	if not pos then pos=POS_FACEUP end
	if not r then r=REASON_EFFECT end
	return Duel.Remove(g,pos,r)
end
function Card.IsAbleToRemoveTemp(c,tp,r)
	if not r then r=REASON_EFFECT end
	local pos = c:GetPosition()&POS_FACEDOWN>0 and POS_FACEDOWN or POS_FACEUP
	return c:IsAbleToRemove(tp,pos,r|REASON_TEMPORARY)
end
function Duel.BanishUntil(g,e,tp,pos,phase,id,phasect,phasenext,rc,r,disregard_turncount,counts_turns,op,loc,lingering_effect_to_reset)
	if not e then
		e=self_reference_effect
	end
	if not tp then
		tp=current_triggering_player
	end
	if aux.GetValueType(g)=="Card" then g=Group.FromCards(g) end
	if not phase then phase=PHASE_END end
	if not phasect then phasect=1 end
	if not rc then rc=e:GetHandler() end
	if not r then r=REASON_EFFECT end
	if not loc then loc=LOCATION_REMOVED end
	
	local ct=0
	if pos or op then
		if not op then
			ct=Duel.Remove(g,pos,r|REASON_TEMPORARY)
		else
			ct=op(g,r|REASON_TEMPORARY)
		end
	else
		for tc in aux.Next(g) do
			local locpos=tc:IsFaceup() and POS_FACEUP or POS_FACEDOWN
			ct=ct+Duel.Remove(tc,locpos,r|REASON_TEMPORARY)
		end
	end
	if ct>0 then
		local og=g:Filter(Card.IsLocation,nil,loc)
		if #og>0 then
			og:KeepAlive()
			local turnct,turnct2=phasect-1,phasect
			local ph = phase&(PHASE_DRAW|PHASE_STANDBY|PHASE_MAIN1|PHASE_BATTLE_START|PHASE_BATTLE_STEP|PHASE_DAMAGE|PHASE_DAMAGE_CAL|PHASE_BATTLE|PHASE_MAIN2|PHASE_END)
			local player = phase&(RESET_SELF_TURN|RESET_OPPO_TURN)
			local p = player==RESET_SELF_TURN and tp or player==RESET_OPPO_TURN and 1-tp or nil
			
			--Debug.Message(phasenext)
			--Debug.Message(Duel.GetCurrentPhase().." "..ph)
			--Debug.Message(Duel.GetTurnPlayer().." "..tostring(p))
			if Duel.GetCurrentPhase()>ph or (p and Duel.GetTurnPlayer()~=p) or (phasenext and Duel.GetCurrentPhase()==ph and (not p or Duel.GetTurnPlayer()==p)) then
				turnct=turnct+1
				if phasenext and Duel.GetCurrentPhase()==ph and (not p or Duel.GetTurnPlayer()==p) then
					turnct2=turnct2+1
				end
			end
			for tc in aux.Next(og) do
				tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|phase,EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT,turnct2,0,STRING_TEMPORARILY_BANISHED)
			end
			local turnct0 = not p and Duel.GetTurnCount() or Duel.GetTurnCount(p)
			local e1=Effect.CreateEffect(rc)
			e1:SetDescription(STRING_RETURN_TO_FIELD)
			e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE|ph)
			e1:SetReset(RESET_PHASE|phase,turnct2)
			e1:SetCountLimit(1)
			e1:SetLabel(turnct0+turnct)
			e1:SetLabelObject(og)
			if not counts_turns then
				e1:SetCondition(aux.TimingCondition(ph,p,disregard_turncount))
			else
				e1:SetCondition(aux.TimingConditionButCountsTurns(counts_turns))
			end
			e1:SetOperation(aux.ReturnLabelObjectToFieldOp(id,lingering_effect_to_reset))
			Duel.RegisterEffect(e1,tp)
			return ct,e1
		end
	end
	return ct,nil
end
function Duel.ToExtraUntil(g,e,tp,phase,id,phasect,phasenext,rc,r,disregard_turncount,counts_turns)
	local op = function(og,reason)
		return Duel.SendtoExtraP(og,nil,reason)
	end
	return Duel.BanishUntil(g,e,tp,nil,phase,id,phasect,phasenext,rc,r,disregard_turncount,counts_turns,op,LOCATION_EXTRA)
end

function Auxiliary.TimingCondition(phase,p,disregard_turncount)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				--Debug.Message(Duel.GetTurnCount().." "..e:GetLabel())
				--Debug.Message(e:GetLabelObject():GetFirst():GetReasonEffect())
				--Debug.Message(Duel.GetTurnCount(p).." "..e:GetLabel())
				local turnct = not p and Duel.GetTurnCount() or Duel.GetTurnCount(p)
				return Duel.GetCurrentPhase()==phase and (not p or Duel.GetTurnPlayer()==p) and (disregard_turncount or turnct==e:GetLabel())
			end
end
function Auxiliary.TimingConditionButCountsTurns(counts_turns)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local tc=e:GetOwner()
				local ct=tc:GetTurnCounter()
				--Debug.Message(ct.." "..counts_turns)
				if ct==counts_turns then
					return true
				end
				if ct>counts_turns then
					e:Reset()
				end
				return false
			end
end
function Auxiliary.ReturnLabelObjectToFieldOp(id,lingering_effect_to_reset)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local g=e:GetLabelObject()
				local ltype=aux.GetValueType(lingering_effect_to_reset)
				--Debug.Message("OBJSIZE: "..#g)
				local sg=g:Filter(Card.HasFlagEffect,nil,id)
				local rg=Group.CreateGroup()
				for p=tp,1-tp,1-2*tp do
					local sg1=sg:Filter(Card.IsPreviousControler,nil,p)
					if #sg1>0 then
						local sgm=sg1:Filter(Card.IsPreviousLocation,nil,LOCATION_MZONE)
						--Debug.Message("SGM: "..#sgm)
						local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
						if ft>0 then
							if ft<#sgm then
								Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
								local tg=sgm:Select(tp,ft,ft,nil)
								if #tg>0 then
									rg:Merge(tg)
								end
							else
								rg:Merge(sgm)
							end
						end
						local sgs=sg1:Filter(Card.IsPreviousLocation,nil,LOCATION_SZONE):Filter(aux.NOT(Card.IsPreviousLocation),nil,LOCATION_FZONE)
						--Debug.Message("SGS: "..#sgs)
						local ft=Duel.GetLocationCount(p,LOCATION_SZONE)
						if ft>0 then
							if ft<#sgs then
								Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
								local tg=sgs:Select(tp,ft,ft,nil)
								if #tg>0 then
									rg:Merge(tg)
								end
							else
								rg:Merge(sgs)
							end
						end
						local sgf=sg1:Filter(Card.IsPreviousLocation,nil,LOCATION_FZONE)
						rg:Merge(sgf)
					end
				end
				--Debug.Message(#rg)
				if #rg>0 then
					for tc in aux.Next(rg) do
						if tc:IsPreviousLocation(LOCATION_FZONE) then
							Duel.MoveToField(tc,tp,tc:GetPreviousControler(),LOCATION_FZONE,tc:GetPreviousPosition(),true)
						else
							local e1
							if tc:IsInExtra() and tc:IsFaceup() then
								e1=Effect.CreateEffect(tc)
								e1:SetType(EFFECT_TYPE_SINGLE)
								e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
								e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
								e1:SetValue(1)
								e1:SetReset(RESET_EVENT|RESETS_STANDARD)
								tc:RegisterEffect(e1,true)
							end
							--Debug.Message(tc:GetReasonEffect())
							--Debug.Message(e:GetOwner())
							Duel.ReturnToField(tc,tc:GetPreviousPosition(),0xff&(~EXTRA_MONSTER_ZONE))
							if e1 then e1:Reset() end
						end
						if ltype=="number" then
							tc:ResetFlagEffect(lingering_effect_to_reset)
						end
					end
				end
				if ltype=="Effect" then
					lingering_effect_to_reset:Reset()
				end
				g:DeleteGroup()
			end
end

--For cards that equip other cards to themselves ONLY
function Duel.EquipAndRegisterLimit(e,p,be_equip,equip_to,...)
	local res=Duel.Equip(p,be_equip,equip_to,...)
	if res and equip_to:GetEquipGroup():IsContains(be_equip) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(function(e,c)
						return e:GetOwner()==c
					end
				   )
		be_equip:RegisterEffect(e1)
		return true
	end
	return false
end
--For effects that equip a card to another card
function Duel.EquipToOtherCardAndRegisterLimit(e,p,be_equip,equip_to,...)
	local res=Duel.Equip(p,be_equip,equip_to,...)
	if res and equip_to:GetEquipGroup():IsContains(be_equip) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabelObject(equip_to)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(function(e,c)
						return e:GetLabelObject()==c
					end
				   )
		be_equip:RegisterEffect(e1)
		return true
	end
	return false
end
function Duel.EquipAndRegisterCustomLimit(f,p,be_equip,equip_to,...)
	local res=Duel.Equip(p,be_equip,equip_to,...)
	if res and equip_to:GetEquipGroup():IsContains(be_equip) then
		local e1=Effect.CreateEffect(equip_to)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(f)
		be_equip:RegisterEffect(e1)
	end
	return res and equip_to:GetEquipGroup():IsContains(be_equip)
end

function Card.Recreate(c,...)
	local x={...}
	if #x==0 then return end
	local datalist={CARDDATA_CODE,CARDDATA_ALIAS,CARDDATA_SETCODE,CARDDATA_TYPE,CARDDATA_LEVEL,CARDDATA_ATTRIBUTE,CARDDATA_RACE,CARDDATA_ATTACK,CARDDATA_DEFENSE,CARDDATA_LSCALE,CARDDATA_RSCALE}
	for i,newval in ipairs(x) do
		if newval then
			c:SetCardData(datalist[i],newval)
		end
	end
end

function Card.CheckNegateConjunction(c,e1,e2,e3)
	return not c:IsImmuneToEffect(e1) and not c:IsImmuneToEffect(e2) and (not e3 or not c:IsImmuneToEffect(e3))
end
function Duel.Negate(tc,e,reset,notfield,forced,typ)
	local rct=1
	if not reset then
		reset=0
	elseif type(reset)=="table" then
		rct=reset[2]
		reset=reset[1]
	end
	if not typ then typ=0 end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	tc:RegisterEffect(e1,forced)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	if not notfield then
		e2:SetValue(RESET_TURN_SET)
	end
	e2:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	tc:RegisterEffect(e2,forced)
	if not notfield and typ&TYPE_TRAP>0 and tc:IsType(TYPE_TRAPMONSTER) then
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+reset,rct)
		tc:RegisterEffect(e3,forced)
		local res=tc:CheckNegateConjunction(e1,e2,e3)
		if res then
			Duel.AdjustInstantly(tc)
		end
		return e1,e2,e3,res
	end
	local res=tc:CheckNegateConjunction(e1,e2)
	if res then
		Duel.AdjustInstantly(tc)
	end
	return e1,e2,res
end
function Duel.NegateInGY(tc,e,reset)
	if not reset then reset=0 end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE+reset)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE+reset)
	tc:RegisterEffect(e2)
	return e1,e2
end
function Duel.PositionChange(c)
	return Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
end
function Duel.Search(g,tp,p)
	if aux.GetValueType(g)=="Card" then g=Group.FromCards(g) end
	local ct=Duel.SendtoHand(g,p,REASON_EFFECT)
	local cg=g:Filter(aux.PLChk,nil,tp,LOCATION_HAND)
	if #cg>0 then
		Duel.ConfirmCards(1-tp,cg)
	end
	return ct,#cg,cg
end
function Duel.SearchAndCheck(g,tp,p,brk)
	if aux.GetValueType(g)=="Card" then g=Group.FromCards(g) end
	local ct=Duel.SendtoHand(g,p,REASON_EFFECT)
	local cg=g:Filter(aux.PLChk,nil,tp,LOCATION_HAND)
	if #cg>0 then
		if brk then
			Duel.BreakEffect()
		end
		Duel.ConfirmCards(1-tp,cg)
	end
	return ct>0 and #cg>0
end
function Duel.Bounce(g)
	if aux.GetValueType(g)=="Card" then g=Group.FromCards(g) end
	local ct=Duel.SendtoHand(g,nil,REASON_EFFECT)
	local cg=g:Filter(aux.PLChk,nil,nil,LOCATION_HAND)
	return ct,#cg,cg
end

function Duel.ShuffleIntoDeck(g,p,loc)
	if not loc then loc=LOCATION_DECK|LOCATION_EXTRA end
	local ct=Duel.SendtoDeck(g,p,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct>0 then
		aux.AfterShuffle(g)
		if aux.GetValueType(g)=="Card" and aux.PLChk(g,p,loc) then
			return 1
		elseif aux.GetValueType(g)=="Group" then
			return g:FilterCount(aux.PLChk,nil,p,loc)
		end
	end
	return 0
end
function Duel.PlaceOnTopOfDeck(g,p)
	local ct=Duel.SendtoDeck(g,p,SEQ_DECKTOP,REASON_EFFECT)
	if ct>0 then
		local og=g:Filter(Card.IsLocation,nil,LOCATION_DECK)
		for pp=tp,1-tp,1-2*tp do
			local dg=og:Filter(Card.IsControler,nil,pp)
			if #dg>1 then
				Duel.SortDecktop(p,pp,#dg)
			end
		end
		return ct
	end
	return 0
end

function Auxiliary.PLChk(c,p,loc,min,pos)
	if aux.GetValueType(c)=="Card" then
		if min and not pos then pos=min end
		return (not p or c:IsControler(p)) and (not loc or c:IsLocation(loc)) and (not pos or c:IsPosition(pos))
	elseif aux.GetValueType(c)=="Group" then
		if not min then min=1 end
		return c:IsExists(aux.PLChk,min,nil,p,loc,pos)
	else
		return false
	end
end
function Auxiliary.AfterShuffle(g)
	for p=0,1 do
		if aux.PLChk(g,p,LOCATION_DECK) then
			Duel.ShuffleDeck(p)
		end
	end
end

--Battle Phase
function Card.IsCapableOfAttacking(c,tp)
	if not tp then tp=Duel.GetTurnPlayer() end
	return not c:IsForbidden() and not c:IsHasEffect(EFFECT_CANNOT_ATTACK) and not c:IsHasEffect(EFFECT_ATTACK_DISABLED) and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_SKIP_BP)
end

--Card Filters
function Card.IsMonster(c,typ)
	return c:IsType(TYPE_MONSTER) and (aux.GetValueType(typ)~="number" or c:IsType(typ))
end
function Card.IsSpell(c,typ)
	return c:IsType(TYPE_SPELL) and (aux.GetValueType(typ)~="number" or c:IsType(typ))
end
function Card.IsTrap(c,typ)
	return c:IsType(TYPE_TRAP) and (aux.GetValueType(typ)~="number" or c:IsType(typ))
end
function Card.IsNormalSpell(c)
	return c:GetType()&(TYPE_SPELL|TYPE_CONTINUOUS|TYPE_RITUAL|TYPE_EQUIP|TYPE_QUICKPLAY|TYPE_FIELD)==TYPE_SPELL
end
function Card.IsNormalTrap(c)
	return c:GetType()&(TYPE_TRAP|TYPE_CONTINUOUS|TYPE_COUNTER)==TYPE_TRAP
end
function Card.IsNormalST(c)
	return c:IsNormalSpell() or c:IsNormalTrap()
end
function Card.IsST(c,typ)
	return c:IsType(TYPE_ST) and (aux.GetValueType(typ)~="number" or c:IsType(typ))
end
function Card.MonsterOrFacedown(c)
	return c:IsMonster() or c:IsFacedown()
end

function Card.IsAttributeRace(c,attr,race)
	return c:IsAttribute(attr) and c:IsRace(race)
end

function Card.IsAppropriateEquipSpell(c,ec,tp)
	return c:IsSpell(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end

function Card.HasAttack(c)
	return true
end
function Card.HasDefense(c)
	return not c:IsOriginalType(TYPE_LINK)
end
function Card.HasRank(c)
	return c:IsOriginalType(TYPE_XYZ)
end
function Auxiliary.GetCappedDefense(c)
	local x=c:GetDefense()
	if x>MAX_PARAMETER then
		return MAX_PARAMETER
	else
		return x
	end
end

function Card.HasHighest(c,stat,g,f)
	if not g then g=Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE):Filter(Card.IsFaceup,nil) end
	local func	=	function(tc,val,fil)
						return stat(tc)>val and (not fil or fil(tc))
					end
	return not g:IsExists(func,1,c,stat(c),f)
end
function Card.HasLowest(c,stat,g,f)
	if not g then g=Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE):Filter(Card.IsFaceup,nil) end
	local func	=	function(tc,val,fil)
						return stat(tc)<val and (not fil or fil(tc))
					end
	return not g:IsExists(func,1,c,stat(c),f)
end
function Card.HasHighestATK(c,g,f)
	return c:HasHighest(Card.GetAttack,g,f)
end
function Card.HasLowestATK(c,g,f)
	return c:HasLowest(Card.GetAttack,g,f)
end
function Card.HasHighestDEF(c,g,f)
	return c:HasHighest(Card.GetDefense,g,f)
end
function Card.HasLowestDEF(c,g,f)
	return c:HasLowest(Card.GetDefense,g,f)
end

function Card.HasOriginalLevel(c)
	return not c:IsOriginalType(TYPE_XYZ+TYPE_LINK)
end

function Card.IsOriginalType(c,typ)
	return c:GetOriginalType()&typ>0
end
function Card.IsOriginalRace(c,rc)
	return c:GetOriginalRace()&rc>0
end

function Card.HasRank(c)
	return c:IsType(TYPE_XYZ) or c:IsOriginalType(TYPE_XYZ) or c:IsHasEffect(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY)
end
function Card.GetRating(c)
	local list={false,false,false,false}
	if c:HasLevel() then
		list[1]=c:GetLevel()
	end
	if c:IsOriginalType(TYPE_XYZ) then
		list[2]=c:GetRank()
	end
	if c:IsOriginalType(TYPE_LINK) then
		list[3]=c:GetLink()
	end
	if c:IsOriginalType(TYPE_TIMELEAP) then
		list[4]=c:GetFuture()
	end
	return list
end
	
function Card.IsRating(c,rtyp,...)
	local x={...}
	local lv=rtyp&RATING_LEVEL>0
	local rk=rtyp&RATING_RANK>0
	local link=rtyp&RATING_LINK>0
	local fut=rtyp&RATING_FUTURE>0
	for i,n in ipairs(x) do
		if (lv and c:HasLevel() and c:IsLevel(n)) or (rk and c:HasRank() and c:IsRank(n)) or (link and c:IsOriginalType(TYPE_LINK) and c:IsLink(n))
			or (fut and c:IsOriginalType(TYPE_TIMELEAP) and c:IsFuture(n)) then
			return true
		end
	end
	return false
end
function Card.IsRatingAbove(c,rtyp,...)
	local x={...}
	local lv=rtyp&RATING_LEVEL>0
	local rk=rtyp&RATING_RANK>0
	local link=rtyp&RATING_LINK>0
	local fut=rtyp&RATING_FUTURE>0
	for i,n in ipairs(x) do
		if (lv and c:HasLevel() and c:IsLevelAbove(n)) or (rk and c:HasRank() and c:IsRankAbove(n)) or (link and c:IsOriginalType(TYPE_LINK) and c:IsLinkAbove(n))
			or (fut and c:IsOriginalType(TYPE_TIMELEAP) and c:IsFutureAbove(n)) then
			return true
		end
	end
end
function Card.IsRatingBelow(c,rtyp,...)
	local x={...}
	local lv=rtyp&RATING_LEVEL>0
	local rk=rtyp&RATING_RANK>0
	local link=rtyp&RATING_LINK>0
	local fut=rtyp&RATING_FUTURE>0
	for i,n in ipairs(x) do
		if (lv and c:HasLevel() and c:IsLevelBelow(n)) or (rk and c:HasRank() and c:IsRankBelow(n)) or (link and c:IsOriginalType(TYPE_LINK) and c:IsLinkBelow(n))
			or (fut and c:IsOriginalType(TYPE_TIMELEAP) and c:IsFutureBelow(n)) then
			return true
		end
	end
end

function Card.IsStats(c,atk,def)
	return (not atk or (c:HasAttack() and c:IsAttack(atk))) and (not def or (c:HasDefense() and c:IsDefense(def)))
end
function Card.IsStat(c,rtyp,...)
	local x={...}
	local atk=rtyp&STAT_ATTACK>0
	local def=rtyp&STAT_DEFENSE>0
	for i,n in ipairs(x) do
		if (not atk or (c:HasAttack() and c:IsAttack(n))) and (not def or (c:HasDefense() and c:IsDefense(n))) then
			return true
		end
	end
	return false
end
function Card.IsStatBelow(c,rtyp,...)
	local x={...}
	local atk=rtyp&STAT_ATTACK>0
	local def=rtyp&STAT_DEFENSE>0
	for i,n in ipairs(x) do
		if (not atk or (c:HasAttack() and c:IsAttackBelow(n))) or (not def or (c:HasDefense() and c:IsDefenseBelow(n))) then
			return true
		end
	end
	return false
end
function Card.IsStatAbove(c,rtyp,...)
	local x={...}
	local atk=rtyp&STAT_ATTACK>0
	local def=rtyp&STAT_DEFENSE>0
	for i,n in ipairs(x) do
		if (not atk or (c:HasAttack() and c:IsAttackAbove(n))) or (not def or (c:HasDefense() and c:IsDefenseAbove(n))) then
			return true
		end
	end
	return false
end

function Card.ByBattleOrEffect(c,f,p)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and (not f or re and f(re:GetHandler(),e,tp,eg,ep,ev,re,r,rp)) and (not p or rp~=(1-p))
			end
end

function Card.IsContained(c,g,exc)
	return g:IsContains(c) and (not exc or not exc:IsContains(c))
end

--Chain Info
function Duel.GetTargetPlayer()
	return Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
end
function Duel.GetTargetParam()
	return Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
end

--Cloned Effects
function Effect.SpecialSummonEventClone(e,c,notreg)
	local ex=e:Clone()
	ex:SetCode(EVENT_SPSUMMON_SUCCESS)
	if not notreg then
		c:RegisterEffect(ex)
	end
	return ex
end
function Effect.FlipSummonEventClone(e,c,notreg)
	local ex=e:Clone()
	ex:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	if not notreg then
		c:RegisterEffect(ex)
	end
	return ex
end
function Effect.UpdateDefenseClone(e,c,notreg)
	local ex=e:Clone()
	ex:SetCode(EFFECT_UPDATE_DEFENSE)
	if not notreg then
		c:RegisterEffect(ex)
	end
	return ex
end
function Effect.SetDefenseFinalClone(e,c,notreg)
	local ex=e:Clone()
	ex:SetCode(EFFECT_SET_DEFENSE_FINAL)
	if not notreg then
		c:RegisterEffect(ex)
	end
	return ex
end
--codes
function Card.IsOriginalCode(c,code)
	return c:GetOriginalCode()==code
end

--Columns
function Card.GlitchyGetColumnGroup(c,left,right,without_center)
	local left = (left and aux.GetValueType(left)=="number" and left>=0) and left or 0
	local right = (right and aux.GetValueType(right)=="number" and right>=0) and right or 0
	if left==0 and right==0 then
		return c:GetColumnGroup()
	else
		local f = 	function(card,refc,val)
						local refseq
						if refc:GetSequence()<5 then
							refseq=refc:GetSequence()
						else
							if refc:GetSequence()==5 then
								refseq = 1
							elseif refc:GetSequence()==6 then
								refseq = 3
							end
						end
						
						if card:GetSequence()<5 then
							if card:IsControler(refc:GetControler()) then
								return math.abs(refseq-card:GetSequence())==val
							else
								return math.abs(refseq+card:GetSequence()-4)==val
							end
						
						elseif card:GetSequence()==5 then
							local seq = card:IsControler(refc:GetControler()) and 1 or 3
							return math.abs(refseq-seq)==val
						elseif card:GetSequence()==6 then
							local seq = card:IsControler(refc:GetControler()) and 3 or 1
							return math.abs(refseq-seq)==val
						end
					end
					
		local lg=Duel.Group(f,c:GetControler(),LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE+LOCATION_SZONE,nil,c,left)
		local cg = without_center and Group.CreateGroup() or c:GetColumnGroup()
		local rg=Duel.Group(f,c:GetControler(),LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE+LOCATION_SZONE,nil,c,right)
		cg:Merge(lg)
		cg:Merge(rg)
		return cg
	end
end
function Card.GlitchyGetPreviousColumnGroup(c,left,right,without_center)
	local left = (left and aux.GetValueType(left)=="number" and left>=0) and left or 0
	local right = (right and aux.GetValueType(right)=="number" and right>=0) and right or 0
	if left==0 and right==0 then
		return c:GetColumnGroup()
	else
		local f = 	function(card,refc,val)
						local refseq
						if refc:GetPreviousSequence()<5 then
							refseq=refc:GetPreviousSequence()
						else
							if refc:GetPreviousSequence()==5 then
								refseq = 1
							elseif refc:GetPreviousSequence()==6 then
								refseq = 3
							end
						end
						
						if card:GetSequence()<5 then
							if card:IsControler(refc:GetPreviousControler()) then
								return math.abs(refseq-card:GetSequence())==val
							else
								return math.abs(refseq+card:GetSequence()-4)==val
							end
						
						elseif card:GetSequence()==5 then
							local seq = card:IsControler(refc:GetPreviousControler()) and 1 or 3
							return math.abs(refseq-seq)==val
						elseif card:GetSequence()==6 then
							local seq = card:IsControler(refc:GetPreviousControler()) and 3 or 1
							return math.abs(refseq-seq)==val
						end
					end
					
		local lg=Duel.Group(f,c:GetPreviousControler(),LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE+LOCATION_SZONE,nil,c,left)
		local cg = without_center and Group.CreateGroup() or c:GetColumnGroup()
		local rg=Duel.Group(f,c:GetPreviousControler(),LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE+LOCATION_SZONE,nil,c,right)
		cg:Merge(lg)
		cg:Merge(rg)
		return cg
	end
end

--Exception
function Auxiliary.ActivateException(e,chk)
	local c=e:GetHandler()
	if c and e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsType(TYPE_CONTINUOUS+TYPE_FIELD+TYPE_EQUIP) and not c:IsHasEffect(EFFECT_REMAIN_FIELD) and (chk or c:IsRelateToChain(0)) then
		return c
	else
		return nil
	end
end
function Auxiliary.ExceptThis(c)
	if aux.GetValueType(c)=="Effect" then c=c:GetHandler() end
	if c:IsRelateToChain() then return c else return nil end
end

--Descriptions
function Effect.Desc(e,id,...)
	local x = {...}
	local c=e:GetOwner()
	if aux.GetValueType(aux.EffectBeingApplied)=="Effect" and aux.GetValueType(aux.ProxyEffect)=="Effect" and aux.ProxyEffect:GetOwner()==c then
		c=aux.EffectBeingApplied:GetOwner()
	end
	local code = #x>0 and x[1] or c:GetOriginalCode()
	if id<16 then
		return e:SetDescription(aux.Stringid(code,id))
	else
		return e:SetDescription(id)
	end
end
function Card.AskPlayer(c,tp,desc)
	if aux.GetValueType(aux.EffectBeingApplied)=="Effect" and aux.GetValueType(aux.ProxyEffect)=="Effect" and aux.ProxyEffect:GetHandler()==c then
		c=aux.EffectBeingApplied:GetHandler()
	end
	local string = desc<=15 and aux.Stringid(c:GetOriginalCode(),desc) or desc
	return Duel.SelectYesNo(tp,string)
end
function Duel.Ask(tp,id,desc)
	if desc and (desc<0 or desc>15) then desc=0 end
	local string = desc and aux.Stringid(id,desc) or id
	return Duel.SelectYesNo(tp,string)
end

function Auxiliary.Option(id,tp,desc,...)
	if id<2 then
		id,tp=tp,id
	end
	local list={...}
	local off=1
	local ops={}
	local opval={}
	local truect=1
	for ct,b in ipairs(list) do
		local check=b
		local localid
		local localdesc
		if aux.GetValueType(b)=="table" then
			check=b[1]
			if #b==3 then
				localid=b[2]
				localdesc=b[3]
			else
				localid=false
				localdesc=b[2]
			end
		else
			localid=id
			localdesc=desc+truect-1
			truect=truect+1
		end
		if check==true then
			if localid then
				ops[off]=aux.Stringid(localid,localdesc)
			else
				ops[off]=localdesc
			end
			opval[off]=ct-1
			off=off+1
		end
	end
	if #ops==0 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	Duel.Hint(HINT_OPSELECTED,1-tp,ops[op])
	return sel
end

function Duel.RegisterHint(p,flag,reset,rct,id,desc,prop)
	if not reset then reset=PHASE_END end
	if not rct then rct=1 end
	if not prop then prop=0 end
	return Duel.RegisterFlagEffect(p,flag,RESET_PHASE+reset,EFFECT_FLAG_CLIENT_HINT|prop,rct,0,aux.Stringid(id,desc))
end

--EDOPro Imports
function Auxiliary.BitSplit(v)
	local res={}
	local i=0
	while 2^i<=v do
		local p=2^i
		if v & p~=0 then
			table.insert(res,p)
		end
		i=i+1
	end
	return pairs(res)
end
function Auxiliary.GetAttributeStrings(v)
	local t = {
		[ATTRIBUTE_EARTH] = 1010,
		[ATTRIBUTE_WATER] = 1011,
		[ATTRIBUTE_FIRE] = 1012,
		[ATTRIBUTE_WIND] = 1013,
		[ATTRIBUTE_LIGHT] = 1014,
		[ATTRIBUTE_DARK] = 1015,
		[ATTRIBUTE_DIVINE] = 1016
	}
	local res={}
	local ct=0
	for _,att in Auxiliary.BitSplit(v) do
		if t[att] then
			table.insert(res,t[att])
			ct=ct+1
		end
	end
	return pairs(res)
end

function Group.CheckSameProperty(g,f,...)
	local chk=nil
	for tc in aux.Next(g) do
		chk = chk and (chk&f(tc,...)) or f(tc,...)
		if chk==0 then return false,0 end
	end
	return true, chk
end

--Excavate
function Duel.IsPlayerCanExcavateAndSpecialSummon(tp)
	return Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,CARD_EHERO_BLAZEMAN)
end

--Filters
function Auxiliary.Filter(f,...)
	local ext_params={...}
	return aux.FilterBoolFunction(f,table.unpack(ext_params))
end
function Auxiliary.BuildFilter(f,...)
	local ext_params={...}
	return	function(c)
				for _,func in ipairs(ext_params) do
					if type(func)=="function" then
						if not func(c) then
							return false
						end
					elseif type(func)=="table" then
						if not func[1](c,func[2]) then
							return false
						end
					end
				end
				return true
			end
	
end
function Auxiliary.Faceup(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsFaceup()
			end
end
function Auxiliary.Facedown(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsFacedown()
			end
end
function Auxiliary.FaceupFilter(f,...)
	local ext_params={...}
	return	function(target)
				return target:IsFaceup() and f(target,table.unpack(ext_params))
			end
end
function Auxiliary.ArchetypeFilter(set,f,...)
	local ext_params={...}
	return	function(target)
				return target:IsSetCard(set) and (not f or f(target,table.unpack(ext_params)))
			end
end
function Auxiliary.MonsterFilter(typ,f,...)
	local ext_params={...}
	if type(typ)=="function" then
		if type(f)~="nil" then
			table.insert(ext_params,1,f)
		end
		f=typ
		typ=nil
	end
	return	function(target)
				return target:IsMonster(typ) and (not f or f(target,table.unpack(ext_params)))
			end
end
function Auxiliary.RaceFilter(race,f,...)
	local ext_params={...}
	return	function(target)
				return target:IsRace(race) and (not f or f(target,table.unpack(ext_params)))
			end
end
function Auxiliary.STFilter(f,...)
	local ext_params={...}
	return	function(target)
				return target:IsST() and (not f or f(target,table.unpack(ext_params)))
			end
end

--Flag Effects
function Card.HasFlagEffect(c,id,...)
	local flags={...}
	if id then
		table.insert(flags,id)
	end
	for _,flag in ipairs(flags) do
		if c:GetFlagEffect(flag)>0 then
			return true
		end
	end
	
	return false
end
function Duel.PlayerHasFlagEffect(p,id,...)
	local flags={...}
	if id then
		table.insert(flags,id)
	end
	for _,flag in ipairs(flags) do
		if Duel.GetFlagEffect(p,flag)>0 then
			return true
		end
	end
	
	return false
end
function Card.UpdateFlagEffectLabel(c,id,ct)
	if not ct then ct=1 end
	return c:SetFlagEffectLabel(id,c:GetFlagEffectLabel(id)+ct)
end
function Duel.UpdateFlagEffectLabel(p,id,ct)
	if not ct then ct=1 end
	return Duel.SetFlagEffectLabel(p,id,Duel.GetFlagEffectLabel(p,id)+ct)
end
function Card.HasFlagEffectLabel(c,id,val)
	if not c:HasFlagEffect(id) then return false end
	for _,label in ipairs({c:GetFlagEffectLabel(id)}) do
		if label==val then
			return true
		end
	end
	return false
end
function Card.HasFlagEffectLabelLower(c,id,val)
	if not c:HasFlagEffect(id) then return false end
	for _,label in ipairs({c:GetFlagEffectLabel(id)}) do
		if label<val then
			return true
		end
	end
	return false
end
function Card.HasFlagEffectLabelHigher(c,id,val)
	if not c:HasFlagEffect(id) then return false end
	for _,label in ipairs({c:GetFlagEffectLabel(id)}) do
		if label>val then
			return true
		end
	end
	return false
end
function Duel.PlayerHasFlagEffectLabel(tp,id,val)
	if Duel.GetFlagEffect(tp,id)==0 then return false end
	for _,label in ipairs({Duel.GetFlagEffectLabel(tp,id)}) do
		if label==val then
			return true
		end
	end
	return false
end

function Auxiliary.FixNegativeLabel(n)
	if n<2147483648 then
		return n
	else
		return n-4294967296
	end
end

--Gain Effect
function Auxiliary.GainEffectType(c,oc,reset)
	if not oc then oc=c end
	if not reset then reset=0 end
	if not c:IsType(TYPE_EFFECT) then
		local e=Effect.CreateEffect(oc)
		e:SetType(EFFECT_TYPE_SINGLE)
		e:SetCode(EFFECT_ADD_TYPE)
		e:SetValue(TYPE_EFFECT)
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
		c:RegisterEffect(e,true)
	end
end

--Groups
function Group.GetControlers(g)
	local p=PLAYER_NONE
	if #g==0 then return p end
	for i=0,1 do
		if g:IsExists(Card.IsControler,1,nil,i) then
			if p==PLAYER_NONE then
				p=i
			else
				p=PLAYER_ALL
			end
		end
	end
	return p
end

--Hint timing
function Effect.SetRelevantTimings(e,extra_timings)
	if not extra_timings then extra_timings=0 end
	return e:SetHintTiming(extra_timings,RELEVANT_TIMINGS|extra_timings)
end


--Labels
function Effect.SetLabelPair(e,l1,l2)
	if l1 and l2 then
		e:SetLabel(l1,l2)
	elseif l1 then
		local _,o2=e:GetLabel()
		e:SetLabel(l1,o2)
	else
		local o1,_=e:GetLabel()
		e:SetLabel(o1,l2)
	end
end
function Effect.GetSpecificLabel(e,pos)
	if not pos then pos=1 end
	local tab={e:GetLabel()}
	if #tab<pos then return end
	return tab[pos]
end

--Link Markers
function Card.IsCanActivateLinkMarker(c,markers,e,tp,r)
	if not markers then markers=LINK_MARKER_ALL end
	if not c:IsType(TYPE_LINK) then return false end
	local val=c:GetLinkMarker()&markers
	return val~=markers
end
function Card.IsCanDeactivateLinkMarker(c,markers,e,tp,r)
	if not markers then markers=LINK_MARKER_ALL end
	if not c:IsType(TYPE_LINK) then return false end
	local val=c:GetLinkMarker()&markers
	return val>0
end
function Card.ActivateLinkMarker(c,markers,e,tp,r,reset,rc)
	if not markers then
		local free=(~c:GetLinkMarker())&0xffff
		local SW={free&LINK_MARKER_BOTTOM_LEFT==LINK_MARKER_BOTTOM_LEFT,STRING_LINK_MARKER_BOTTOM_LEFT}
		local S={free&LINK_MARKER_BOTTOM==LINK_MARKER_BOTTOM,STRING_LINK_MARKER_BOTTOM}
		local SE={free&LINK_MARKER_BOTTOM_RIGHT==LINK_MARKER_BOTTOM_RIGHT,STRING_LINK_MARKER_BOTTOM_RIGHT}
		local W={free&LINK_MARKER_LEFT==LINK_MARKER_LEFT,STRING_LINK_MARKER_LEFT}
		local E={free&LINK_MARKER_RIGHT==LINK_MARKER_RIGHT,STRING_LINK_MARKER_RIGHT}
		local NW={free&LINK_MARKER_TOP_LEFT==LINK_MARKER_TOP_LEFT,STRING_LINK_MARKER_TOP_LEFT}
		local N={free&LINK_MARKER_TOP==LINK_MARKER_TOP,STRING_LINK_MARKER_TOP}
		local NE={free&LINK_MARKER_TOP_RIGHT==LINK_MARKER_TOP_RIGHT,STRING_LINK_MARKER_TOP_RIGHT}
		local opt=aux.Option(tp,false,false,SW,S,SE,W,E,NW,N,NE)
		if opt>=4 then
			opt=opt+1
		end
		markers=1<<opt
	else
		markers=(markers&(~(c:GetLinkMarker())))&0x1ef
	end
	if markers==0 then return false end
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_LINK_MARKER_KOISHI)
	e1:SetValue(markers)
	if reset then
		local rct=1
		if type(reset)=="table" then
			rct=reset[2]
			reset=reset[1]
		elseif type(reset)~="number" then
			reset=0
		end
		if c==rc then reset=reset|RESET_DISABLE end
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	c:RegisterEffect(e1)
end
function Card.DeactivateLinkMarker(c,markers,e,tp,r,reset,rc)
	if not markers then
		local free=c:GetLinkMarker()&0xffff
		local SW={free&LINK_MARKER_BOTTOM_LEFT==LINK_MARKER_BOTTOM_LEFT,STRING_LINK_MARKER_BOTTOM_LEFT}
		local S={free&LINK_MARKER_BOTTOM==LINK_MARKER_BOTTOM,STRING_LINK_MARKER_BOTTOM}
		local SE={free&LINK_MARKER_BOTTOM_RIGHT==LINK_MARKER_BOTTOM_RIGHT,STRING_LINK_MARKER_BOTTOM_RIGHT}
		local W={free&LINK_MARKER_LEFT==LINK_MARKER_LEFT,STRING_LINK_MARKER_LEFT}
		local E={free&LINK_MARKER_RIGHT==LINK_MARKER_RIGHT,STRING_LINK_MARKER_RIGHT}
		local NW={free&LINK_MARKER_TOP_LEFT==LINK_MARKER_TOP_LEFT,STRING_LINK_MARKER_TOP_LEFT}
		local N={free&LINK_MARKER_TOP==LINK_MARKER_TOP,STRING_LINK_MARKER_TOP}
		local NE={free&LINK_MARKER_TOP_RIGHT==LINK_MARKER_TOP_RIGHT,STRING_LINK_MARKER_TOP_RIGHT}
		local opt=aux.Option(tp,false,false,SW,S,SE,W,E,NW,N,NE)
		if opt>=4 then
			opt=opt+1
		end
		markers=1<<opt
	else
		markers=markers&c:GetLinkMarker()
	end
	if markers==0 then return false end
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMOVE_LINK_MARKER_KOISHI)
	e1:SetValue(markers)
	if reset then
		local rct=1
		if type(reset)=="table" then
			rct=reset[2]
			reset=reset[1]
		elseif type(reset)~="number" then
			reset=0
		end
		if c==rc then reset=reset|RESET_DISABLE end
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
	end
	c:RegisterEffect(e1)
end

--LP
function Duel.LoseLP(p,val)
	return Duel.SetLP(tp,Duel.GetLP(tp)-math.abs(val))
end

--Locations
function Card.IsBanished(c,pos)
	return c:IsLocation(LOCATION_REMOVED) and (not pos or c:IsPosition(pos))
end
function Card.IsInExtra(c,fu)
	return c:IsLocation(LOCATION_EXTRA) and (fu==nil or (fu==true or fu==POS_FACEUP) and c:IsFaceup() or (fu==false or fu==POS_FACEDOWN) and c:IsFacedown())
end
function Card.IsInGY(c)
	return c:IsLocation(LOCATION_GRAVE)
end
function Card.IsInMMZ(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
function Card.IsInEMZ(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()>=5
end
function Card.IsInBackrow(c,pos)
	return c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5 and (not pos or c:IsPosition(pos))
end
function Card.IsSequence(c,seq)
	return c:GetSequence()==seq
end
function Card.IsSequenceBelow(c,seq)
	return c:GetSequence()<=seq
end
function Card.IsSequenceAbove(c,seq)
	return c:GetSequence()>=seq
end
function Card.IsInMainSequence(c)
	return c:IsSequenceBelow(4)
end

function Card.IsSpellTrapOnField(c)
	return not c:IsLocation(LOCATION_MZONE) or (c:IsFaceup() and c:IsST())
end
function Card.NotOnFieldOrFaceup(c)
	return not c:IsOnField() or c:IsFaceup()
end
function Card.NotBanishedOrFaceup(c)
	return not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()
end
function Card.NotInExtraOrFaceup(c)
	return not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup()
end

function Card.IsFusionSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_FUSION)
end
function Card.IsRitualSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function Card.IsSynchroSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function Card.IsXyzSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_XYZ)
end
function Card.IsPendulumSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function Card.IsLinkSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function Card.IsPandemoniumSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_PANDEMONIUM)
end
function Card.IsTimeleapSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function Card.IsBigbangSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_BIGBANG)
end
function Card.IsDriveSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_DRIVE)
end
function Card.IsSelfSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end

--Zones
function Card.GetZone(c,tp)
	local rzone
	if c:IsLocation(LOCATION_MZONE) then
		rzone = c:IsControler(tp) and (1 <<c:GetSequence()) or (1 << (16+c:GetSequence()))
		if c:IsSequence(5,6) then
			rzone = rzone | (c:IsControler(tp) and (1 << (16 + 11 - c:GetSequence())) or (1 << (11 - c:GetSequence())))
		end
	elseif c:IsLocation(LOCATION_SZONE) then
		rzone = c:IsControler(tp) and (1 << (8+c:GetSequence())) or (1 << (24+c:GetSequence()))
	end
	
	return rzone
end
function Card.GetPreviousZone(c,tp)
	local rzone
	if c:IsPreviousLocation(LOCATION_MZONE) then
		rzone = c:IsControler(tp) and (1 <<c:GetPreviousSequence()) or (1 << (16+c:GetPreviousSequence()))
		if c:GetPreviousSequence()==5 or c:GetPreviousSequence()==6 then
			rzone = rzone | (c:IsControler(tp) and (1 << (16 + 11 - c:GetPreviousSequence())) or (1 << (11 - c:GetPreviousSequence())))
		end
	
	elseif c:IsPreviousLocation(LOCATION_SZONE) then
		rzone = c:IsControler(tp) and (1 << (8+c:GetPreviousSequence())) or (1 << (24+c:GetPreviousSequence()))
	end
	return rzone
end

function Duel.GetColumnZoneFromSequence(seq,seqloc,loc)
	local zones=0
	if not seqloc then
		seqloc=LOCATION_ONFIELD
	else
		if seqloc&LOCATION_ONFIELD==0 or (seqloc==LOCATION_SZONE and seq>=5) then
			return 0
		end 
	end
	if not loc then
		loc=LOCATION_ONFIELD
	else
		if loc&LOCATION_ONFIELD==0 then
			return 0
		end
	end
	
	if seq<=4 then
		if loc&LOCATION_MZONE~=0 then
			if seqloc&LOCATION_MZONE==0 then
				zones = zones|(1<<seq)
			end
			zones = zones|(1<<(16+(4-seq)))
			if seq==1 then
				zones = zones|((1<<5)|(1<<(16+6)))
			end
			if seq==3 then
				zones = zones|((1<<6)|(1<<(16+5)))
			end
		end
		if loc&LOCATION_SZONE~=0 then
			if seqloc&LOCATION_SZONE==0 then
				zones = zones|(1<<seq+8)
			end
			zones = zones|(1<<(16+8+(4-seq)))
		end
	
	elseif seq==5 then
		if loc&LOCATION_MZONE~=0 then
			zones = zones|((1 << 1) | (1 << (16 + 3)))
		end
		if loc&LOCATION_SZONE~=0 then
			zones = zones|((1 << (8 + 1)) | (1 << (16 + 8 + 3)))
		end
	
	elseif seq==6 then
		if loc&LOCATION_MZONE~=0 then
			zones = zones|((1 << 3) | (1 << (16 + 1)))
		end
		if loc&LOCATION_SZONE~=0 then
			zones = zones|((1 << (8 + 3)) | (1 << (16 + 8 + 1)))
		end
	end
	
	--Debug.Message(zones)
	return zones
end
function Duel.GetColumnGroupFromSequence(tp,seq,seqloc)
	if seqloc&LOCATION_ONFIELD==0 then return end
	local column_mzone,column_szone = Duel.GetColumnZoneFromSequence(seq,seqloc,LOCATION_MZONE),Duel.GetColumnZoneFromSequence(seq,seqloc,LOCATION_SZONE)
	local g1=Duel.GetCardsInZone(column_mzone,tp,LOCATION_MZONE)
	local g2=Duel.GetCardsInZone(column_mzone>>16,1-tp,LOCATION_MZONE)
	local g3=Duel.GetCardsInZone(column_szone>>8,tp,LOCATION_SZONE)
	local g4=Duel.GetCardsInZone(column_szone>>24,1-tp,LOCATION_SZONE)
	g1:Merge(g2)
	g1:Merge(g3)
	g1:Merge(g4)
	return g1
end
function Duel.GetCardsInZone(zone,tp,loc)
	if loc&LOCATION_ONFIELD==0 then return end
	local g=Group.CreateGroup()
	local v = loc==LOCATION_MZONE and Duel.GetFieldGroup(tp,LOCATION_MZONE,0) or Duel.GetFieldGroup(tp,LOCATION_SZONE,0):Filter(Card.IsSequenceBelow,nil,4)
	for tc in aux.Next(v) do
		local icheck=1<<tc:GetSequence()
		if zone&icheck~=0 then
			g:AddCard(tc)
		end
	end
	return g
end

function Duel.CheckPendulumZones(tp)
	return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
end
function Card.IsInLinkedZone(c,cc)
	return cc:GetLinkedGroup():IsContains(c)
end
function Card.WasInLinkedZone(c,cc)
	return cc:GetLinkedZone(c:GetPreviousControler())&c:GetPreviousZone()~=0
end
function Card.HasBeenInLinkedZone(c,cc)
	return cc:GetLinkedGroup():IsContains(c) or (not c:IsLocation(LOCATION_MZONE) and cc:GetLinkedZone(c:GetPreviousControler())&c:GetPreviousZone()~=0)
end

function Duel.GetMZoneCountFromLocation(tp,up,g,c)
	if c:IsInExtra() then
		return Duel.GetLocationCountFromEx(tp,up,g,c)
	else
		return Duel.GetMZoneCount(tp,g,up)
	end
end

--Location Groups
function Duel.GetHand(p)
	return Duel.GetFieldGroup(p,LOCATION_HAND,0)
end
function Duel.GetHandCount(p)
	return Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
end
function Duel.GetDeck(p)
	return Duel.GetFieldGroup(p,LOCATION_DECK,0)
end
function Duel.GetDeckCount(p)
	return Duel.GetFieldGroupCount(p,LOCATION_DECK,0)
end
function Duel.GetGY(p)
	return Duel.GetFieldGroup(p,LOCATION_GY,0)
end
function Duel.GetGYCount(p)
	return Duel.GetFieldGroupCount(p,LOCATION_GY,0)
end
function Duel.GetExtraDeck(p)
	return Duel.GetFieldGroup(p,LOCATION_EXTRA,0)
end
function Duel.GetExtraDeckCount(p)
	return Duel.GetFieldGroupCount(p,LOCATION_EXTRA,0)
end
function Duel.GetPendulums(p)
	return Duel.GetFieldGroup(p,LOCATION_PZONE,0)
end
function Duel.GetPendulumsCount(p)
	return Duel.GetFieldGroupCount(p,LOCATION_PZONE,0)
end

--Materials
function Auxiliary.GetMustMaterialGroup(p,eff)
	return Duel.GetMustMaterial(p,eff)
end

--Normal Summon/set
function Card.IsSummonableOrSettable(c)
	return c:IsSummonable(true,nil) or c:IsMSetable(true,nil)
end
function Duel.SummonOrSet(tp,tc,ignore_limit,min)
	if not ignore_limit then ignore_limit=true end
	if tc:IsSummonable(ignore_limit,min) and (not tc:IsMSetable(ignore_limit,min) or Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) then
		Duel.Summon(tp,tc,ignore_limit,min)
	else
		Duel.MSet(tp,tc,ignore_limit,min)
	end
end

--Set Monster/Spell/Trap
function Card.IsCanBeSet(c,e,tp,ignore_mzone,ignore_szone)
	if c:IsMonster() then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and (not ignore_mzone or Duel.GetMZoneCount(tp)>0)
	elseif c:IsST() then
		return c:IsSSetable(ignore_szone)
	end
end
function Duel.Set(tp,g)
	if aux.GetValueType(g)=="Card" then g=Group.FromCards(g) end
	local ct=0
	local mg=g:Filter(Card.IsMonster,nil)
	if #mg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		for tc in aux.Next(mg) do
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) then
				Duel.ConfirmCards(1-tp,tc)
			end
		end
	end
	local sg=g:Filter(Card.IsST,nil)
	if #sg>0 then
		for tc in aux.Next(sg) do
			if tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
				ct=ct+Duel.SSet(tp,tc)
			end
		end
	end
	ct=ct+Duel.SpecialSummonComplete()
	return ct
end

--Once per turn
function Effect.OPT(e,ct)
	if not ct then ct=1 end
	if type(ct)=="boolean" then
		return e:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	else
		return e:SetCountLimit(ct)
	end
end

if not Auxiliary.HOPTTracker then
	Auxiliary.HOPTTracker={}
end
function Effect.HOPT(e,oath,ct)
	if not e:GetOwner() then return end
	if not ct then ct=1 end
	local c=e:GetOwner()
	local cid=c:GetOriginalCode()
	if not aux.HOPTTracker[c] then
		aux.HOPTTracker[c]=-1
	end
	aux.HOPTTracker[c]=aux.HOPTTracker[c]+1
	if type(aux.HOPTTracker[c])=="number" then
		cid=cid+aux.HOPTTracker[c]*100
	end
	local flag=0
	if oath then
		if type(oath)~="number" then oath=EFFECT_COUNT_CODE_OATH end
		flag=flag|oath
	end
	return e:SetCountLimit(ct,cid+flag)
end
function Effect.SHOPT(e,oath)
	if not e:GetOwner() then return end
	local c=e:GetOwner()
	local cid=c:GetOriginalCode()
	if not aux.HOPTTracker[c] then
		aux.HOPTTracker[c]=0
	end
	if type(aux.HOPTTracker[c])=="number" then
		cid=cid+aux.HOPTTracker[c]*100
	end
	
	local flag=0
	if oath then
		if type(oath)~="number" then oath=EFFECT_COUNT_CODE_OATH end
		flag=flag|oath
	end
	
	return e:SetCountLimit(1,cid+flag)
end

--Phases
function Duel.IsDrawPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_DRAW
end
function Duel.IsStandbyPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_STANDBY
end
function Duel.IsMainPhase(tp,ct)
	return (not tp or Duel.GetTurnPlayer()==tp)
		and (not ct and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) or ct==1 and Duel.GetCurrentPhase()==PHASE_MAIN1 or ct==2 and Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function Duel.IsBattlePhase(tp)
	local ph=Duel.GetCurrentPhase()
	return (not tp or Duel.GetTurnPlayer()==tp) and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function Duel.IsEndPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_END
end

function Duel.GetNextPhaseCount(ph,p)
	if Duel.GetCurrentPhase()==ph and (not p or Duel.GetTurnPlayer()==tp) then
		return 2
	else
		return 1
	end
end

--PositionChange
function Duel.Flip(c,pos)
	if not c or (pos&POS_FACEUP==0 and pos&POS_FACEDOWN==0) then return 0 end
	if aux.GetValueType(c)=="Card" then
		if (pos&POS_FACEUP>0 and c:IsFaceup()) or (pos&POS_FACEDOWN>0 and c:IsFacedown()) then return 0 end
		local position = pos&POS_FACEUP>0 and c:GetPosition()>>1 or c:GetPosition()<<1
		return Duel.ChangePosition(c,position)
	else
		local ct=0
		for tc in aux.Next(c) do
			ct=ct+Duel.Flip(tc,pos)
		end
		return ct
	end
end
function Card.IsCanTurnSetGlitchy(c)
	if c:IsPosition(POS_FACEDOWN_DEFENSE) then return false end
	if not c:IsPosition(POS_FACEDOWN_ATTACK) then
		return c:IsCanTurnSet()
	else
		return not c:IsType(TYPE_LINK|TYPE_TOKEN) and not c:IsHasEffect(EFFECT_CANNOT_TURN_SET) and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_TURN_SET)
	end
end

--Previous
function Card.IsPreviousCodeOnField(c,code,...)
	local codes={...}
	table.insert(codes,1,code)
	local precodes={c:GetPreviousCodeOnField()}
	for _,prename in ipairs(precodes) do
		for _,name in ipairs(codes) do
			if prename==name then
				return true
			end
		end
	end
	return false
end
function Card.IsPreviousTypeOnField(c,typ)
	return c:GetPreviousTypeOnField()&typ==typ
end
function Card.IsPreviousLevelOnField(c,lv)
	return c:GetPreviousLevelOnField()==lv
end
function Card.IsPreviousRankOnField(c,lv)
	return c:GetPreviousRankOnField()==lv
end
function Card.IsPreviousAttributeOnField(c,att)
	return c:GetPreviousAttributeOnField()&att==att
end
function Card.IsPreviousRaceOnField(c,rac)
	return c:GetPreviousRaceOnField()&rac==rac
end
function Card.IsPreviousAttackOnField(c,atk)
	return c:GetPreviousAttackOnField()==atk
end
function Card.IsPreviousDefenseOnField(c,def)
	return c:GetPreviousDefenseOnField()==def
end

--Check archetype at Activation
function Auxiliary.RegisterTriggeringArchetypeCheck(c,setc)
	local s=getmetatable(c)
	if not s.TriggeringSetcodeCheck then
		s.TriggeringSetcodeCheck=true
		s.TriggeringSetcode={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_CREATED)
		ge1:SetOperation(aux.UpdateTriggeringArchetypeCheck(s,setc))
		Duel.RegisterEffect(ge1,0)
		return ge1
	end
	return
end
function Auxiliary.UpdateTriggeringArchetypeCheck(s,setc)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
				local rc=re:GetHandler()
				if rc:IsSetCard(setc) then
					s.TriggeringSetcode[cid]=true
					return
				end
				s.TriggeringSetcode[cid]=false
			end
end

function Auxiliary.CheckArchetypeReasonEffect(s,re,setc)
	local rc=re:GetHandler()
	local ch=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID)
	if re:IsActivated() then
		if rc:IsRelateToChain(ch) then
			return rc:IsSetCard(setc)
		else
			return s.TriggeringSetcode[cid]
		end
	else
		return rc:IsSetCard(setc)
	end
end

--Pendulum-related
function Card.IsCapableSendToExtra(c,tp)
	if not c:IsMonster(TYPE_EXTRA|TYPE_PENDULUM|TYPE_PANDEMONIUM) or c:IsHasEffect(EFFECT_CANNOT_TO_DECK) or not Duel.IsPlayerCanSendtoDeck(tp,c) then return false end
	return true
end
function Card.IsAbleToExtraFaceupAsCost(c,p,tp)
	local redirect=0
	local dest=LOCATION_DECK
	if not c:IsMonster(TYPE_PENDULUM|TYPE_PANDEMONIUM) or c:IsLocation(LOCATION_EXTRA) or (tp and c:GetOwner()~=tp)
		or c:IsHasEffect(EFFECT_CANNOT_USE_AS_COST) or not c:IsCapableSendToExtra(p) then 
		return false
	end
	if c:IsOnField() then
		redirect=c:LeaveFieldRedirect(REASON_COST)&0xffff
	end
	if redirect~=0 then
		dest=redirect
	end
	redirect = c:DestinationRedirect(dest,REASON_COST)&0xffff
	if redirect~=0 then
		dest=redirect
	end
	return dest==LOCATION_DECK
end

--redirect
function Card.DestinationRedirect(c,dest,r)
	local eset
	if c:IsOriginalType(TYPE_TOKEN) then return 0 end
	local options={
		[LOCATION_HAND]=EFFECT_TO_HAND_REDIRECT;
		[LOCATION_DECK]=EFFECT_TO_DECK_REDIRECT;
		[LOCATION_GRAVE]=EFFECT_TO_GRAVE_REDIRECT;
		[LOCATION_REMOVED]=EFFECT_REMOVE_REDIRECT
	}
	for loc,eloc in pairs(options) do
		if dest==loc then
			eset={c:IsHasEffect(eloc)}
			break
		end
	end
	if not eset then return 0 end
	for _,e in ipairs(eset) do
		local p=e:GetHandlerPlayer()
		local val=e:Evaluate(c)
		if val&LOCATION_HAND>0 and not c:IsHasEffect(EFFECT_CANNOT_TO_HAND) and Duel.IsPlayerCanSendtoHand(p,c) then
			return LOCATION_HAND
		end
		if val&LOCATION_DECK>0 and not c:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(p,c) then
			return LOCATION_DECK
		end
		if val&LOCATION_REMOVED>0 and not c:IsHasEffect(EFFECT_CANNOT_REMOVE) and Duel.IsPlayerCanRemove(p,c,r) then
			return LOCATION_REMOVED
		end
		if val&LOCATION_GRAVE>0 and not c:IsHasEffect(EFFECT_CANNOT_TO_GRAVE) and Duel.IsPlayerCanSendtoGrave(p,c) then
			return LOCATION_GRAVE
		end
	end
	
	return 0
end
function Card.LeaveFieldRedirect(c,r)
	local redirects=0
	if c:IsOriginalType(TYPE_TOKEN) then return 0 end
	local eset={c:IsHasEffect(EFFECT_LEAVE_FIELD_REDIRECT)}
	for _,e in ipairs(eset) do
		local p=e:GetHandlerPlayer()
		local val=e:Evaluate(c)
		if val&LOCATION_HAND>0 and not c:IsHasEffect(EFFECT_CANNOT_TO_HAND) and Duel.IsPlayerCanSendtoHand(p,c) then
			redirects = redirects|LOCATION_HAND
		end
		if val&LOCATION_DECK>0 and not c:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(p,c) then
			redirects = redirects|LOCATION_DECK
		end
		if val&LOCATION_REMOVED>0 and not c:IsHasEffect(EFFECT_CANNOT_REMOVE) and Duel.IsPlayerCanRemove(p,c,r) then
			redirects = redirects|LOCATION_REMOVED
		end
	end
	if redirects&LOCATION_REMOVED>0 then return LOCATION_REMOVED end
	if redirects&LOCATION_DECK>0 then
		if redirects&LOCATION_DECKBOT==LOCATION_DECKBOT then
			return LOCATION_DECKBOT
		end
		if redirects&LOCATION_DECKSHF==LOCATION_DECKSHF then
			return LOCATION_DECKSHF
		end
		return LOCATION_DECK
	end
	if redirects&LOCATION_HAND>0 then return LOCATION_HAND end
	return 0
end

--Relation
local _IsRelateToChain = Card.IsRelateToChain

Card.IsRelateToChain = function(c,...)
	if aux.ConvertChainToEffectRelation then
		if not ... then
			local re=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_EFFECT)
			return c:IsRelateToEffect(re)
			
		else
			local x={...}
			local ev=x[1]
			local re=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
			return c:IsRelateToEffect(re)
		end
	else
		return _IsRelateToChain(c,...)
	end
end

--Remain on field
function Auxiliary.RemainOnFieldCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(aux.RemainOnFieldCostFunction)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e2,tp)
end
function Auxiliary.RemainOnFieldCostFunction(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end

--Location Check
function Auxiliary.AddThisCardBanishedAlreadyCheck(c,setf,getf)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(Auxiliary.ThisCardInLocationAlreadyCheckReg(setf,getf))
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.AddThisCardInBackrowAlreadyCheck(c,pos,setf,getf)
	if pos==POS_FACEDOWN then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SSET)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCondition(function(e) return (not e:GetHandler():IsPreviousLocation(LOCATION_SZONE) or e:GetHandler():GetPreviousSequence()<5) and e:GetHandler():IsInBackrow(pos) end)
		e1:SetOperation(Auxiliary.ThisCardInLocationAlreadyCheckReg(setf,getf,true))
		Duel.RegisterEffect(e1,0)
		return e1
	end
end
function Auxiliary.AddThisCardInExtraAlreadyCheck(c,pos,setf,getf)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(function(e) return e:GetHandler():IsInExtra(pos) end)
	e1:SetOperation(Auxiliary.ThisCardInLocationAlreadyCheckReg(setf,getf))
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.AddThisCardInMZoneAlreadyCheck(c,setf,getf)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_MOVE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(function(e) return not e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsLocation(LOCATION_MZONE) end)
	e1:SetOperation(Auxiliary.ThisCardInLocationAlreadyCheckReg(setf,getf,true))
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.AddThisCardInPZoneAlreadyCheck(c,pos,setf,getf)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_MOVE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(function(e) return not e:GetHandler():IsPreviousLocation(LOCATION_PZONE) and e:GetHandler():IsLocation(LOCATION_PZONE) end)
	e1:SetOperation(Auxiliary.ThisCardInLocationAlreadyCheckReg(setf,getf))
	c:RegisterEffect(e1)
	return e1
end
function Effect.SetLabelObjectObject(e,obj)
	return e:GetLabelObject():SetLabelObject(obj)
end
function Effect.GetLabelObjectObject(e)
	return e:GetLabelObject():GetLabelObject()
end
function Auxiliary.ThisCardInLocationAlreadyCheckReg(setf,getf,ignore_reason)
	if not setf then setf=Effect.SetLabelObject end
	if not getf then getf=Effect.GetLabelObject end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				--condition of continous effect will be checked before other effects
				--Debug.Message("RE: "..tostring(re))
				--Debug.Message("GETF: "..tostring(getf(e)))
				if re==nil then return false end
				if getf(e)~=nil then return false end
				--Debug.Message("r: "..tostring(r))
				if (r&REASON_EFFECT)>0 or ignore_reason then
					setf(e,re)
					--e:SetLabelObject(re)
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EVENT_CHAIN_END)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetOperation(Auxiliary.ThisCardInLocationAlreadyReset1(getf))
					e1:SetLabelObject(e)
					Duel.RegisterEffect(e1,tp)
					local e2=e1:Clone()
					e2:SetCode(EVENT_BREAK_EFFECT)
					e2:SetOperation(Auxiliary.ThisCardInLocationAlreadyReset2(getf))
					e2:SetReset(RESET_CHAIN)
					e2:SetLabelObject(e1)
					Duel.RegisterEffect(e2,tp)
				elseif (r&REASON_MATERIAL)>0 or not re:IsActivated() and (r&REASON_COST)>0 then
					setf(e,re)
					--e:SetLabelObject(re)
					local reset_event=EVENT_SPSUMMON
					if re:GetCode()~=EFFECT_SPSUMMON_PROC then reset_event=EVENT_SUMMON end
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(reset_event)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetOperation(Auxiliary.ThisCardInLocationAlreadyReset1(getf))
					e1:SetLabelObject(e)
					Duel.RegisterEffect(e1,tp)
				end
			
				return false
			end
end
function Auxiliary.ThisCardInLocationAlreadyReset1(getf)
	return	function(e)
				--this will run after EVENT_SPSUMMON_SUCCESS
				getf(e):SetLabelObject(nil)
				e:Reset()
			end
end
function Auxiliary.ThisCardInLocationAlreadyReset2(getf)
	return	function(e)
				local e1=e:GetLabelObject()
				getf(e1):SetLabelObject(nil)
				e1:Reset()
				e:Reset()
			end
end

-----------------------------------------------------------------------
SCRIPT_REGISTER_FLAG = nil

function Auxiliary.HOPT(oath)
	if oath then
		return {true,false,true}
	else
		return true
	end
end
function Auxiliary.SHOPT(oath)
	if oath then
		return {true,true,true}
	else
		return {true,true}
	end
end

function Card.Ignition(c,desc,ctg,prop,range,ctlim,cond,cost,tg,op,reset,quickcon)
	if not range then range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE end
	---
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	if ctg then
		if aux.GetValueType(ctg)=="table" then
			e1:SetCategory(ctg[1])
			if #ctg>1 then
				e1:SetCustomCategory(ctg[2])
			end
		else
			e1:SetCategory(ctg)
		end
	end
	if aux.GetValueType(prop)=="number" and prop~=0 then
		e1:SetProperty(prop)
	end	
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(range)
	if ctlim then
		if type(ctlim)=="boolean" then
			e1:HOPT()
		elseif type(ctlim)=="table" then
			if type(ctlim[1])=="boolean" then
				local shopt=ctlim[2]
				local oath=ctlim[3]
				if shopt then
					e1:SHOPT(oath)
				else
					e1:HOPT(oath)
				end
			else
				local flag=#ctlim>2 and ctlim[3] or 0
				e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
			end
		else
			e1:SetCountLimit(ctlim)
		end
	end
	if cond then
		e1:SetCondition(cond)
	end
	if cost then
		e1:SetCost(cost)
	end
	if tg then
		e1:SetTarget(tg)
	end
	if op then
		e1:SetOperation(op)
	end
	if reset then
		e1:SetReset(reset)
	end
	c:RegisterEffect(e1)
	--
	if quickcon then
		local e2=e1:Clone()
		if desc then
			e2:Desc(desc+1)
		end
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		if e1:GetCategory()&(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)>0 then
			local prop = aux.GetValueType(prop)=="number" and prop or 0
			e2:SetProperty(prop+EFFECT_FLAG_DAMAGE_STEP)
			quickcon=aux.AND(quickcon,aux.ExceptOnDamageCalc)
		end
		if ctlim and aux.GetValueType(ctlim)=="number" then
			e1:SetCountLimit(ctlim,EFFECT_COUNT_CODE_SINGLE)
			e2:SetCountLimit(ctlim,EFFECT_COUNT_CODE_SINGLE)
		end
		if cond then
			e2:SetCondition(aux.AND(cond,quickcon))
			e1:SetCondition(aux.NOT(aux.AND(cond,quickcon)))
		else
			e2:SetCondition(quickcon)
			e1:SetCondition(aux.NOT(quickcon))
		end
		c:RegisterEffect(e2)
		return e1,e2
	end
	return e1
end
function Card.Activate(c,desc,ctg,prop,event,ctlim,cond,cost,tg,op,handcon,timing)
	local event = event and event or EVENT_FREE_CHAIN
	---
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	if ctg then
		if aux.GetValueType(ctg)=="table" then
			e1:SetCategory(ctg[1])
			if #ctg>1 then
				e1:SetCustomCategory(ctg[2])
			end
		else
			e1:SetCategory(ctg)
		end
	end
	if prop~=nil then
		e1:SetProperty(prop)
	end	
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(event)
	if ctlim then
		if type(ctlim)=="boolean" then
			e1:HOPT()
		elseif type(ctlim)=="table" then
			if type(ctlim[1])=="boolean" then
				local shopt=ctlim[2]
				local oath=ctlim[3]
				if shopt then
					e1:SHOPT(oath)
				else
					e1:HOPT(oath)
				end
			else
				local flag=#ctlim>2 and ctlim[3] or 0
				e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
			end
		else
			e1:SetCountLimit(ctlim)
		end
	end
	if timing then
		if type(timing)=="table" then
			e1:SetHintTiming(timing[1],timing[2])
		else
			e1:SetHintTiming(0,timing)
		end
	end
	if cond then
		e1:SetCondition(cond)
	end
	if cost then
		e1:SetCost(cost)
	end
	if tg then
		e1:SetTarget(tg)
	end
	if op then
		e1:SetOperation(op)
	end
	if reset then
		e1:SetReset(reset)
	end
	c:RegisterEffect(e1)
	--
	if handcon and c:GetOriginalType()&(TYPE_QUICKPLAY+TYPE_TRAP)>0 then
		local handcode = c:GetOriginalType()&TYPE_TRAP==0 and EFFECT_QP_ACT_IN_NTPHAND or EFFECT_TRAP_ACT_IN_HAND
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
		e2:SetRange(LOCATION_HAND)
		e2:SetCondition(handcon)
		c:RegisterEffect(e2)
		return e1,e2
	end
	return e1
end
function Card.Quick(c,forced,desc,ctg,prop,event,range,ctlim,cond,cost,tg,op,timing)
	if not range then range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE end
	if not event then event=EVENT_FREE_CHAIN end
	local quick_type=(not forced) and EFFECT_TYPE_QUICK_O or EFFECT_TYPE_QUICK_F
	---
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	if ctg then
		if aux.GetValueType(ctg)=="table" then
			e1:SetCategory(ctg[1])
			if #ctg>1 then
				e1:SetCustomCategory(ctg[2])
			end
		else
			e1:SetCategory(ctg)
		end
	end
	if prop~=nil then
		if aux.GetValueType(prop)=="boolean" and prop==true then
			e1:SetProperty(EFFECT_FLAG_DELAY)
		else
			e1:SetProperty(prop)
		end
	end	
	e1:SetType(quick_type)
	e1:SetCode(event)
	e1:SetRange(range)
	if ctlim then
		if type(ctlim)=="boolean" then
			e1:HOPT()
		elseif type(ctlim)=="table" then
			if type(ctlim[1])=="boolean" then
				local shopt=ctlim[2]
				local oath=ctlim[3]
				if shopt then
					e1:SHOPT(oath)
				else
					e1:HOPT(oath)
				end
			else
				local flag=#ctlim>2 and ctlim[3] or 0
				e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
			end
		else
			e1:SetCountLimit(ctlim)
		end
	end
	if timing then
		if type(timing)=="table" then
			e1:SetHintTiming(timing[1],timing[2])
		else
			e1:SetHintTiming(0,timing)
		end
	end
	if cond then
		e1:SetCondition(cond)
	end
	if cost then
		e1:SetCost(cost)
	end
	if tg then
		e1:SetTarget(tg)
	end
	if op then
		e1:SetOperation(op)
	end
	c:RegisterEffect(e1)
	return e1
end

function Card.CreateNegateEffect(c,negateact,rp,rf,desc,range,ctlim,cond,cost,tg,negatedop,negatecat)
	local negcategory = negateact and CATEGORY_NEGATE or CATEGORY_DISABLE
	local negcategory2 = (negatecat and negatecat) or (type(negatedop)=="number" and negatedop) or 0
	local negatedop = negatedop or 0
	if c:IsOriginalType(TYPE_MONSTER) then
		local range = range and range or (c:IsOriginalType(TYPE_MONSTER)) and LOCATION_MZONE or (c:IsOriginalType(TYPE_FIELD)) and LOCATION_FZONE or LOCATION_SZONE
		local e1=Effect.CreateEffect(c)
		if desc then
			e1:Desc(desc)
		end
		e1:SetCategory(negcategory+negcategory2)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		if negateact then
			e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		end
		e1:SetCode(EVENT_CHAINING)
		e1:SetRange(range)
		if ctlim then
			if type(ctlim)=="boolean" then
				e1:HOPT()
			elseif type(ctlim)=="table" then
				if type(ctlim[1])=="boolean" then
					local shopt=ctlim[2]
					local oath=ctlim[3]
					if shopt then
						e1:SHOPT(oath)
					else
						e1:HOPT(oath)
					end
				else
					local flag=#ctlim>2 and ctlim[3] or 0
					e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
				end
			else
				e1:SetCountLimit(ctlim)
			end
		end
		e1:SetCondition(aux.NegateCondition(true,negateact,rp,rf,cond))
		if cost then e1:SetCost(cost) end
		e1:SetTarget(aux.NegateTarget(negateact,negatedop,tg))
		e1:SetOperation(aux.NegateOperation(negateact,negatedop))
		c:RegisterEffect(e1)
	else
		local e1=Effect.CreateEffect(c)
		if desc then
			e1:Desc(desc)
		end
		e1:SetCategory(negcategory+negcategory2)
		if not range then
			e1:SetType(EFFECT_TYPE_ACTIVATE)
		else
			e1:SetType(EFFECT_TYPE_QUICK_O)
			e1:SetRange(range)
		end
		if negateact then
			e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		end
		e1:SetCode(EVENT_CHAINING)
		if ctlim then
			if type(ctlim)=="boolean" then
				e1:HOPT()
			elseif type(ctlim)=="table" then
				if type(ctlim[1])=="boolean" then
					local shopt=ctlim[2]
					local oath=ctlim[3]
					if shopt then
						e1:SHOPT(oath)
					else
						e1:HOPT(oath)
					end
				else
					local flag=#ctlim>2 and ctlim[3] or 0
					e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
				end
			else
				e1:SetCountLimit(ctlim)
			end
		end
		e1:SetCondition(aux.NegateCondition(false,negateact,rp,rf,cond))
		if cost then e1:SetCost(cost) end
		e1:SetTarget(aux.NegateTarget(negateact,negatedop,tg))
		e1:SetOperation(aux.NegateOperation(negateact,negatedop))
		c:RegisterEffect(e1)
	end
end

--ARCHETYPAL FUNCTIONS

----ILLUSION MONSTERS
function Auxiliary.AddIllusionBattleEffect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.IllusionBattleEffectTarget)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.IllusionBattleEffectTarget(e,c)
	local h=e:GetHandler()
	return c==h or c==h:GetBattleTarget()
end

----AIRCASTER
function Auxiliary.AddAircasterExcavateEffect(c,ct,typ,desc,id,e,cat,altf)
	if typ==EFFECT_TYPE_TRIGGER_O then
		local e1=Effect.CreateEffect(c)
		e1:Desc(desc)
		e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DECKDES)
		e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetTarget(aux.AircasterExcavateTarget(ct))
		e1:SetOperation(aux.AircasterExcavateOperation(ct))
		c:RegisterEffect(e1)
		local e2=e1:SpecialSummonEventClone(c)
		local e3=e1:FlipSummonEventClone(c)
		return e1,e2,e3
	
	elseif typ==EFFECT_TYPE_QUICK_O then
		if not cat then cat=0 end
		local e1=Effect.CreateEffect(c)
		e1:Desc(desc)
		e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DECKDES|cat)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_HAND)
		e1:SetRelevantTimings()
		e1:SetTarget(aux.AircasterExcavateTarget(ct,typ,id,e))
		e1:SetOperation(aux.AircasterExcavateOperation(ct,typ,id,e,altf))
		c:RegisterEffect(e1)
		return e1
	
	elseif typ==EFFECT_TYPE_IGNITION then
		local e1=Effect.CreateEffect(c)
		e1:Desc(desc)
		e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DECKDES)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		if id then
			e1:SetCost(aux.DetachSelfCost())
		else
			e1:OPT()
		end
		e1:SetTarget(aux.AircasterExcavateTarget(ct))
		e1:SetOperation(aux.AircasterExcavateOperation(ct))
		c:RegisterEffect(e1)
		return e1
	end
end
function Auxiliary.AircasterExcavateFilter(c,altf)
	return c:IsMonster() and ((not altf and c:IsRace(RACE_PSYCHIC)) or (altf and c:IsSetCard(ARCHE_AIRCASTER))) and c:IsAbleToGrave()
end
function Auxiliary.AircasterExcavateTarget(ct,typ,id)
	if not typ then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,ct) end
					Duel.SetTargetPlayer(tp)
					Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
				end
	
	elseif typ==EFFECT_TYPE_QUICK_O then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if chk==0 then return not c:HasFlagEffect(id) and c:IsAbleToGrave() end
					c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
					Duel.SetCardOperationInfo(c,CATEGORY_TOGRAVE)
					Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
				end
	end
end
function Auxiliary.AircasterExcavateOperation(ct,typ,id,ge,altf)
	if not typ then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local p=Duel.GetTargetPlayer()
					if not Duel.IsPlayerCanDiscardDeck(p,ct) then return end
					Duel.ConfirmDecktop(p,ct)
					local g=Duel.GetDecktopGroup(p,ct)
					local sg=g:Filter(aux.AircasterExcavateFilter,nil,altf)
					if #sg>0 then
						Duel.DisableShuffleCheck()
						Duel.SendtoGrave(sg,REASON_EFFECT|REASON_EXCAVATE)
					end
					Duel.ShuffleDeck(p)
				end
	
	elseif typ==EFFECT_TYPE_QUICK_O then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if c:IsRelateToChain() and Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsInGY() and Duel.IsPlayerCanDiscardDeck(tp,ct) and c:AskPlayer(tp,STRING_ASK_EXCAVATE) then
						if ge then
							local eff=ge:Clone()
							eff:SetLabel(e:GetFieldID())
							Duel.RegisterEffect(eff,tp)
						end
						Duel.BreakEffect()
						Duel.ConfirmDecktop(p,ct)
						local g=Duel.GetDecktopGroup(p,ct)
						local sg=g:Filter(aux.AircasterExcavateFilter,nil)
						if #sg>0 then
							Duel.DisableShuffleCheck()
							Duel.SendtoGrave(sg,REASON_EFFECT|REASON_EXCAVATE)
						end
						Duel.ShuffleDeck(p)
					end
				end
	end
end

function Auxiliary.AddAircasterEquipEffect(c,desc)
	local e1=Effect.CreateEffect(c)
	e1:Desc(desc)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(aux.AircasterEquipCond)
	e1:SetTarget(aux.AircasterEquipTarget)
	e1:SetOperation(aux.AircasterEquipOperation)
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.AircasterEquipCond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:GetReason()&(REASON_EFFECT|REASON_EXCAVATE)==REASON_EFFECT|REASON_EXCAVATE
end
function Auxiliary.AircasterEquipTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local c=e:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,c:GetControler(),c:GetLocation())
	if c:IsInGY() then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,c:GetControler(),0)
	end
end
function Auxiliary.AircasterEquipOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsRelateToChain() then return end
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	if tc:IsFacedown() or not tc:IsRelateToChain() then
		if not c:IsLocation(LOCATION_GB) then
			Duel.SendtoGrave(c,REASON_RULE)
		end
		return
	end
	Duel.EquipToOtherCardAndRegisterLimit(e,tp,c,tc)
end

----DREAMY/DREARY FOREST
function Auxiliary.AddDreamyDrearyTransformation(c,status)
	local side = status==ARCHE_DREARY_FOREST and SIDE_REVERSE or SIDE_OBVERSE
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetCondition(Auxiliary.DreamyDrearyTransformationCondition(status))
	e1:SetTarget(aux.IsCanTransformTargetFunction)
	e1:SetOperation(aux.TransformOperationFunction(side))
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.DreamyDrearyTransformationCondition(status)
	if status==ARCHE_DREARY_FOREST then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					return Duel.GetTurnPlayer()==tp
				end
	elseif status==ARCHE_DREAMY_FOREST then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					return Duel.GetTurnPlayer()==1-tp
						and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_DREAMY_FOREST,ARCHE_DREARY_FOREST),tp,LOCATION_ONFIELD,0,1,e:GetHandler())
				end
	end
end

----OSCURION
function Auxiliary.RegisterOscurionDiscardCostEffectFlag(c,e)
	local prop=EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE
	if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(prop)
	e3:SetCode(CARD_OSCURION_TYPE0)
	e3:SetLabelObject(e)
	e3:SetLabel(c:GetOriginalCode())
	c:RegisterEffect(e3)
end
function Auxiliary.RegisterOscurionDriveSummonEffectFlag(c,e)
	local prop=EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE
	if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(prop)
	e3:SetCode(CARD_OSCURION_TYPE2)
	e3:SetLabelObject(e)
	e3:SetLabel(c:GetOriginalCode())
	c:RegisterEffect(e3)
end

----VAISSEAU
function Auxiliary.RegisterVaisseauPendulumEffectFlag(c,pe)
	local prop=EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE
	if pe:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(prop)
	e3:SetCode(CARD_ROI_DU_VAISSEAU)
	e3:SetLabelObject(pe)
	e3:SetLabel(c:GetOriginalCode())
	c:RegisterEffect(e3)
end
function Auxiliary.VaisseauQECondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()==1-tp or c:IsSummonType(SUMMON_TYPE_RITUAL)
end

----ZEROST
--[[Scripts the following effect template:
● You can only use 1 "Zerost Moby" effect per turn, and only once that turn.

① If this card is in your hand or GY: You can roll a six-sided die, banish other monsters from your field and/or GY equal to the result, and if you do, Special Summon this card, and if you do that, its ATK/DEF become equal to the number of monsters banished by this effect x 400.
② If this card is banished by the effect of a "Zerost" card: ...]]
function Auxiliary.AddZerostMonsterEffects(c,category,property,target,operation)
	if not property then property=0 end
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DICE|CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SHOPT()
	e1:SetTarget(Auxiliary.ZerostFirstMonsterEffectTarget)
	e1:SetOperation(Auxiliary.ZerostFirstMonsterEffectOperation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	if category then
		e2:SetCategory(category)
	end
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|property)
	e2:SetCode(EVENT_REMOVE)
	e2:SHOPT()
	e2:SetCondition(Auxiliary.ZerostSecondMonsterEffectCondition)
	e2:SetTarget(target)
	e2:SetOperation(operation)
	c:RegisterEffect(e2)
	--
	local prop=EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE
	if e2:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(prop)
	e3:SetCode(CARD_ZEROST_BEAST_ZEROTL)
	e3:SetLabelObject(e2)
	e3:SetLabel(c:GetOriginalCode())
	c:RegisterEffect(e3)
	local s=getmetatable(c)
	if s.toss_dice==nil then
		s.toss_dice=true
	end
	return e1,e2
end
function Auxiliary.ZerostFirstMonsterEffectFilter(c,tp,zonechk)
	return (c:IsLocation(LOCATION_MZONE) or c:IsMonster()) and c:IsAbleToRemove() and (not zonechk or Duel.GetMZoneCount(tp,c)>0)
end
function Auxiliary.ZerostFirstMonsterEffectTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.ZerostFirstMonsterEffectFilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,c,tp,true) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE|LOCATION_GRAVE)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function Auxiliary.ZerostFirstMonsterEffectOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dc=Duel.TossDice(tp,1)
	local g=Duel.Group(aux.NecroValleyFilter(aux.ZerostFirstMonsterEffectFilter),tp,LOCATION_MZONE|LOCATION_GRAVE,0,aux.ExceptThis(c),tp)
	if #g>=dc then
		local rg=Group.CreateGroup()
		if Duel.GetMZoneCount(tp)<=0 then
			Duel.HintMessage(tp,HINTMSG_REMOVE)
			local rg0=g:FilterSelect(tp,function(card,p) return Duel.GetMZoneCount(p,card)>0 end,1,1,nil,tp)
			rg:Merge(rg0)
			g:Sub(rg0)
			dc=dc-1
		end
		if dc>0 then
			Duel.HintMessage(tp,HINTMSG_REMOVE)
			local rg1=g:Select(tp,dc,dc,nil)
			rg:Merge(rg1)
		end
		if #rg>0 then
			Duel.HintSelection(rg)
			local ct=Duel.Banish(rg)
			if ct>0 and c:IsRelateToChain() and Duel.GetMZoneCount(tp)>0 and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK)
				e1:SetValue(ct*400)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_DISABLE)
				c:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_SET_DEFENSE)
				c:RegisterEffect(e2)
			end
			Duel.SpecialSummonComplete()
		end
	end
end
function Auxiliary.ZerostSecondMonsterEffectCondition(e,tp,eg,ep,ev,re,r,rp)
	if r&REASON_EFFECT==0 or not re then return false end
	local rc=re:GetHandler()
	return rc and rc:IsSetCard(ARCHE_ZEROST)
end

function Auxiliary.AddZerostDiceModifier(c,id,etyp)
	if not etyp then etyp=EFFECT_TYPE_IGNITION end
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(etyp)
	if etyp==EFFECT_TYPE_QUICK_O then
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetHintTiming(0,RELEVANT_TIMINGS)
	end
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(Auxiliary.RegisterZerostDiceModifier(id))
	c:RegisterEffect(e2)
	return e2
end
function Auxiliary.RegisterZerostDiceModifier(id)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_TOSS_DICE_NEGATE)
				e1:SetOperation(Auxiliary.ZerostDiceModifierOperation(id))
				Duel.RegisterEffect(e1,tp)
			end
end
function Auxiliary.ZerostDiceModifierOperation(id)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not re or not re:IsActivated() then return end
				if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					Duel.Hint(HINT_CARD,0,e:GetHandler():GetOriginalCode())
					local dc={Duel.GetDiceResult()}
					local ac=1
					local ct=(ev&0xff)+(ev>>16&0xff)
					if ct>1 then
						Duel.Hint(HINT_SELECTMSG,tp,STRING_INPUT_DICE_ROLL)
						local _,idx=Duel.AnnounceNumber(tp,table.unpack(aux.idx_table,1,ct))
						ac=idx+1
					end
					local val=dc[ac]
					local increase=val<6
					local reduce=val>1
					local opt=aux.Option(tp,0,0,{increase,STRING_INCREASE_DICE_RESULT},{reduce,STRING_DECREASE_DICE_RESULT})
					if opt==0 then
						val=val+1
					else
						val=val-1
					end
					dc[ac]=val
					Duel.SetDiceResult(table.unpack(dc))
				end
				e:Reset()
			end
end