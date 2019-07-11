--Not yet finalized values
--Custom constants
EFFECT_STAGE						=388		--
EFFECT_CANNOT_BE_EVOLUTE_MATERIAL	=389	 --
EFFECT_EXTRA_EVOLUTE_MATERIAL		=390
EFFECT_EVOLUTE_LEVEL				=391
EFFECT_MUST_BE_EVOLUTE_MATERIAL		=392
EFFECT_CONVERGENT_EVOLUTE			=393
EFFECT_CONJOINT_EVOLUTE_RATING		=394
EFFECT_BIGBANG						=624
EFFECT_CANNOT_BE_BIGBANG_MATERIAL	=625
EFFECT_MUST_BE_BIGBANG_MATERIAL		=626
EFFECT_PANDEMONIUM					=726
EFFECT_STABLE						=765
EFFECT_CANNOT_BE_POLARITY_MATERIAL	=766
EFFECT_DIMENSION_NUMBER				=500
EFFECT_CANNOT_BE_SPACE_MATERIAL		=501
EFFECT_CORONA_DRAW_COST				=550
EFFECT_DEFAULT_CALL					=31993443
EFFECT_EXTRA_GEMINI					=86433590
EFFECT_AVAILABLE_LMULTIPLE			=86433612
EFFECT_MULTIPLE_LMATERIAL			=86433613
EFFECT_RANDOM_TARGET				=39759371
EFFECT_CANNOT_BE_TIMELEAP_MATERIAL	=825
EFFECT_MUST_BE_TIMELEAP_MATERIAL	=826
EFFECT_FUTURE						=827
EFFECT_CANNOT_BANISH_FD_EFFECT		=856
TYPE_EVOLUTE						=0x100000000
TYPE_PANDEMONIUM					=0x200000000
TYPE_POLARITY						=0x400000000
TYPE_SPATIAL						=0x800000000
TYPE_CORONA							=0x1000000000
TYPE_SKILL							=0x2000000000
TYPE_CONJOINT						=0x4000000000
TYPE_BIGBANG						=0x8000000000
TYPE_TIMELEAP						=0x10000000000
TYPE_DECKMASTER						=0x40000000000
TYPE_CUSTOM							=TYPE_EVOLUTE+TYPE_PANDEMONIUM+TYPE_POLARITY+TYPE_SPATIAL+TYPE_CORONA+TYPE_SKILL+TYPE_DECKMASTER+TYPE_CONJOINT+TYPE_BIGBANG+TYPE_TIMELEAP

CTYPE_EVOLUTE						=0x1
CTYPE_PANDEMONIUM					=0x2
CTYPE_POLARITY						=0x4
CTYPE_SPATIAL						=0x8
CTYPE_CORONA						=0x10
CTYPE_SKILL							=0x20
CTYPE_CONJOINT						=0x40
CTYPE_BIGBANG						=0x80
CTYPE_TIMELEAP						=0x100
CTYPE_DECKMASTER					=0x400
CTYPE_CUSTOM						=CTYPE_EVOLUTE+CTYPE_PANDEMONIUM+CTYPE_POLARITY+CTYPE_SPATIAL+CTYPE_CORONA+CTYPE_SKILL+CTYPE_DECKMASTER+CTYPE_CONJOINT+TYPE_BIGBANG+TYPE_TIMELEAP

SUMMON_TYPE_EVOLUTE					=SUMMON_TYPE_SPECIAL+388
SUMMON_TYPE_SPATIAL					=SUMMON_TYPE_SPECIAL+500
SUMMON_TYPE_MASTER					=SUMMON_TYPE_SPECIAL+3338
SUMMON_TYPE_TIMELEAP				=SUMMON_TYPE_SPECIAL+825

EVENT_CORONA_DRAW					=EVENT_CUSTOM+0x1600000000
EVENT_XYZATTACH						=EVENT_CUSTOM+9966607
EVENT_LP_CHANGE						=EVENT_CUSTOM+68007397

EFFECT_COUNT_SECOND_HOPT			=10000000

--Commonly used cards
CARD_BLUEEYES_SPIRIT				=59822133
CARD_CYBER_DRAGON					=70095154
CARD_INLIGHTENED_PSYCHIC_HELMET		=210400006
CARD_REDUNDANCY_TOKEN				=210400054
CARD_NEBULA_TOKEN					=218201917

--Custom Type Tables
Auxiliary.Customs={} --check if card uses custom type, indexing card
Auxiliary.Evolutes={} --number as index = card, card as index = function() is_xyz
Auxiliary.Conjoints={} --number as index = card, card as index = function() is_xyz
Auxiliary.Bigbangs={} --number as index = card, card as index = function() is_synchro
Auxiliary.Pandemoniums={} --number as index = card, card as index = function() is_pendulum
Auxiliary.Polarities={} --number as index = card, card as index = function() is_synchro
Auxiliary.Spatials={} --number as index = card, card as index = function() is_xyz
Auxiliary.Coronas={} --number as index = card, card as index = function() is_fusion
Auxiliary.Skills={} --number as index = card, card as index = function() is_pendulum
Auxiliary.Deckmasters={} --number as index = card, card as index = function() is_fusion
Auxiliary.Timeleaps={} --number as index = card, card as index = function() is_synchro

--overwrite constants
TYPE_EXTRA=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_EVOLUTE+TYPE_POLARITY+TYPE_SPATIAL+TYPE_CORONA+TYPE_DECKMASTER+TYPE_BIGBANG+TYPE_TIMELEAP

--Custom Functions
function Card.IsCustomType(c,tpe,scard,sumtype,p)
	return (c:GetType(scard,sumtype,p)>>32)&tpe>0
end
function GetID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local scard=_G[str]
	local s_id=tonumber(string.sub(str,2))
	return scard,s_id
end

--overwrite functions
local get_rank, get_orig_rank, prev_rank_field, is_rank, is_rank_below, is_rank_above, get_type, is_type, get_orig_type, get_prev_type_field, get_level, get_syn_level, get_rit_level, get_orig_level, is_xyz_level, 
	get_prev_level_field, is_level, is_level_below, is_level_above, change_position, card_remcounter, duel_remcounter, card_is_able_to_extra, card_is_able_to_extra_as_cost, duel_draw, registereff, effect_set_target_range, add_xyz_proc, add_xyz_proc_nlv,
	duel_overlay, duel_set_lp, duel_select_target, duel_banish = 
	Card.GetRank, Card.GetOriginalRank, Card.GetPreviousRankOnField, Card.IsRank, Card.IsRankBelow, Card.IsRankAbove, Card.GetType, Card.IsType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetLevel, 
	Card.GetSynchroLevel, Card.GetRitualLevel, Card.GetOriginalLevel, Card.IsXyzLevel, Card.GetPreviousLevelOnField, Card.IsLevel, Card.IsLevelBelow, Card.IsLevelAbove, Duel.ChangePosition, Card.RemoveCounter, 
	Duel.RemoveCounter, Card.IsAbleToExtra, Card.IsAbleToExtraAsCost, Duel.Draw, Card.RegisterEffect, Effect.SetTargetRange, 
	Auxiliary.AddXyzProcedure, Auxiliary.AddXyzProcedureLevelFree, Duel.Overlay, Duel.SetLP, Duel.SelectTarget, Duel.Remove

Card.GetRank=function(c)
	if Auxiliary.Evolutes[c] or Auxiliary.Spatials[c] then return 0 end
	return get_rank(c)
end
Card.GetOriginalRank=function(c)
	if (Auxiliary.Evolutes[c] and not Auxiliary.Evolutes[c]()) or (Auxiliary.Spatials[c] and not Auxiliary.Spatials[c]()) then return 0 end
	return get_orig_rank(c)
end
Card.GetPreviousRankOnField=function(c)
	if (Auxiliary.Evolutes[c] and not Auxiliary.Evolutes[c]()) or (Auxiliary.Spatials[c] and not Auxiliary.Spatials[c]()) then return 0 end
	return prev_rank_field(c)
end
Card.IsRank=function(c,...)
	if (Auxiliary.Evolutes[c] and not Auxiliary.Evolutes[c]()) or (Auxiliary.Spatials[c] and not Auxiliary.Spatials[c]()) then return false end
	local funs={...}
	for key,value in pairs(funs) do
		if c:GetRank()==value then return true end
	end
	return false
	--return is_rank(c,rk)
end
Card.IsRankBelow=function(c,rk)
	if (Auxiliary.Evolutes[c] and not Auxiliary.Evolutes[c]()) or (Auxiliary.Spatials[c] and not Auxiliary.Spatials[c]()) then return false end
	return is_rank_below(c,rk)
end
Card.IsRankAbove=function(c,rk)
	if (Auxiliary.Evolutes[c] and not Auxiliary.Evolutes[c]()) or (Auxiliary.Spatials[c] and not Auxiliary.Spatials[c]()) then return false end
	return is_rank_above(c,rk)
end
Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Evolutes[c] then
		tpe=tpe|TYPE_EVOLUTE
		if not Auxiliary.Evolutes[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	if Auxiliary.Conjoints[c] then
		tpe=tpe|TYPE_CONJOINT
	end
	if Auxiliary.Pandemoniums[c] then
		tpe=tpe|TYPE_PANDEMONIUM
		local ispen,isspell=Auxiliary.Pandemoniums[c]()
		if not ispen then
			tpe=tpe&~TYPE_PENDULUM
		end
		if c:IsLocation(LOCATION_PZONE) and not isspell then
			tpe=tpe&~TYPE_SPELL
		end
	end
	if Auxiliary.Polarities[c] then
		tpe=tpe|TYPE_POLARITY
		if not Auxiliary.Polarities[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	if Auxiliary.Bigbangs[c] then
		tpe=tpe|TYPE_BIGBANG
		if not Auxiliary.Bigbangs[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	if Auxiliary.Spatials[c] then
		tpe=tpe|TYPE_SPATIAL
		if not Auxiliary.Spatials[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	if Auxiliary.Coronas[c] then
		tpe=tpe|TYPE_CORONA
		if not Auxiliary.Coronas[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	if Auxiliary.Skills[c] then
		tpe=tpe|TYPE_SKILL
		local ispen,isspell=Auxiliary.Skills[c]()
		if not ispen then
			tpe=tpe&~TYPE_PENDULUM
		end
		if c:IsLocation(LOCATION_PZONE) and not isspell then
			tpe=tpe&~TYPE_SPELL
		end
	end
	if Auxiliary.Deckmasters[c] then
		tpe=tpe|TYPE_DECKMASTER
		if not Auxiliary.Deckmasters[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	if Auxiliary.Timeleaps[c] then
		tpe=tpe|TYPE_TIMELEAP
		if not Auxiliary.Timeleaps[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.IsType=function(c,tpe,scard,sumtype,p)
	local custpe=tpe>>32
	local otpe=tpe&0xffffffff
	if (scard and c:GetType(scard,sumtype,p)&otpe>0) or (not scard and c:GetType()&otpe>0) then return true end
	if custpe<=0 then return false end
	return c:IsCustomType(custpe,scard,sumtype,p)
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Evolutes[c] then
		tpe=tpe|TYPE_EVOLUTE
		if not Auxiliary.Evolutes[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	if Auxiliary.Conjoints[c] then
		tpe=tpe|TYPE_CONJOINT
	end
	if Auxiliary.Pandemoniums[c] then
		tpe=tpe|TYPE_PANDEMONIUM
		if not Auxiliary.Pandemoniums[c]() then
			tpe=tpe&~TYPE_PENDULUM
		end
	end
	if Auxiliary.Polarities[c] then
		tpe=tpe|TYPE_POLARITY
		if not Auxiliary.Polarities[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	if Auxiliary.Bigbangs[c] then
		tpe=tpe|TYPE_BIGBANG
		if not Auxiliary.Bigbangs[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	if Auxiliary.Spatials[c] then
		tpe=tpe|TYPE_SPATIAL
		if not Auxiliary.Spatials[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	if Auxiliary.Coronas[c] then
		tpe=tpe|TYPE_CORONA
		if not Auxiliary.Coronas[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	if Auxiliary.Skills[c] then
		tpe=tpe|TYPE_SKILL
		if not Auxiliary.Skills[c]() then
			tpe=tpe&~TYPE_PENDULUM
		end
	end
	if Auxiliary.Deckmasters[c] then
		tpe=tpe|TYPE_DECKMASTER
		if not Auxiliary.Deckmasters[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	if Auxiliary.Timeleaps[c] then
		tpe=tpe|TYPE_TIMELEAP
		if not Auxiliary.Timeleaps[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Evolutes[c] then
		tpe=tpe|TYPE_EVOLUTE
		if not Auxiliary.Evolutes[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	if Auxiliary.Conjoints[c] then
		tpe=tpe|TYPE_CONJOINT
	end
	if Auxiliary.Pandemoniums[c] then
		tpe=tpe|TYPE_PANDEMONIUM
		local ispen,isspell=Auxiliary.Pandemoniums[c]()
		if not ispen then
			tpe=tpe&~TYPE_PENDULUM
		end
		if c:IsPreviousLocation(LOCATION_PZONE) and not isspell then
			tpe=tpe&~TYPE_SPELL
		end
	end
	if Auxiliary.Polarities[c] then
		tpe=tpe|TYPE_POLARITY
		if not Auxiliary.Polarities[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	if Auxiliary.Bigbangs[c] then
		tpe=tpe|TYPE_BIGBANG
		if not Auxiliary.Bigbangs[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	if Auxiliary.Spatials[c] then
		tpe=tpe|TYPE_SPATIAL
		if not Auxiliary.Spatials[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	if Auxiliary.Coronas[c] then
		tpe=tpe|TYPE_CORONA
		if not Auxiliary.Coronas[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	if Auxiliary.Skills[c] then
		tpe=tpe|TYPE_SKILL
		local ispen,isspell=Auxiliary.Skills[c]()
		if not ispen then
			tpe=tpe&~TYPE_PENDULUM
		end
		if c:IsLocation(LOCATION_PZONE) and not isspell then
			tpe=tpe&~TYPE_SPELL
		end
	end
	if Auxiliary.Deckmasters[c] then
		tpe=tpe|TYPE_DECKMASTER
		if not Auxiliary.Deckmasters[c]() then
			tpe=tpe&~TYPE_FUSION
		end
	end
	if Auxiliary.Timeleaps[c] then
		tpe=tpe|TYPE_TIMELEAP
		if not Auxiliary.Timeleaps[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetLevel=function(c)
	if Auxiliary.Polarities[c] and not Auxiliary.Polarities[c]() then return 0 end
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return 0 end
	return get_level(c)
end
GetSynchroLevel=function(c,sc)
	if Auxiliary.Polarities[c] and not Auxiliary.Polarities[c]() then return 0 end
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return 0 end
	return get_syn_level(c,sc)
end
Card.GetRitualLevel=function(c,rc)
	if Auxiliary.Polarities[c] and not Auxiliary.Polarities[c]() then return 0 end
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return 0 end
	return get_rit_level(c,rc)
end
Card.GetOriginalLevel=function(c)
	if Auxiliary.Polarities[c] and not Auxiliary.Polarities[c]() then return 0 end
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return 0 end
	return get_orig_level(c)
end
Card.IsXyzLevel=function(c,xyz,lv)
	if Auxiliary.Polarities[c] and not Auxiliary.Polarities[c]() then return false end
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return 0 end
	return is_xyz_level(c,xyz,lv)
end
Card.GetPreviousLevelOnField=function(c)
	if Auxiliary.Polarities[c] and not Auxiliary.Polarities[c]() then return 0 end
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return 0 end
	return get_prev_level_field(c)
end
Card.IsLevel=function(c,...)
	if Auxiliary.Polarities[c] and not Auxiliary.Polarities[c]() then return false end
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return false end
	local funs={...}
	for key,value in pairs(funs) do
		if c:GetLevel()==value then return true end
	end
	return false
	--return is_level(c,lv)
end
Card.IsLevelBelow=function(c,lv)
	if Auxiliary.Polarities[c] and not Auxiliary.Polarities[c]() then return false end
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return false end
	return is_level_below(c,lv)
end
Card.IsLevelAbove=function(c,lv)
	if Auxiliary.Polarities[c] and not Auxiliary.Polarities[c]() then return false end
	if Auxiliary.Timeleaps[c] and not Auxiliary.Timeleaps[c]() then return false end
	return is_level_above(c,lv)
end
Duel.ChangePosition=function(cc, au, ad, du, dd)
	if not ad then ad=au end if not du then du=au end if not dd then dd=au end
	local cc=Group.CreateGroup()+cc
	local tg=cc:Clone()
	for c in aux.Next(tg) do
		if c:SwitchSpace() then cc=cc-c end
	end
	return change_position(cc,au,ad,du,dd)
end

Card.RemoveCounter=function(c,p,typ,ct,r)
	local n=c:GetCounter(typ)
	card_remcounter(c,p,typ,ct,r)
	if n-c:GetCounter(typ)==ct then return true else return false end
end

Duel.RemoveCounter=function(p,s,o,typ,ct,r,rp)
	if rp==nil or rp==PLAYER_NONE --[[2]] then
		duel_remcounter(p,s,o,typ,ct,r)
		return nil
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
Card.IsAbleToExtra=function(c)
	if Auxiliary.Coronas[c] then return true end
	return card_is_able_to_extra(c)
end
Card.IsAbleToExtraAsCost=function(c)
	if Auxiliary.Coronas[c] then return true end
	return card_is_able_to_extra_as_cost(c)
end
Duel.Draw=function(tp,ct,r)
	local newct = ct
	if (Duel.GetFlagEffect(tp,1600000000)==0) and Duel.IsExistingMatchingCard(Auxiliary.CoronaFilterNeo,tp,LOCATION_EXTRA,0,1,nil,ct) and Duel.SelectYesNo(tp,572) then
		local tc = Auxiliary.CoronaOp(tp,ct,REASON_RULE)
		newct = ct - 1 --tc:GetAura()
		Duel.RaiseEvent(tc,EVENT_CORONA_DRAW,nil,r,tp,tp,99)
	end
	return duel_draw(tp,newct,r) + (ct-newct)
end
Card.RegisterEffect=function(c,e,forced)
	if c:IsStatus(STATUS_INITIALIZING) and not e then return end
	registereff(c,e,forced)
	local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
	if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
	local ex=Effect.CreateEffect(c)
	ex:SetType(EFFECT_TYPE_SINGLE)
	ex:SetProperty(prop)
	ex:SetCode(EFFECT_DEFAULT_CALL)
	ex:SetLabelObject(e)
	ex:SetLabel(c:GetOriginalCode())
	registereff(c,ex,forced)
end
Auxiliary.kaiju_procs={}
Effect.SetTargetRange=function(e,self,oppo)
	if e:GetCode()==EFFECT_SPSUMMON_PROC or e:GetCode()==EFFECT_SPSUMMON_PROC_G then
		if oppo==1 then
			table.insert(Auxiliary.kaiju_procs,e)
		end
	end
	effect_set_target_range(e,self,oppo)
end
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
		oct=og:GetCount()
	end
	duel_overlay(xyz,mat)
	if oct and xyz:GetOverlayCount()>oct then
		Duel.RaiseEvent(mat,EVENT_XYZATTACH,nil,0,0,xyz:GetControler(),xyz:GetOverlayCount()-oct)
	end
end
Duel.SetLP=function(p,setlp,...)
	local opt={...}
	local rule,rplayer=nil,0
	if opt[1] then reason=opt[1] end
	if opt[2] then rplayer=opt[2] end
	local prev=Duel.GetLP(p)
	local event_test=Duel.GetMatchingGroup(aux.TRUE,p,0xff,0xff,nil):GetFirst()
	duel_set_lp(p,setlp)
	if not rule and Duel.GetLP(p)~=prev then
		Duel.RaiseEvent(event_test,EVENT_LP_CHANGE,nil,REASON_EFFECT,rplayer,p,Duel.GetLP(p)-prev)
	end
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
		local rct=rg:GetCount()
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
Duel.Remove=function(cc,pos,r)
	local cc=Group.CreateGroup()+cc
	local tg=cc:Clone()
	for c in aux.Next(tg) do
		if pos&POS_FACEDOWN~=0 and r&REASON_EFFECT~=0 then
			local ef=c:IsHasEffect(EFFECT_CANNOT_BANISH_FD_EFFECT)
			local cf=ef:GetValue()
			local typ=aux.GetValueType(cf)
			if typ=="function" then
				if cf(ef,c:GetReasonEffect(),c:GetReasonPlayer()) then cc=cc-c end
			elseif cf>0 then cc=cc-c end
		end
	end
	return duel_banish(cc,pos,r)
end

--Custom Functions
--Evolutes
function Card.GetStage(c)
	if not Auxiliary.Evolutes[c] then return 0 end
	local te=c:IsHasEffect(EFFECT_STAGE)
	if type(te:GetValue())=='function' then
		return te:GetValue()(te,c)
	else
		return te:GetValue()
	end
end
function Card.IsStage(c,stage)
	return c:GetStage()==stage
end
GLOBAL_E_COUNTER={0,0}
GLOBAL_E_COUNTER[0]=0
GLOBAL_E_COUNTER[1]=0
function Auxiliary.AddECounter(p,ct)
	GLOBAL_E_COUNTER[p]=GLOBAL_E_COUNTER[p]+ct
	Duel.Hint(HINT_NUMBER,p,GLOBAL_E_COUNTER[p])
	Duel.Hint(HINT_NUMBER,1-p,GLOBAL_E_COUNTER[p])
	--TODO: Figure out how to make this work?
	--Duel.Hint(HINT_MESSAGE,p,1550,GLOBAL_E_COUNTER[p])
	--Duel.Hint(HINT_MESSAGE,1-p,1550,GLOBAL_E_COUNTER[p])
end
function Auxiliary.GetECounter(p)
	return GLOBAL_E_COUNTER[p]
end
function Card.AddEC(c,ct,p)
	c:AddCounter(0x1088,ct)
	if p then Auxiliary.AddECounter(p,ct) end
	--TODO: Remove once all Evolutes are updated
	--c:AddCounter(0x88,ct)
end
function Card.GetEC(c)
	return c:GetCounter(0x1088)
end
function Card.RefillEC(c)
	local val=0
	if c:IsHasEffect(EFFECT_CONVERGENT_EVOLUTE) then
		local cone={c:IsHasEffect(EFFECT_CONVERGENT_EVOLUTE)}
		for _,te in ipairs(cone) do
			val = val+te:GetValue()
		end
	else
		val = c:GetStage() - c:GetEC()
	end
	c:AddEC(val,c:GetControler())
	return val
end
function Card.IsCanRemoveEC(c,p,ct,r)
--  if Auxiliary.GetECounter(p)>=ct then return true end
	return c:IsCanRemoveCounter(p,0x1088,ct,REASON_COST)
end
function Duel.IsCanRemoveEC(p,s,o,ct,r)
--  if Auxiliary.GetECounter(p)>=ct then return true end
	return Duel.IsCanRemoveCounter(p,s,o,0x1088,ct,r)
end
function Card.RemoveEC(c,p,ct,r)
	if Auxiliary.GetECounter(p)>0 then
		Auxiliary.AddECounter(p,-ct)
	end
	if ct>0 then c:RemoveCounter(p,0x1088,ct,r) end
end
function Duel.RemoveEC(p,s,o,ct,r)
	if Auxiliary.GetECounter(p)>=ct then
		Auxiliary.AddECounter(p,-ct)
	end
	if ct>0 then Duel.RemoveCounter(p,s,o,0x1088,ct,r) end
end
function Card.IsCanBeEvoluteMaterial(c,ec)
	if c:GetLevel()<=0 and c:GetRank()<=0 and not c:IsStatus(STATUS_NO_LEVEL) then return false end
	if not c:IsLocation(LOCATION_MZONE) then
		local tef1={c:IsHasEffect(EFFECT_EXTRA_EVOLUTE_MATERIAL)}
		local ValidSubstitute=false
		for _,te1 in ipairs(tef1) do
			local con=te1:GetCondition()
			if con(c,ec,1) then ValidSubstitute=true end
		end
		if not ValidSubstitute then return false end
	else
		if c:IsFacedown() then return false end
	end
	local tef2={c:IsHasEffect(EFFECT_CANNOT_BE_EVOLUTE_MATERIAL)}
	for _,te2 in ipairs(tef2) do
		if te2:GetValue()(te2,ec) then return false end
	end
	return true
end
function Auxiliary.AddOrigEvoluteType(c,isxyz)
	table.insert(Auxiliary.Evolutes,c)
	Auxiliary.Customs[c]=true
	local isxyz=isxyz==nil and false or isxyz
	Auxiliary.Evolutes[c]=function() return isxyz end
end
function Auxiliary.AddEvoluteProc(c,echeck,stage,...)
	--echeck - extra check after everything is settled, stage - Evolute "level"
	--... format - any number of materials + optional material - min, max (min can be 0, max can be nil which will set it to 99)	use aux.TRUE for generic materials
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local t={...}
	if type(echeck)=='function' then table.insert(t,echeck) end
	local extramat,min,max
	if type(t[#t])=='number' then
		max=t[#t]
		table.remove(t)
		if type(t[#t])=='number' then
			min=t[#t]
			extramat=t[#t-1]
			table.remove(t)
		else
			min=max
			max=99
			extramat=t[#t]
		end
	end
	if not extramat then extramat,min,max=aux.FALSE,#t,#t end
	local r1=Effect.CreateEffect(c)
	r1:SetType(EFFECT_TYPE_SINGLE)
	r1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	r1:SetCode(EFFECT_CANNOT_TURN_SET)
	r1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(r1)
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_STAGE)
	e1:SetValue(Auxiliary.StageVal(stage))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(Auxiliary.EvoluteCondition(echeck,extramat,min,max,table.unpack(t)))
	e2:SetTarget(Auxiliary.EvoluteTarget(echeck,extramat,min,max,table.unpack(t)))
	e2:SetOperation(Auxiliary.EvoluteOperation)
	e2:SetValue(SUMMON_TYPE_EVOLUTE)
	c:RegisterEffect(e2)
	if (type(echeck)=='string') and echeck=="Convergent" then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CONVERGENT_EVOLUTE)
		c:RegisterEffect(e3)
	end
	if not Evochk then
		Evochk=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(Auxiliary.EvoluteCounter)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD)
		ge2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_IGNORE_IMMUNE)
		ge2:SetCode(EFFECT_COUNTER_PERMIT+0x88)
		ge2:SetTarget(function(e,c)return c:IsType(TYPE_EVOLUTE) end)
		ge2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		ge2:SetValue(LOCATION_MZONE)
		Duel.RegisterEffect(ge2,0)
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		ge3:SetCode(EFFECT_RCOUNTER_REPLACE+0x88)
		ge3:SetCondition(Auxiliary.ECounterUseCon)
		ge3:SetOperation(Auxiliary.ECounterUseOp)
		Duel.RegisterEffect(ge3,0)
		--Cannot be Summoned Face-down
		local ge4=Effect.CreateEffect(c)
		ge4:SetType(EFFECT_TYPE_FIELD)
		ge4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		ge4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		ge4:SetTargetRange(1,1)
		ge4:SetTarget(Auxiliary.FaceDownEvoluteLimit)
		Duel.RegisterEffect(ge4,tp)
	end
end
--Cannot be Summoned Face-down
function Auxiliary.FaceDownEvoluteLimit(e,c,sump,sumtype,sumpos,targetp,se)
	return (c:IsType(TYPE_EVOLUTE) and (sumpos==POS_FACEDOWN_ATTACK or sumpos==POS_FACEDOWN_DEFENSE))
end
--E-C Replace
function Auxiliary.ECounterUseCon(e,tp,eg,ep,ev,re,r,rp)
	return Auxiliary.GetECounter(tp)>=ev
end
function Auxiliary.ECounterUseOp(e,tp,eg,ep,ev,re,r,rp)
	Auxiliary.AddECounter(tp,-ev)
end
function Auxiliary.StageVal(stage)
	return  function(e,c)
				local stage=stage
				--insert modifications here
				return stage
			end
end
function Card.GetValueForEvolute(c,ec)
	return Auxiliary.EvoluteValue(c,ec)
end
function Auxiliary.EvoluteValue(c,ec)
	local lv=c:GetLevel()
	local rk=c:GetRank()
	if c:IsHasEffect(EFFECT_EVOLUTE_LEVEL) then
		local tef={c:IsHasEffect(EFFECT_EVOLUTE_LEVEL)}
		for _,te in ipairs(tef) do
			return te:GetValue()(te,ec)
		end
	end
	if lv>0 or c:IsStatus(STATUS_NO_LEVEL) then
		return lv+0x10000*rk
	else
		return rk+0x10000*lv
	end
end
function Auxiliary.EvoluteRecursiveFilter(c,tp,sg,mg,ec,ct,minc,maxc,...)
	sg:AddCard(c)
	if not (c.EvoFakeMaterial and c.EvoFakeMaterial()) then ct=ct+1 end
	
	local res=Auxiliary.EvoluteCheckGoal(tp,sg,ec,minc,ct,...)
		or (ct<maxc and mg:IsExists(Auxiliary.EvoluteRecursiveFilter,1,sg,tp,sg,mg,ec,ct,minc,maxc,...))
	sg:RemoveCard(c)
	if not (c.EvoFakeMaterial and c.EvoFakeMaterial()) then ct=ct-1 end
	return res
end
function Auxiliary.EvoluteCheckGoal(tp,sg,ec,minc,ct,...)
	local funs={...}
	for _,f in pairs(funs) do
		if not sg:IsExists(f,1,nil) then return false end
	end
	return ct>=minc and (ec:IsHasEffect(EFFECT_CONVERGENT_EVOLUTE) or sg:CheckWithSumEqual(Auxiliary.EvoluteValue,ec:GetStage(),ct,ct,ec)) and Duel.GetLocationCountFromEx(tp,tp,sg,ec)>0
end
function Auxiliary.EvoluteCondition(outdate1,outdate2,min,max,...)
	local funs={...}
	return  function(e,c)
				if c==nil then return true end
				if (c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_PANDEMONIUM)) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=Auxiliary.GetEvoluteMaterials(c,tp)
				return mg:IsExists(Auxiliary.EvoluteRecursiveFilter,1,nil,tp,Group.CreateGroup(),mg,c,0,min,max,table.unpack(funs))
			end
end
function Auxiliary.GetEvoluteMaterials(ec,tp)
	return Duel.GetMatchingGroup(Card.IsCanBeEvoluteMaterial,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE+LOCATION_FZONE,0,nil,ec)
end
function Auxiliary.EvoluteTarget(outdate1,outdate2,minc,maxc,...)
	local funs={...}
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Auxiliary.GetEvoluteMaterials(c,tp)
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_EVOLUTE_MATERIAL)}
				for _,te in ipairs(ce) do
					local tc=te:GetHandler()
					if tc then bg:AddCard(tc) end
				end
				if #bg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					bg:Select(tp,#bg,#bg,nil)
				end
				local sg=Group.CreateGroup()
				sg:Merge(bg)
				local finish=false
				while not (sg:GetCount()>=maxc) do
					finish=Auxiliary.EvoluteCheckGoal(tp,sg,c,minc,#sg,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.EvoluteRecursiveFilter,sg,tp,sg,mg,c,#sg,minc,maxc,table.unpack(funs))
					if #cg==0 then break end
					local cancel=not finish
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
					local tc=cg:SelectUnselect(sg,tp,finish,cancel,minc,maxc)
					if not tc then break end
					if not bg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
							if (sg:GetCount()>=maxc) then finish=true end
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
function Auxiliary.EvoluteOperation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	local tc=g:GetFirst()
	local lvTotal=0
	while tc do
		lvTotal = lvTotal + tc:GetValueForEvolute(c)
		if not tc:IsLocation(LOCATION_MZONE) then
			local tef={tc:IsHasEffect(EFFECT_EXTRA_EVOLUTE_MATERIAL)}
			for _,te in ipairs(tef) do
				local op=te:GetOperation()
				op(tc,tp)
			end
		else
			Duel.SendtoGrave(g,REASON_MATERIAL+0x10000000)
		end
		tc=g:GetNext()
	end
	--Set Maximum for Convergents
	local cone={c:IsHasEffect(EFFECT_CONVERGENT_EVOLUTE)}
	for _,te in ipairs(cone) do
		te:SetValue(lvTotal)
	end
	g:DeleteGroup()
end
function Auxiliary.ECSumFilter(c)
	return c:IsSummonType(SUMMON_TYPE_EVOLUTE) and c:IsType(TYPE_EVOLUTE)
end
function Auxiliary.EvoluteCounter(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=eg:Filter(Auxiliary.ECSumFilter,nil)
	local tc=g:GetFirst()
	while tc do
		if not tc:IsHasEffect(EFFECT_CONVERGENT_EVOLUTE) then tc:AddEC(tc:GetStage(),tp) end
		if tc:IsHasEffect(EFFECT_CONVERGENT_EVOLUTE) then 
			local cone={tc:IsHasEffect(EFFECT_CONVERGENT_EVOLUTE)}
			for _,te in ipairs(cone) do
				tc:AddEC(te:GetValue(),tp)
			end
			--[[local mg=tc:GetMaterial()
			local mc=mg:GetFirst()
			local val=0
			while mc do
				val = val+mc:GetValueForEvolute(tc)
				mc=mg:GetNext()
			end
			tc:AddEC(val)]]
		end
		tc=g:GetNext()
	end
end

--Conjoints
function Card.GetConjointNumber(c)
	if not Auxiliary.Conjoints[c] then return 0 end
	local te=c:IsHasEffect(EFFECT_CONJOINT_EVOLUTE_RATING)
	if c:IsLocation(LOCATION_OVERLAY) then return c:GetFlagEffectLabel(394) end
	if type(te:GetValue())=='function' then
		return te:GetValue()(te,c)
	else
		return te:GetValue()
	end
end
function Card.IsConjointedTo(c)
	return (c:GetFlagEffect(394)>0 or c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:GetOverlayTarget():IsType(TYPE_EVOLUTE)
end
function Auxiliary.AddOrigConjointType(c)
	table.insert(Auxiliary.Conjoints,c)
	Auxiliary.Customs[c]=true
	Auxiliary.Conjoints[c]=aux.TRUE
end
function Auxiliary.EnableConjointAttribute(c,ce)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CONJOINT_EVOLUTE_RATING)
	e1:SetValue(Auxiliary.CEVal(ce))
	c:RegisterEffect(e1)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetTarget(Auxiliary.DesRepDisjoint(ce))
	c:RegisterEffect(e5)
	if c:IsType(TYPE_MONSTER) then
		e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_SPSUMMON_PROC_G)
		e3:SetRange(LOCATION_MZONE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCondition(Auxiliary.ConjointTarget)
		e3:SetOperation(Auxiliary.ConjointOp(ce))
		c:RegisterEffect(e3)
	else
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_MOVE)
		e2:SetOperation(Auxiliary.AddCE(ce))
		c:RegisterEffect(e2)
		e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAIN_SOLVED)
		e3:SetRange(LOCATION_SZONE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetOperation(Auxiliary.STConjointOp(ce))
		c:RegisterEffect(e3)
	end
end
function Auxiliary.CEVal(ce)
	return	function(e,c)
				local ce=ce
				--insert modifications here
				return ce
			end
end
function Auxiliary.EvoluteFilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EVOLUTE) 
end
function Auxiliary.ConjointTarget(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	return c:GetFlagEffect(0)==0 and Duel.IsExistingMatchingCard(Auxiliary.EvoluteFilter,tp,LOCATION_MZONE,0,1,c)
end
function Auxiliary.ConjointOp(ce)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local g=Duel.SelectMatchingCard(tp,Auxiliary.EvoluteFilter,tp,LOCATION_MZONE,0,1,1,c)
				Duel.HintSelection(g+c)
				local tc=g:GetFirst()
				if c:GetOverlayCount()>0 then Duel.SendtoGrave(c:GetOverlayGroup(),REASON_RULE) end
				Duel.Overlay(tc,c)
				Auxiliary.AddCE(ce)(e,tp)
				if c:IsLocation(LOCATION_OVERLAY) and c:IsType(TYPE_EVOLUTE) then c:RegisterFlagEffect(394,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1,ce) end
				if tc:GetFlagEffect(2)==0 then
					tc:RegisterFlagEffect(2,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1)
					local e4=Effect.CreateEffect(c)
					e4:SetType(EFFECT_TYPE_FIELD)
					e4:SetCode(EFFECT_SPSUMMON_PROC_G)
					e4:SetRange(LOCATION_MZONE)
					e4:SetDescription(2)
					e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
					e4:SetCondition(Auxiliary.DisjointTarget)
					e4:SetOperation(Auxiliary.DisjointOp)
					e4:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e4)
				end
				c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			end
end
function Auxiliary.ConjointedFilter(c)
	return c:GetFlagEffect(0)==0 or c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function Auxiliary.DisjointTarget(e,c)
	if c==nil then return true end
	local g=c:GetOverlayGroup():Filter(Auxiliary.ConjointedFilter,nil)
	return #g>0 and (Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 or g:IsExists(Card.IsType,1,nil,TYPE_SPELL+TYPE_TRAP))
end
function Auxiliary.DisjointOp(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	Duel.Hint(HINT_SELECTMSG,tp,12)
	local tc=c:GetOverlayGroup():FilterSelect(tp,Auxiliary.ConjointedFilter,1,1,nil):GetFirst()
	Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
	c:RemoveEC(tp,math.min(tc:GetConjointNumber(),c:GetEC()),REASON_RULE)
	if tc:IsType(TYPE_EFFECT) then
		sg:AddCard(tc)
		if c:IsType(TYPE_CONJOINT) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(aux.FilterEqualFunction(Card.GetSummonLocation,LOCATION_OVERLAY),1,nil) end)
			e1:SetOperation(Auxiliary.SwapConjoint)
			c:RegisterEffect(e1)
		end
	else Duel.SendtoDeck(tc,nil,2,REASON_RULE) end
	tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
		e:Reset()
end
function Auxiliary.SwapConjoint(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.SelectEffectYesNo(tp,c) then return end
	local tc=eg:GetFirst()
	if c:GetOverlayCount()>0 then Duel.SendtoGrave(c:GetOverlayGroup(),REASON_RULE) end
	local cn=c:GetConjointNumber()
	Duel.Overlay(tc,c)
	if c:IsLocation(LOCATION_OVERLAY) then
		Auxiliary.AddCE(cn)(e,tp)
		c:RegisterFlagEffect(394,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1,cn)
		if tc:GetFlagEffect(2)==0 then
			tc:RegisterFlagEffect(2,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1)
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetCode(EFFECT_SPSUMMON_PROC_G)
			e4:SetRange(LOCATION_MZONE)
			e4:SetDescription(2)
			e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e4:SetCondition(Auxiliary.DisjointTarget)
			e4:SetOperation(Auxiliary.DisjointOp)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e4)
		end
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	e:Reset()
end
function Auxiliary.AddCE(ce)
	return	function(e,tp)
				local c=e:GetHandler()
				if not c:IsLocation(LOCATION_OVERLAY) then return end
				local tc=c:GetOverlayTarget()
				if ce<tc:GetStage()-tc:GetEC() then
					tc:AddEC(ce,tp)
				else tc:RefillEC() end
			end
end
function Auxiliary.STConjointOp(ce)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				local ef=c:GetActivateEffect()
				if re~=ef or not c:IsRelateToEffect(ef)
					or not Duel.IsExistingMatchingCard(Auxiliary.EvoluteFilter,tp,LOCATION_MZONE,0,1,nil)
					or not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local g=Duel.SelectMatchingCard(tp,Auxiliary.EvoluteFilter,tp,LOCATION_MZONE,0,1,1,c)
				Duel.HintSelection(g+c)
				c:CancelToGrave()
				local cn=c:GetConjointNumber()
				local tc=g:GetFirst()
				Duel.Overlay(tc,c)
				Auxiliary.AddCE(ce)(e,tp)
				c:RegisterFlagEffect(394,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1,cn)
				if tc:GetFlagEffect(2)==0 then
					tc:RegisterFlagEffect(2,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1)
					local e4=Effect.CreateEffect(c)
					e4:SetType(EFFECT_TYPE_FIELD)
					e4:SetCode(EFFECT_SPSUMMON_PROC_G)
					e4:SetRange(LOCATION_MZONE)
					e4:SetDescription(2)
					e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
					e4:SetCondition(Auxiliary.DisjointTarget)
					e4:SetOperation(Auxiliary.DisjointOp)
					e4:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e4)
				end
				c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			end
end
function Auxiliary.DesRepDisjoint(ce)
	return function	(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_RULE) end
				if Duel.SelectEffectYesNo(tp,c,96) then
				c:RemoveEC(tp,math.min(ce,c:GetEC()),REASON_RULE)
					c:RemoveOverlayCard(tp,1,1,REASON_RULE)
					return true
				else return false end
			end
end

--Bigbangs
function Card.IsCanBeBigbangMaterial(c,ec)
	if c:IsType(TYPE_LINK) then return false end
	local tef={c:IsHasEffect(EFFECT_CANNOT_BE_BIGBANG_MATERIAL)}
	for _,te in ipairs(tef) do
		if te:GetValue()(te,ec) then return false end
	end
	return true
end
function Card.GetVibe(c)
	---1 = Negative; +0 = Neutral; +1 = Positive
	local stat=c:GetAttack()-c:GetDefense()
	if stat==0 then return stat
	else return stat/math.abs(stat) end
end
function Card.GetBigbangAttack(c)
	return c:GetAttack()*c:GetVibe()
end
function Card.GetBigbangDefense(c)
	return c:GetDefense()*c:GetVibe()
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
	ge2:SetCondition(Auxiliary.BigbangCondition(table.unpack(list)))
	ge2:SetTarget(Auxiliary.BigbangTarget(table.unpack(list)))
	ge2:SetOperation(Auxiliary.BigbangOperation)
	ge2:SetValue(624)
	c:RegisterEffect(ge2)
end
function Auxiliary.BigbangCondition(...)
	local funs={...}
	return  function(e,c)
				if c==nil then return true end
				if (c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_PANDEMONIUM)) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=Duel.GetMatchingGroup(Card.IsCanBeBigbangMaterial,tp,LOCATION_MZONE,0,nil,c)
				return mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,nil,tp,Group.CreateGroup(),mg,c,0,table.unpack(funs))
			end
end
function Auxiliary.BigbangRecursiveFilter(c,tp,sg,mg,bc,ct,...)
	sg:AddCard(c)
	ct=ct+1
	local funs,max,chk={...},0
	for i=1,#funs do
		max=max+funs[i][3]
		if funs[i][1](c) then
			chk=true
		end
	end
	if max>99 then max=99 end
	local res=chk and (Auxiliary.BigbangCheckGoal(tp,sg,bc,ct,...)
		or (ct<max and mg:IsExists(Auxiliary.BigbangRecursiveFilter,1,sg,tp,sg,mg,bc,ct,...)))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.BigbangCheckGoal(tp,sg,bc,ct,...)
	local funs,min={...},0
	for i=1,#funs do
		if not sg:IsExists(funs[i][1],1,nil) then return false end
		min=min+funs[i][2]
	end
	return ct>=min and Duel.GetLocationCountFromEx(tp,tp,sg,bc)>0 and sg:GetSum(Card.GetBigbangAttack)>=bc:GetAttack() and sg:GetSum(Card.GetBigbangDefense)>=bc:GetDefense()
end
function Auxiliary.BigbangTarget(...)
	local funs,min,max={...},0,0
	for i=1,#funs do min=min+funs[i][2] max=max+funs[i][3] end
	if max>99 then max=99 end
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetMatchingGroup(Card.IsCanBeBigbangMaterial,tp,LOCATION_MZONE,0,nil,c)
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_BIGBANG_MATERIAL)}
				for _,te in ipairs(ce) do
					local tc=te:GetHandler()
					if tc then bg:AddCard(tc) end
				end
				if #bg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					bg:Select(tp,#bg,#bg,nil)
				end
				local sg=Group.CreateGroup()
				sg:Merge(bg)
				local finish=false
				while not (sg:GetCount()>=max) do
					finish=Auxiliary.BigbangCheckGoal(tp,sg,c,#sg,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.BigbangRecursiveFilter,sg,tp,sg,mg,c,#sg,table.unpack(funs))
					if #cg==0 then break end
					local cancel=not finish
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
					local tc=cg:SelectUnselect(sg,tp,finish,cancel,min,max)
					if not tc then break end
					if not bg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
							if (sg:GetCount()>=max) then finish=true end
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
function Auxiliary.BigbangOperation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.Destroy(g,REASON_MATERIAL+0x8000000000)
	g:DeleteGroup()
end

--Pandemoniums
function Auxiliary.AddOrigPandemoniumType(c,ispendulum,is_spell)
	table.insert(Auxiliary.Pandemoniums,c)
	Auxiliary.Customs[c]=true
	local ispendulum=ispendulum==nil and false or ispendulum
	local is_spell=is_spell==nil and false or is_spell
	Auxiliary.Pandemoniums[c]=function() return ispendulum, is_spell end
end
function Auxiliary.EnablePandemoniumAttribute(c,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local t={...}
	local regfield,typ=nil,nil
	if type(t[#t])=='number' then
		typ=t[#t]
		table.remove(t)
	end
	if type(t[#t])=='boolean' then
		regfield=t[#t]
		table.remove(t)
	end
	--summon
	local ge6=Effect.CreateEffect(c)
	ge6:SetType(EFFECT_TYPE_FIELD)
	ge6:SetDescription(1074)
	ge6:SetCode(EFFECT_SPSUMMON_PROC_G)
	ge6:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	ge6:SetRange(LOCATION_SZONE)
	ge6:SetCountLimit(1,10000000)
	ge6:SetCondition(Auxiliary.PandCondition)
	ge6:SetCost(Auxiliary.PandCost)
	ge6:SetOperation(Auxiliary.PandOperation)
	ge6:SetValue(726)
	c:RegisterEffect(ge6)
	--add Pendulum-like redirect property
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetOperation(Auxiliary.PandEnConFUInED(typ))
	c:RegisterEffect(e0)
	--reset Pendulum-like redirect property
	local sp=Effect.CreateEffect(c)
	sp:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	sp:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	sp:SetCode(EVENT_SPSUMMON_SUCCESS)
	sp:SetCondition(Auxiliary.PandDisConFUInED)
	sp:SetOperation(Auxiliary.PandDisableFUInED(c,typ))
	c:RegisterEffect(sp)
	local th=Effect.CreateEffect(c)
	th:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	th:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	th:SetCode(EVENT_TO_HAND)
	th:SetCondition(Auxiliary.PandDisConFUInED)
	th:SetOperation(Auxiliary.PandDisableFUInED(c,typ))
	c:RegisterEffect(th)
	local td=th:Clone()
	td:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(td)
	local rem=th:Clone()
	rem:SetCode(EVENT_REMOVE)
	c:RegisterEffect(rem)
	--keep on field
	local kp=Effect.CreateEffect(c)
	kp:SetType(EFFECT_TYPE_SINGLE)
	kp:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(kp)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(Auxiliary.PandActCon)
	if #t>0 then
		local flags=0
		for _,xe in ipairs(t) do
			if type(xe)=='userdata' and xe:GetProperty() then flags=flags|xe:GetProperty() end
		end
		e1:SetProperty(flags)
		e1:SetHintTiming(TIMING_DAMAGE_CAL+TIMING_DAMAGE_STEP)
	end
	e1:SetTarget(Auxiliary.PandActTarget(table.unpack(t)))
	e1:SetOperation(Auxiliary.PandActOperation(table.unpack(t)))
	c:RegisterEffect(e1)
	--register by default
	if regfield==nil or regfield then
		--set
		local set=Effect.CreateEffect(c)
		set:SetDescription(1159)
		set:SetType(EFFECT_TYPE_FIELD)
		set:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		set:SetCode(EFFECT_SPSUMMON_PROC_G)
		set:SetRange(LOCATION_HAND)
		set:SetCondition(Auxiliary.PandSSetCon)
		set:SetOperation(Auxiliary.PandSSet(c,REASON_RULE,typ))
		c:RegisterEffect(set)
	end
	Duel.AddCustomActivityCounter(c:GetOriginalCode(),ACTIVITY_SPSUMMON,Auxiliary.PaCheck)
end
function Auxiliary.PaCheck(c)
	return not c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function Auxiliary.PandCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(e:GetHandler():GetOriginalCode(),tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(Auxiliary.PandePendSwitch)
	Duel.RegisterEffect(e1,tp)
end
function Auxiliary.PandePendSwitch(e,c,tp,sumtp,sumpos)
	return sumtp&SUMMON_TYPE_PENDULUM==SUMMON_TYPE_PENDULUM
end
function Auxiliary.PaConditionFilter(c,e,tp,lscale,rscale)
	local lv=0
	if c.pandemonium_level then
		lv=c.pandemonium_level
	else
		lv=c:GetLevel()
	end
	return (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM)))
		and (lv>lscale and lv<rscale) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL+726,tp,false,false)
		and not c:IsForbidden()
end
function Auxiliary.PandCondition(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	local lscale=c:GetLeftScale()
	local rscale=c:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
	if loc==0 then return false end
	local g=nil
	if og then
		g=og:Filter(Card.IsLocation,nil,loc)
	else
		g=Duel.GetFieldGroup(tp,loc,0)
	end
	return aux.PandActCheck(e) and g:IsExists(Auxiliary.PaConditionFilter,1,nil,e,tp,lscale,rscale) and c:GetFlagEffect(53313903)<=0
end
function Auxiliary.PandOperation(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	local lscale=c:GetLeftScale()
	local rscale=c:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp)
	local ft=Duel.GetUsableMZoneCount(tp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		ft=1
	end
	local loc=0
	if ft1>0 then loc=loc+LOCATION_HAND end
	if ft2>0 then loc=loc+LOCATION_EXTRA end
	local tg=nil
	if og then
		tg=og:Filter(Card.IsLocation,nil,loc):Filter(Auxiliary.PaConditionFilter,nil,e,tp,lscale,rscale)
	else
		tg=Duel.GetMatchingGroup(Auxiliary.PaConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale)
	end 
	ft1=math.min(ft1,tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND))
	ft2=math.min(ft2,tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect and ect<ft2 then ft2=ect end
	while true do
		local ct1=tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		local ct2=tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
		local ct=ft
		if ct1>ft1 then ct=math.min(ct,ft1) end
		if ct2>ft2 then ct=math.min(ct,ft2) end
		if ct<=0 then break end
		if sg:GetCount()>0 and not Duel.SelectYesNo(tp,210) then ft=0 break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=tg:Select(tp,1,ct,nil)
		tg:Sub(g)
		sg:Merge(g)
		if g:GetCount()<ct then ft=0 break end
		ft=ft-g:GetCount()
		ft1=ft1-g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		ft2=ft2-g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
	end
	if ft>0 then
		local tg1=tg:Filter(Card.IsLocation,nil,LOCATION_HAND)
		local tg2=tg:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
		if ft1>0 and ft2==0 and tg1:GetCount()>0 and (sg:GetCount()==0 or Duel.SelectYesNo(tp,210)) then
			local ct=math.min(ft1,ft)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=tg1:Select(tp,1,ct,nil)
			sg:Merge(g)
		end
		if ft1==0 and ft2>0 and tg2:GetCount()>0 and (sg:GetCount()==0 or Duel.SelectYesNo(tp,210)) then
			local ct=math.min(ft2,ft)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=tg2:Select(tp,1,ct,nil)
			sg:Merge(g)
		end
	end
	if sg:GetCount()>0 then
		Duel.HintSelection(Group.FromCards(c))
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_SPECIAL+726) end)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.SendtoGrave(e:GetHandler(),REASON_RULE) end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function Auxiliary.PaCheckFilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM) and c:GetFlagEffect(726)>0
end
function Auxiliary.PandActCon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Auxiliary.PaCheckFilter,tp,LOCATION_SZONE,0,1,e:GetHandler())
end
function Auxiliary.PandEnConFUInED(tpe)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				if (e:GetHandler():GetFlagEffect(706)>0 or e:GetHandler():GetFlagEffect(726)>0) and e:GetHandler():GetDestination()~=LOCATION_GRAVE then
					Auxiliary.PandDisableFUInED(e:GetHandler(),tpe)(e,tp,eg,ep,ev,re,r,rp)
				elseif e:GetHandler():GetDestination()==LOCATION_GRAVE then
					Auxiliary.PandEnableFUInED(e:GetHandler(),e:GetHandler():GetReason(),tpe)(e,tp,eg,ep,ev,re,r,rp)
				else
					return
				end
	end
end
function Auxiliary.PandEnableFUInED(tc,reason,tpe)
	if not tpe then tpe=TYPE_EFFECT end
	return  function(e,tp,eg,ep,ev,re,r,rp)
				if pcall(Group.GetFirst,tc) then
					local tg=tc:Clone()
					for cc in aux.Next(tg) do
						Card.SetCardData(cc,CARDDATA_TYPE,TYPE_MONSTER+tpe+TYPE_PENDULUM)
						if not cc:IsOnField() or cc:GetDestination()==0 then
							Duel.SendtoExtraP(cc,nil,reason)
						end
					end
				else
					Card.SetCardData(tc,CARDDATA_TYPE,TYPE_MONSTER+tpe+TYPE_PENDULUM)
					if not tc:IsOnField() or tc:GetDestination()==0 then
						Duel.SendtoExtraP(tc,nil,reason)
					end
				end
			end
end
function Auxiliary.PandDisConFUInED(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
function Auxiliary.PandDisableFUInED(tc,tpe)
	if not tpe then tpe=TYPE_EFFECT end
	return  function(e,tp,eg,ep,ev,re,r,rp)
				tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER+tpe)
			end
end
function Auxiliary.PandSSetCon(c,e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function Auxiliary.PandSSet(tc,reason,tpe)
	if not tpe then tpe=TYPE_EFFECT end
	return  function(e,tp,eg,ep,ev,re,r,rp,c)
				if pcall(Group.GetFirst,tc) then
					local tg=tc:Clone()
					for cc in aux.Next(tg) do
						cc:SetCardData(CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
						if cc:IsLocation(LOCATION_SZONE) then
							if cc:IsCanTurnSet() then
								Duel.ChangePosition(cc,POS_FACEDOWN_ATTACK)
								Duel.RaiseEvent(cc,EVENT_SSET,e,reason,cc:GetControler(),cc:GetControler(),0)
								cc:RegisterFlagEffect(706,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1)
							end
						else Duel.SSet(cc:GetControler(),cc) cc:RegisterFlagEffect(706,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1) end
						if not cc:IsLocation(LOCATION_SZONE) then
							cc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER+tpe)
						end
					end
				else
					tc:SetCardData(CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
					if tc:IsLocation(LOCATION_SZONE) then
						if tc:IsCanTurnSet() then
							Duel.ChangePosition(tc,POS_FACEDOWN_ATTACK)
							Duel.RaiseEvent(tc,EVENT_SSET,e,reason,tc:GetControler(),tc:GetControler(),0)
							tc:RegisterFlagEffect(706,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1)
						end
					else Duel.SSet(tc:GetControler(),tc) tc:RegisterFlagEffect(706,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1) end
					if not tc:IsLocation(LOCATION_SZONE) then
						tc:SetCardData(CARDDATA_TYPE,TYPE_MONSTER+tpe)
					end
				end
			end
end
function Auxiliary.PandActCheck(e)
	local c=e:GetHandler()
	return e:IsHasType(EFFECT_TYPE_ACTIVATE) or c:GetFlagEffect(726)>0
end
function Auxiliary.PandActTarget(...)
	local fx={...}
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return true end
				local c=e:GetHandler()
				c:RegisterFlagEffect(726,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE,1)
				if #fx==0 then
					e:SetCategory(0)
					e:SetProperty(0)
					e:SetLabel(0)
					return
				end
				local ops={}
				local t={}
				local cost=nil
				local tg=nil
				for i,xe in ipairs(fx) do
					local condition=xe:GetCondition()
					local code=xe:GetCode()
					local check_own_label=xe:GetLabelObject()
					if check_own_label then
						e:SetLabelObject(check_own_label)
					end
					cost=xe:GetCost()
					tg=xe:GetTarget()
					local tchk=(code==EVENT_FREE_CHAIN or Duel.CheckEvent(code))
					if code==EVENT_CHAINING then
						tchk=(tchk or Duel.GetCurrentChain()>1)
						ev=Duel.GetCurrentChain()-1
						re=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
						eg=re:GetHandler()
					end
					if tchk and xe:CheckCountLimit(tp) and (not condition or condition(e,tp,eg,ep,ev,re,r,rp))
						and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0))
						and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)) then
						table.insert(ops,xe:GetDescription())
					else table.insert(ops,1214) end
					table.insert(t,xe)
				end
				local op=0
				if #ops>1 then
					op=Duel.SelectOption(tp,1214,table.unpack(ops))
					if ops[op]==1214 then op=0 end
				elseif ops[1]~=1214 and Duel.SelectYesNo(tp,94) then op=1 end
				if op>0 then
					local xe=t[op]
					xe:UseCountLimit(tp)
					local confirm_own_label=xe:GetLabelObject()
					if confirm_own_label then
						e:SetLabelObject(confirm_own_label)
					end
					e:SetCategory(xe:GetCategory())
					cost=xe:GetCost()
					if cost then cost(e,tp,eg,ep,ev,re,r,rp,1) end
					tg=xe:GetTarget()
					if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
					c:RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,65)
				else
					e:SetCategory(0)
					e:SetLabel(0)
				end
				e:SetLabel(op)
			end
end
function Auxiliary.PandActOperation(...)
	local fx={...}
	return  function(e,tp,eg,ep,ev,re,r,rp)
				if e:GetLabel()==0 then return end
				local xe=fx[e:GetLabel()]
				if xe:GetCode()==EVENT_CHAINING then
					ev=Duel.GetCurrentChain()-1
					re=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
					eg=re:GetHandler()
				end
				local confirm_own_label=xe:GetLabelObject()
				if confirm_own_label then
					e:SetLabelObject(confirm_own_label)
				end
				local op=xe:GetOperation()
				if op then op(e,tp,eg,ep,ev,re,r,rp) end
			end
end
function Auxiliary.PandAct(tc)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				tc:SetCardData(CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
				if not tc:IsOnField() then
					Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				end
				tc:RegisterFlagEffect(726,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE,1)
			end
end

--Polarities
function Card.GetStability(c)
	if not c:IsHasEffect(EFFECT_STABLE) then return 0 end
	local te=c:IsHasEffect(EFFECT_STABLE)
	if type(te:GetValue())=='function' then
		return te:GetValue()(te,c)
	else
		return te:GetValue()
	end
end
function Card.IsStability(c,stability)
	return c:GetStability()==stability
end
function Card.IsCanBePolarityMaterial(c,ec)
	if c:GetLevel()<=0 and not c:IsStatus(STATUS_NO_LEVEL) then return false end
	local tef={c:IsHasEffect(EFFECT_CANNOT_BE_POLARITY_MATERIAL)}
	for _,te in ipairs(tef) do
		if te:GetValue()(te,ec) then return false end
	end
	return true
end
function Auxiliary.AddOrigPolarityType(c,issynchro)
	table.insert(Auxiliary.Polarities,c)
	Auxiliary.Customs[c]=true
	local issynchro=issynchro==nil and false or issynchro
	Auxiliary.Polarities[c]=function() return issynchro end
end
function Auxiliary.AddPolarityProc(c,stability,f1,f2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_STABLE)
	e1:SetValue(Auxiliary.StabilityVal(stability))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(Auxiliary.PolarityCondition(f1,f2))
	e2:SetTarget(Auxiliary.PolarityTarget(f1,f2))
	e2:SetOperation(Auxiliary.PolarityOperation)
	e2:SetValue(765)
	c:RegisterEffect(e2)
end
function Auxiliary.StabilityVal(stability)
	return  function(e,c)
				local stability=stability
				--insert modifications here
				return stability
			end
end
function Auxiliary.PolarityMatFilter(c,ec,tp,...)
	if not c:IsCanBePolarityMaterial(ec) then return false end
	for _,f in ipairs({...}) do
		if f(c,ec,tp) then return true end
	end
	return false
end
function Auxiliary.PolarCheckRecursive1(g2,pc,stability)
	return  function(sg,e,tp,mg)
				local sg2=g2:Filter(aux.TRUE,sg)
				return Auxiliary.SelectUnselectGroup(sg2,e,tp,nil,nil,Auxiliary.PolarCheckRecursive2(sg,pc,stability),0)
			end
end
function Auxiliary.PolarCheckRecursive2(g1,pc,stability)
	return  function(g2,e,tp,mg)
				local sg=g1:Clone()
				sg:Merge(g2)
				return Duel.GetLocationCountFromEx(tp,tp,sg,pc)>0 and math.abs(g1:GetSum(Card.GetLevel)-g2:GetSum(Card.GetLevel))==stability
			end
end
function Auxiliary.PolarityCondition(f1,f2)
	return  function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local stability=c:GetStability()
				local mg=Duel.GetMatchingGroup(Auxiliary.PolarityMatFilter,tp,LOCATION_MZONE,0,nil,c,tp,f1,f2)
				local g1=mg:Filter(f1,nil,c,tp)
				local g2=mg:Filter(f2,nil,c,tp)
				return Auxiliary.SelectUnselectGroup(g1,e,tp,nil,nil,Auxiliary.PolarCheckRecursive1(g2,c,stability),0)
			end
end
function Auxiliary.PolarityTarget(f1,f2)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetMatchingGroup(Auxiliary.PolarityMatFilter,tp,LOCATION_MZONE,0,nil,c,tp,f1,f2)
				local g1=mg:Filter(f1,nil,c,tp)
				local g2=mg:Filter(f2,nil,c,tp)
				local sg1=Auxiliary.SelectUnselectGroup(g1,e,tp,nil,nil,Auxiliary.PolarCheckRecursive1(g2,c,stability),1,tp,0,aux.TRUE)
				local mg2=mg:Sub(sg1)
				if not Auxiliary.PolarCheckRecursive1(g2,c,stability)(sg1,e,tp,mg2) then return false end
				local sg=sg1:Clone()
				local sg2=Group.CreateGroup()
				while true do
					local tg=g2:Sub(sg2)
					local mg=g:Filter(Auxiliary.SelectUnselectLoop,sg,sg,tg,e,tp,1,99,Auxiliary.PolarCheckRecursive2(sg1,c,stability))
					if mg:GetCount()<=0 then break end
					Duel.Hint(HINT_SELECTMSG,tp,0)
					local tc=mg:SelectUnselect(sg,tp,true,true)
					if not tc then break end
					if sg2:IsContains(tc) then
						sg2:RemoveCard(tc)
						sg:RemoveCard(tc)
					elseif not sg:IsContains(tc) then
						sg2:AddCard(tc)
						sg:AddCard(tc)
					end
				end
				local tg=g2:Sub(sg2)
				if Auxiliary.PolarCheckRecursive2(sg1,c,stability)(sg2,e,tp,tg) then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else
					return false
				end
			end
end
function Auxiliary.PolarityOperation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+0x40000000)
	g:DeleteGroup()
end
--Spatials
function Card.SwitchSpace(c)
	if not Auxiliary.Spatials[c] or not c:IsSummonType(SUMMON_TYPE_SPATIAL) or c:GetFlagEffect(500)==0 then return false end
	Auxiliary.Spatials[c]=nil
	local mt=_G["c" .. c:GetOriginalCode()]
	local ospc=mt.spt_other_space
	if not ospc then ospc=Duel.ReadCard(c:GetOriginalCode(),CARDDATA_ALIAS) end
	if ospc==0 then return false end
	c:SetEntityCode(ospc,true)
	c:ReplaceEffect(ospc,0,0)
	Duel.SetMetatable(c,_G["c"..ospc])
	local ct=c:GetFlagEffectLabel(500)
	if ct>1 then
		c:SetFlagEffectLabel(500,ct-1)
	else c:ResetFlagEffect(500) end
	return true
end
function Card.GetDimensionNo(c)
	if not Auxiliary.Spatials[c] then return 0 end
	local te=c:IsHasEffect(EFFECT_DIMENSION_NUMBER)
	if type(te:GetValue())=='function' then
		return te:GetValue()(te,c)
	else
		return te:GetValue()
	end
end
function Card.IsDimensionNo(c,djn)
	return c:GetDimensionNo()==djn
end
function Card.IsCanBeSpaceMaterial(c,sptc)
	local tef={c:IsHasEffect(EFFECT_CANNOT_BE_SPACE_MATERIAL)}
	for _,te in ipairs(tef) do
		if te:GetValue()(te,sptc) then return false end
	end
	return true
end
function Auxiliary.AddOrigSpatialType(c,isxyz)
	table.insert(Auxiliary.Spatials,c)
	Auxiliary.Customs[c]=true
	local isxyz=isxyz==nil and false or isxyz
	Auxiliary.Spatials[c]=function() return isxyz end
end
function Auxiliary.AddSpatialProc(c,sptcheck,djn,adiff,ddiff,...)
	--sptcheck - extra check after everything is settled, djn - Spatial "level", adiff - max material ATK difference, ddiff - max material DEF difference
	--... format - any number of materials  use aux.TRUE for generic materials
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_SINGLE)
	ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ge1:SetCode(EFFECT_DIMENSION_NUMBER)
	ge1:SetValue(Auxiliary.DimensionNoVal(djn))
	c:RegisterEffect(ge1)
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC)
	ge2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ge2:SetRange(LOCATION_EXTRA)
	ge2:SetCondition(Auxiliary.SpatialCondition(sptcheck,adiff,ddiff,...))
	ge2:SetTarget(Auxiliary.SpatialTarget(sptcheck,adiff,ddiff,...))
	ge2:SetOperation(Auxiliary.SpatialOperation)
	ge2:SetValue(500)
	c:RegisterEffect(ge2)
	local ge3=Effect.CreateEffect(c)
	ge3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	ge3:SetCode(EVENT_SPSUMMON_SUCCESS)
	ge3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsSummonType(SUMMON_TYPE_SPATIAL) then
			c:RegisterFlagEffect(500,RESET_EVENT+RESETS_STANDARD,0,1,djn)
		end
	end)
	c:RegisterEffect(ge3)
	local ge4=Effect.CreateEffect(c)
	ge4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	ge4:SetCode(EFFECT_SEND_REPLACE)
	ge4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ge4:SetRange(0xdf)
	ge4:SetTarget(Auxiliary.SpatialToGraveReplace)
	c:RegisterEffect(ge4)
	local ge5=Effect.CreateEffect(c)
	ge5:SetType(EFFECT_TYPE_SINGLE)
	ge5:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	ge5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ge5:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(ge5)
end
function Auxiliary.SpatialToGraveReplace(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetDestination()==LOCATION_GRAVE end
	Duel.Remove(c,POS_FACEUP,r)
	return true
end
function Auxiliary.DimensionNoVal(djn)
	return  function(e,c)
				local djn=djn
				--insert modifications here
				return djn
			end
end
function Auxiliary.SpaceMatFilter(c,sptc,tp,...)
	if c:IsFacedown() or not c:IsCanBeSpaceMaterial(sptc) then return false end
	for _,f in ipairs({...}) do
		if f(c,sptc,tp) then return true end
	end
	return false
end
function Auxiliary.SptCheckRecursive(c,tp,mg,sg,sptc,djn,sptcheck,adiff,ddiff,f,...)
	if not f(c,sptc,tp,sg) then return false end
	sg:AddCard(c)
	local res
	if ... then
		res=mg:IsExists(Auxiliary.SptCheckRecursive,1,sg,tp,mg,sg,sptc,djn,sptcheck,adiff,ddiff,...)
	else
		res=Auxiliary.SptCheckGoal(tp,sg,sptc,adiff,ddiff,sptcheck)
	end
	sg:RemoveCard(c)
	return res
end
function Auxiliary.SptCheckGoal(tp,sg,sptc,adiff,ddiff,sptcheck)
	return sg:IsExists(Auxiliary.SptMatCheckRecursive,1,nil,sg,Group.CreateGroup(),adiff,ddiff) and (not sptcheck or sptcheck(sg,sptc,tp)) and Duel.GetLocationCountFromEx(tp,tp,sg,sptc)>0
end
function Auxiliary.SptMatCheckRecursive(c,mg,sg,adiff,ddiff,fc)
	sg:AddCard(c)
	local res,diff
	if fc and mg:FilterCount(aux.TRUE,sg)==0 then
		if adiff then
			diff=math.abs(c:GetAttack()-fc:GetAttack())
			res=diff>0 and (not adiff or diff<=adiff)
		end
		if ddiff then
			diff=math.abs(c:GetDefense()-fc:GetDefense())
			res=(res) or (diff>0 and (not ddiff or diff<=ddiff))
		end
	else res=mg:IsExists(Auxiliary.SptMatCheckRecursive,1,sg,mg,sg,adiff,ddiff,c) end
	sg:RemoveCard(c)
	return res
end
function Auxiliary.SpatialCondition(sptcheck,adiff,ddiff,...)
	local funs={...}
	return  function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local djn=c:GetDimensionNo()
				local mg=Duel.GetMatchingGroup(Auxiliary.SpaceMatFilter,tp,LOCATION_MZONE,0,nil,c,tp,table.unpack(funs))
				local sg=Group.CreateGroup()
				return mg:IsExists(Auxiliary.SptCheckRecursive,1,nil,tp,mg,sg,c,djn,sptcheck,adiff,ddiff,table.unpack(funs))
			end
end
function Auxiliary.SpatialTarget(sptcheck,adiff,ddiff,...)
	local funs={...}
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetMatchingGroup(Auxiliary.SpaceMatFilter,tp,LOCATION_MZONE,0,nil,c,tp,table.unpack(funs))
				local ct=#funs
				local djn=c:GetDimensionNo()
				local sg
				local sg2
				local tempfun
				::restart::
				sg=Group.CreateGroup()
				sg2=Group.CreateGroup()
				tempfun={table.unpack(funs)}
				while sg:GetCount()<ct do
					local cg
					if #tempfun>0 then
						cg=mg:Filter(Auxiliary.SptCheckRecursive,sg,tp,mg,sg,c,djn,sptcheck,adiff,ddiff,table.unpack(tempfun))
					else
						cg=Group.CreateGroup()
					end
					if cg:GetCount()==0 then break end
					local tc=cg:SelectUnselect(sg,tp,true,true)
					if not tc then break end
					table.remove(tempfun,1)
					if not sg:IsContains(tc) then
						sg:AddCard(tc)
						if #tempfun<=0 then
							sg2:AddCard(tc)
						end
					end
				end
				if sg:GetCount()>=ct then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else
					if sg:GetCount()>0 then goto restart end
					return false
				end
			end
end
function Auxiliary.SpatialOperation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+0x80000000)
	g:DeleteGroup()
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
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
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
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
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
	if tc and c:IsRelateToEffect(re) and tc:IsRelateToEffect(re) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end

--Corona Card init
function Auxiliary.EnableCoronaNeo(c,aura,mat_count,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	table.insert(Auxiliary.Coronas,c)
	Auxiliary.Coronas[c]=function() return true end
	Auxiliary.Customs[c]=true
	--Functions
	local funcs={...}
	--Add Aura
	local mt=getmetatable(c)
	mt.aura = aura
	mt.original_type = (c:GetType()-TYPE_FUSION)
	mt.corona_materials = funcs
	mt.material_count = mat_count
	
	--Draw replace
	--[[local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EVENT_CHAIN_SOLVING)
	e0:SetOperation(Auxiliary.CoronaDrawOp)
	c:RegisterEffect(e0)]]
	--Destruction replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetTarget(Auxiliary.CoronaDesRepTg)
	e3:SetValue(Auxiliary.CoronaDesRepVal)
	c:RegisterEffect(e3)
	
	if not Global_CoronaRedirects then
		Global_CoronaRedirects=true
		--Redirect
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_TO_DECK_REDIRECT)
		ge1:SetTargetRange(0xff,0xff)
		ge1:SetTarget(Auxiliary.CoronaToExtra)
		ge1:SetValue(LOCATION_EXTRA)
		Duel.RegisterEffect(ge1,0)
	end
end
g_CoronaTracker={0,0}
g_CoronaTracker[0]=0
g_CoronaTracker[1]=0
g_CoronaCount={0,0}
g_CoronaCount[0]=0
g_CoronaCount[1]=0
function Auxiliary.CoronaOp(tp,val,r)
	local tc=Duel.SelectMatchingCard(tp,Auxiliary.CoronaFilterNeo,tp,LOCATION_EXTRA,0,1,1,nil,val):GetFirst()
	local aura=tc:GetAura()
	
	local cg=Group.CreateGroup()
	for key,value in pairs(tc.corona_materials) do
		if not cg:IsExists(tc.corona_materials[key],1,nil) then
			local sg=Duel.GetMatchingGroup(tc.corona_materials[key],tp,LOCATION_GRAVE,0,nil)
			sg:Sub(cg)
			local cc=sg:Select(tp,1,1,nil):GetFirst()
			cg:AddCard(cc)
		end
	end
	local ct=tc.material_count - cg:GetCount()
	if ct>0 then
		local sg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_GRAVE,0,ct,ct,nil)
		cg:Merge(sg)
	end
	Duel.Remove(cg,POS_FACEUP,REASON_COST+REASON_MATERIAL+1600000000)
	
	aux.AddCoronaToHand(tc,r,tc.original_type)
	--Duel.Recover(tp,aura*500,REASON_RULE)
	if (r==REASON_RULE) then Duel.RegisterFlagEffect(tp,1600000000,RESET_PHASE+PHASE_END,1,0) end
	return tc
end
function Auxiliary.CoronaDrawOp(e,tp,eg,ep,ev,re,r,rp)
	local p,d,id=Duel.GetChainInfo(ev,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM,CHAININFO_CHAIN_ID)
	local ex = (Duel.GetOperationInfo(ev,CATEGORY_DRAW) or re:IsHasCategory(CATEGORY_DRAW))
	local user = (ep==tp) and (p==tp) and (rp==tp)
	if not (user and ex and (g_CoronaTracker[tp]~=id) and (Duel.GetFlagEffect(tp,1600000000)==0)
		and Duel.IsExistingMatchingCard(Auxiliary.CoronaFilterNeo,tp,LOCATION_EXTRA,0,1,nil,d)) then return end
	g_CoronaTracker[tp]=id
	if d>0 and Duel.SelectYesNo(tp,572) then
		--[[local invest=0
		if d==1 then invest = 1 else
			invest = Duel.AnnounceLevel(tp,1,d,nil)
		end]]
		local tc = Auxiliary.CoronaOp(tp,d,REASON_RULE)
		Duel.ChangeTargetParam(ev,d-tc:GetAura())
	end
end
function Auxiliary.CoronaDesRepFilter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function Auxiliary.CoronaDesRepTg(e,tp,eg,ep,ev,re,r,rp,chk)
	if rp~=tp then return false end
	local id=0
	if re then id=re:GetHandler():GetCode() end
	local ct=eg:FilterCount(Auxiliary.CoronaDesRepFilter,nil,tp)
	if chk==0 then return (rp==tp and ct>0 and (g_CoronaTracker[tp]~=id) and (Duel.GetFlagEffect(tp,1600000000)==0)
		and Duel.IsExistingMatchingCard(Auxiliary.CoronaFilterNeo,tp,LOCATION_EXTRA,0,1,nil,ct)) end
	g_CoronaTracker[tp]=id
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),573) then
		Auxiliary.CoronaOp(tp,ct,REASON_RULE)
		return true
	else return false end
end

function Auxiliary.CoronaDesRepVal(e,c)
	return Auxiliary.CoronaDesRepFilter(c,e:GetHandlerPlayer())
end

function Auxiliary.CoronaFilterNeo(c,ct)
	if not (c:IsType(TYPE_CORONA) and c:GetAura()<=ct and (Duel.GetFieldGroupCount(c:GetControler(),LOCATION_GRAVE,0)>=c.material_count)) then return false end
	for key,value in pairs(c.corona_materials) do
		if not Duel.IsExistingMatchingCard(c.corona_materials[key],c:GetControler(),LOCATION_GRAVE,0,1,nil,nil) then return false end
	end
	return true
end
--Shorthand for "If you performed a Corona Draw this turn"
function Auxiliary.cdrewcon(e,tp)
	return Duel.GetFlagEffect(tp,1600000000)~=0
end
--Aura Functions
function Card.GetAura(c)
	if not c.aura then return 0 end
	return c.aura
end
function Card.IsAuraBelow(c,val)
	if not c.aura then return false end
	return c.aura <= val
end
function Card.IsAuraAbove(c,val)
	if not c.aura then return false end
	return c.aura >= val
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
function Auxiliary.PerformFusionSummon(f,e,tp,mg1,gc)
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
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
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
--Custom Link Procedures Auxiliaries
Auxiliary.LCheckGoal=function(sg,tp,lc,gf)
	if lc:IsHasEffect(EFFECT_AVAILABLE_LMULTIPLE) then
		return sg:CheckWithSumEqual(Auxiliary.GetMultipleLinkCount,lc:GetLink(),#sg,#sg,lc)
			and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg))
			and not sg:IsExists(Auxiliary.LUncompatibilityFilter,1,nil,sg,lc)
	else
		return sg:CheckWithSumEqual(Auxiliary.GetLinkCount,lc:GetLink(),#sg,#sg)
			and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg))
			and not sg:IsExists(Auxiliary.LUncompatibilityFilter,1,nil,sg,lc)
	end
end
function Auxiliary.GetMultipleLinkCount(c,lc)
	local egroup={lc:IsHasEffect(EFFECT_AVAILABLE_LMULTIPLE)}
	for k,w in ipairs(egroup) do
		local lab=w:GetLabel()
		if c:IsHasEffect(EFFECT_MULTIPLE_LMATERIAL) then
		local av_val={}
		local lmat={c:IsHasEffect(EFFECT_MULTIPLE_LMATERIAL)}
		for _,ec in ipairs(lmat) do
				if ec:GetLabel()==lab then
			table.insert(av_val,ec:GetValue())
		end
		for maxval=1,10 do
			local val=av_val[maxval]
			av_val[maxval]=nil
			if c:IsType(TYPE_LINK) and c:GetLink()>1 then
				return 1+0x10000*val and 1+0x10000*c:GetLink()
			else
				return 1+0x10000*val
			end
		end
			end
	elseif c:IsType(TYPE_LINK) and c:GetLink()>1 then
		return 1+0x10000*c:GetLink()
		else 
			return 1 
		end
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
--Skills Utilities
function Auxiliary.AddOrigSkillType(c,ispendulum,is_spell)
	table.insert(Auxiliary.Skills,c)
	Auxiliary.Customs[c]=true
	local ispendulum=ispendulum==nil and false or ispendulum
	local is_spell=is_spell==nil and false or is_spell
	Auxiliary.Skills[c]=function() return ispendulum, is_spell end
end
function Auxiliary.EDSkillProperties(c)
	--ED Skill Properties
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(Auxiliary.skillcon)
	e1:SetValue(Auxiliary.skill_efilter)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(0)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_USE_AS_COST)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
function Auxiliary.skillcon(e)
	return e:GetHandler():IsFaceup() and e:GetHandler():GetFlagEffect(99988871)>0
end
function Auxiliary.skill_efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
--Deck Masters Auxiliaries
function Auxiliary.AddOrigDeckmasterType(c,isfusion)
	table.insert(Auxiliary.Deckmasters,c)
	Auxiliary.Customs[c]=true
	local isfusion=isfusion==nil and false or isfusion
	Auxiliary.Deckmasters[c]=function() return isfusion end
end
function Auxiliary.EnableDeckmaster(c,actcon,actcon_alt,mscon,mscustom,penaltycon,penalty)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local typ=c:GetOriginalType()
	--if c:GetOriginalType()&TYPE_PENDULUM==TYPE_PENDULUM or c:GetOriginalType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM then return end
	--Activation from ED
	local act=Effect.CreateEffect(c)
	act:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	act:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	act:SetCode(EVENT_PREDRAW)
	act:SetRange(LOCATION_EXTRA)
	act:SetCondition(Auxiliary.DMActCon(actcon))
	act:SetOperation(Auxiliary.DMFirstAct(typ))
	c:RegisterEffect(act)
	--Protection in Activated State
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_SINGLE)
	e1x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1x:SetCode(EFFECT_IMMUNE_EFFECT)
	e1x:SetRange(LOCATION_SZONE)
	e1x:SetCondition(Auxiliary.CheckDMActivatedState)
	e1x:SetValue(function(e,te)
					return te:GetOwner()~=e:GetOwner()
					end
				)
	c:RegisterEffect(e1x)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_SINGLE)
	e2x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	e2x:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2x:SetRange(LOCATION_SZONE)
	e2x:SetCondition(Auxiliary.CheckDMActivatedState)
	e2x:SetValue(1)
	c:RegisterEffect(e2x)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_SINGLE)
	e3x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	e3x:SetCode(EFFECT_CANNOT_USE_AS_COST)
	e3x:SetRange(LOCATION_SZONE)
	e3x:SetCondition(Auxiliary.CheckDMActivatedState)
	c:RegisterEffect(e3x)
	--Master Summon
	if mscon~=-1 then
		local ms=Effect.CreateEffect(c)
		ms:SetDescription(aux.Stringid(c:GetOriginalCode(),1))
		ms:SetType(EFFECT_TYPE_FIELD)
		ms:SetCode(EFFECT_SPSUMMON_PROC)
		ms:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		ms:SetRange(LOCATION_SZONE)
		ms:SetCondition(Auxiliary.MasterSummonCon(mscon))
		ms:SetOperation(Auxiliary.MasterSummonOp(mscustom))
		ms:SetValue(SUMMON_TYPE_MASTER)
		c:RegisterEffect(ms)
	end
	local sumlimit=Effect.CreateEffect(c)
	sumlimit:SetType(EFFECT_TYPE_SINGLE)
	sumlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	sumlimit:SetCode(EFFECT_SPSUMMON_CONDITION)
	sumlimit:SetValue(Auxiliary.MasterLimit)
	c:RegisterEffect(sumlimit)
	local neg=Effect.CreateEffect(c)
	neg:SetType(EFFECT_TYPE_SINGLE)
	neg:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	neg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	neg:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
						return e:GetHandler():IsSummonType(SUMMON_TYPE_MASTER)
					end
					)
	c:RegisterEffect(neg)
	--Penalty Effect
	local py=Effect.CreateEffect(c)
	py:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	py:SetCode(EVENT_TURN_END)
	py:SetRange(LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_REMOVED+LOCATION_OVERLAY+LOCATION_HAND+LOCATION_DECK)
	py:SetCondition(Auxiliary.PenaltyCheck(penaltycon))
	py:SetOperation(Auxiliary.PenaltyOperation(penalty))
	c:RegisterEffect(py)
	local reg=Effect.CreateEffect(c)
	reg:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	reg:SetCode(EVENT_LEAVE_FIELD)
	reg:SetOperation(Auxiliary.RegisterPenaltyEffect)
	c:RegisterEffect(reg)
	--Deck Master Replacement
	local rp2=Effect.CreateEffect(c)
	rp2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	rp2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	rp2:SetCode(EVENT_BE_MATERIAL)
	rp2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
						return not e:GetHandler():IsLocation(LOCATION_ONFIELD) and (e:GetHandler():GetPreviousLocation()==LOCATION_MZONE or e:GetHandler():GetPreviousLocation()==LOCATION_SZONE)
						end
					)
	rp2:SetOperation(Auxiliary.RegDeckSubstitute)
	c:RegisterEffect(rp2)
	if actcon_alt~=-1 then
		local rp3=Effect.CreateEffect(c)
		rp3:SetType(EFFECT_TYPE_FIELD)
		rp3:SetCode(EFFECT_SPSUMMON_PROC_G)
		rp3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		rp3:SetRange(LOCATION_EXTRA)
		rp3:SetCondition(Auxiliary.AltMasterSummonCon(typ,actcon_alt))
		rp3:SetOperation(Auxiliary.AltMasterSummonOp(typ))
		rp3:SetValue(SUMMON_TYPE_SPECIAL+1)
		c:RegisterEffect(rp3)
	end
	--keep on field
	local kp=Effect.CreateEffect(c)
	kp:SetType(EFFECT_TYPE_SINGLE)
	kp:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(kp)
	if not Global_DMRedirects then
		Global_DMRedirects=true
		--Redirect
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_TO_DECK_REDIRECT)
		ge1:SetTargetRange(0xff,0xff)
		ge1:SetTarget(Auxiliary.DMToExtra(typ))
		ge1:SetValue(LOCATION_EXTRA)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD)
		ge2:SetCode(EFFECT_TO_HAND_REDIRECT)
		ge2:SetTargetRange(0xff,0xff)
		ge2:SetTarget(Auxiliary.DMToExtra(typ))
		ge2:SetValue(LOCATION_EXTRA)
		Duel.RegisterEffect(ge2,0)
	end
end
--Deck Master Mechanic -- Filters --
function Auxiliary.ActGroupFilter(c,ogcode)
	return c:IsType(TYPE_DECKMASTER) and c:GetOriginalCode()==ogcode
end
function Auxiliary.DeckmasterFilter(c)
	return c:IsFaceup() and (c:GetFlagEffect(3339)>0 or (c:IsType(TYPE_DECKMASTER) and c:IsLocation(LOCATION_MZONE)))
end
--Deck Master First Activation
function Auxiliary.DMActCon(actcon)
	return function (e,tp,eg,ep,ev,re,r,rp)
		return Duel.CheckLocation(tp,LOCATION_SZONE,2) and e:GetHandler():GetFlagEffect(3338)==0 and (not actcon or actcon(e,tp,eg,ep,ev,re,r,rp))
	end
end
function Auxiliary.DMFirstAct(typ)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetFlagEffect(tp,3337)>0 or e:GetHandler():GetFlagEffect(3338)>0 or not Duel.CheckLocation(tp,LOCATION_SZONE,2) or Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),TYPE_DECKMASTER) then return end
		if not Duel.SelectYesNo(tp,aux.Stringid(39759362,2)) then
			local exc=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_DECKMASTER)
			Debug.Message(tostring(exc:GetCount()))
			for i0 in aux.Next(exc) do
				i0:RegisterFlagEffect(3338,RESET_EVENT+EVENT_CUSTOM+3338,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
			end
			return
		end
		local group=Group.CreateGroup()
		group:KeepAlive()
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_DECKMASTER)
		if g:GetCount()>0 then
			for i in aux.Next(g) do
				if i:GetOriginalCode()==e:GetHandler():GetOriginalCode() then
					if i:GetFlagEffect(3343)==0 then
						i:RegisterFlagEffect(3343,RESET_EVENT+EVENT_CUSTOM+3343,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
					end
				end
				group:AddCard(i)
			end
		end
		if group:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tc=group:Select(tp,1,1,nil):GetFirst()
			if tc:IsLocation(LOCATION_EXTRA) then
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP_ATTACK,true,0x4)
				tc:SetCardData(CARDDATA_TYPE,TYPE_SPELL+TYPE_CONTINUOUS)
				tc:SetCardData(CARDDATA_TYPE,typ)
				--register Original Activation
				tc:RegisterFlagEffect(3339,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
				tc:SetFlagEffectLabel(3339,100)
				--Cost payment
				local m=_G["c"..tc:GetCode()]
				m.DMCost(e,tp,eg,ep,ev,re,r,rp)
			else
				local g2=Duel.GetMatchingGroup(Auxiliary.ActGroupFilter,tp,LOCATION_EXTRA,0,e:GetHandler(),e:GetHandler():GetOriginalCode())
				if g2:GetCount()>0 then
					for i2 in aux.Next(g2) do
						if i2:GetFlagEffect(3338)~=0 then
							i2:ResetFlagEffect(3338)
						end
					end
				end
			end
		end
		--first turn flag
		Duel.RegisterFlagEffect(tp,3337,RESET_EVENT+EVENT_CUSTOM+3337,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE,1)
	end
end
--Check if the DM is in an Activated State
function Auxiliary.CheckDMActivatedState(e)
	return e:GetHandler():GetFlagEffect(3339)~=0 and e:GetHandler():GetFlagEffect(3340)==0
end
--Master Summon
function Auxiliary.MasterLimit(e,se,sp,st)
	return st&SUMMON_TYPE_MASTER==SUMMON_TYPE_MASTER
end
function Auxiliary.MasterSummonCon(mscon)
	return function (e,c)
		if c==nil then return true end
		return Auxiliary.CheckDMActivatedState(e) and (not mscon or mscon(e,c))
	end
end
function Auxiliary.MasterSummonOp(mscustom)
	return function (e,tp,eg,ep,ev,re,r,rp,c)
		c:RegisterFlagEffect(3340,RESET_EVENT+EVENT_CUSTOM+3340,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
		if mscustom then
			mscustom(e,tp,eg,ep,ev,re,r,rp,c)
		end
	end
end
--Penalty Effect
function Auxiliary.RegisterPenaltyEffect(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(3341,RESET_EVENT+EVENT_CUSTOM+3341,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
end 
function Auxiliary.PenaltyCheck(penaltycon)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(3341)~=0 and not Duel.IsExistingMatchingCard(Auxiliary.DeckmasterFilter,tp,LOCATION_ONFIELD,0,1,nil) and (not penaltycon or penaltycon(e,tp,eg,ep,ev,re,r,rp))
	end
end
function Auxiliary.PenaltyOperation(penalty)
	return function (e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,tp,e:GetHandler():GetOriginalCode())
		if penalty then
			penalty(e,tp,eg,ep,ev,re,r,rp)
		end
		e:GetHandler():ResetFlagEffect(3341)
	end
end
--Deck Master Replacement
function Auxiliary.RegDeckSubstitute(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--if not rc then return end
	rc:RegisterFlagEffect(3339,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
	rc:SetFlagEffectLabel(3339,99)
	Debug.Message('Deck Master has been replaced')
end
function Auxiliary.AltMasterSummonCon(typ,actcon_alt)
	return function (e,c)
		if c==nil then return true end
		local tp=c:GetControler()
		local ft=Duel.CheckLocation(tp,LOCATION_SZONE,2)
		local val=0
		if c:IsType(TYPE_XYZ) then val=c:GetRank()
		elseif c:IsType(TYPE_LINK) then val=c:GetLink()
		elseif c:IsType(TYPE_EVOLUTE) then val=c:GetStage()
		else val=c:GetLevel() end
		return ft and Duel.IsExistingMatchingCard(Auxiliary.AltMasterSummonFilter,tp,LOCATION_MZONE,0,1,nil,typ,val) and c:GetFlagEffect(3343)==0
			and (not actcon_alt or actcon_alt(e,c))
	end
end
function Auxiliary.AltMasterSummonOp(typ)
	return function (e,tp,eg,ep,ev,re,r,rp,c)
		local val=0
		if c:IsType(TYPE_XYZ) then val=c:GetRank()
		elseif c:IsType(TYPE_LINK) then val=c:GetLink()
		elseif c:IsType(TYPE_EVOLUTE) then val=c:GetStage()
		else val=c:GetLevel() end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Auxiliary.AltMasterSummonFilter,tp,LOCATION_MZONE,0,1,1,nil,typ,val)
		Duel.SendtoGrave(g,REASON_COST)
		if c:IsLocation(LOCATION_EXTRA) then
			Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP_ATTACK,true,0x4)
			c:SetCardData(CARDDATA_TYPE,TYPE_SPELL+TYPE_CONTINUOUS)
			c:SetCardData(CARDDATA_TYPE,typ)
			--register Substitute Activation
			c:RegisterFlagEffect(3339,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
			c:SetFlagEffectLabel(3339,101)
			local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_DECKMASTER)
			if g2:GetCount()>0 then
				for i in aux.Next(g2) do
					if i:GetOriginalCode()==e:GetHandler():GetOriginalCode() then
						if i:GetFlagEffect(3338)==0 then
							i:RegisterFlagEffect(3338,RESET_EVENT+EVENT_CUSTOM+3338,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
						end
					end
				end
			end
			--Cost payment
			local m=_G["c"..c:GetCode()]
			m.DMCost(e,tp,eg,ep,ev,re,r,rp)
			return
		end
	end
end
function Auxiliary.AltMasterSummonFilter(c,typ,val)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and not Duel.IsExistingMatchingCard(Auxiliary.DeckmasterFilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
		and (c:GetLevel()==val or (c:IsType(TYPE_XYZ) and c:GetRank()==val) or (c:IsType(TYPE_LINK) and c:GetLink()==val) or (c:IsType(TYPE_EVOLUTE) and c:GetStage()==val))
		and ((c:IsType(TYPE_NORMAL) and typ&TYPE_EFFECT~=TYPE_EFFECT) or (c:IsType(TYPE_EFFECT) and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_PENDULUM+TYPE_PANDEMONIUM+TYPE_EVOLUTE+TYPE_RITUAL) and typ&TYPE_EFFECT==TYPE_EFFECT)
			or (c:IsType(TYPE_RITUAL) and typ&TYPE_RITUAL==TYPE_RITUAL) or (c:IsType(TYPE_FUSION) and typ&TYPE_FUSION==TYPE_FUSION)
			or (c:IsType(TYPE_SYNCHRO) and typ&TYPE_SYNCHRO==TYPE_SYNCHRO) or (c:IsType(TYPE_LINK) and typ&TYPE_LINK==TYPE_LINK) or (c:IsType(TYPE_EVOLUTE) and typ&TYPE_EVOLUTE==TYPE_EVOLUTE))
end
--Redirect
function Auxiliary.DMToExtra(typ)
	return function(e,c)
		if c:IsType(TYPE_DECKMASTER) and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_EVOLUTE) then
			Card.SetCardData(c,CARDDATA_TYPE,typ+TYPE_FUSION)
			return true
		end
		return false
	end
end
--Random Target Auxiliary
function Auxiliary.CheckPrevRandom(c)
	return c:GetFlagEffect(39759371)>0
end
function Auxiliary.RandomTargetFilter(c)
	return c:GetFlagEffect(39759371)>0 and c:GetFlagEffectLabel(39759371)==999
end

--Global Card Effect Table
if not global_card_effect_table_global_check then
	global_card_effect_table_global_check=true
	global_card_effect_table={}
	Card.register_global_card_effect_table = Card.RegisterEffect
	function Card:RegisterEffect(e)
		if not global_card_effect_table[self] then global_card_effect_table[self]={} end
		table.insert(global_card_effect_table[self],e)
		self.register_global_card_effect_table(self,e)
	end
end

--Time Leap
function Card.IsCanBeTimeleapMaterial(c,ec,...)
	local funs={...}
	local exctyp=funs[1]
	if not exctyp then
		if c:IsType(TYPE_LINK) or c:IsType(TYPE_EVOLUTE) or c:IsType(TYPE_XYZ) then return false end
	end
	local tef={c:IsHasEffect(EFFECT_CANNOT_BE_TIMELEAP_MATERIAL)}
	for _,te in ipairs(tef) do
		if te:GetValue()(te,ec) then return false end
	end
	return true
end
function Auxiliary.AddOrigTimeleapType(c,issynchro)
	table.insert(Auxiliary.Timeleaps,c)
	Auxiliary.Customs[c]=true
	local issynchro=issynchro==nil and false or issynchro
	Auxiliary.Timeleaps[c]=function() return issynchro end
end
function Auxiliary.AddTimeleapProc(c,futureval,sumcon,filter,customop,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local t={...}
	local list={}
	local min,max=1,1
	if #t>0 then
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
		end
	else
		table.insert(list,{999,min,max})
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Auxiliary.TimeleapCondition(sumcon,filter,table.unpack(list)))
	e1:SetTarget(Auxiliary.TimeleapTarget(filter,table.unpack(list)))
	e1:SetOperation(Auxiliary.TimeleapOperation(customop))
	e1:SetValue(825)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_FUTURE)
	e2:SetValue(Auxiliary.FutureVal(futureval))
	c:RegisterEffect(e2)
end
function Auxiliary.TimeleapCondition(sumcon,filter,...)
	local funs={...}
	return  function(e,c)
				if c==nil then return true end
				if (c:IsType(TYPE_PENDULUM) or c:IsType(TYPE_PANDEMONIUM)) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=Duel.GetMatchingGroup(Card.IsCanBeTimeleapMaterialMaterial,tp,LOCATION_MZONE,0,nil,c)
				return (not sumcon or sumcon(e,c))
					and mg:IsExists(Auxiliary.TimeleapMaterialFilter,1,nil,filter,e,tp,Group.CreateGroup(),mg,c,0,table.unpack(funs))
			end
end
function Auxiliary.TimeleapMaterialFilter(c,filter,e,tp,sg,mg,bc,ct,...)
	sg:AddCard(c)
	ct=ct+1
	local funs,max,chk={...},1
	if (not filter or filter(c,e,mg)) then
		chk=true
	end
	if #funs>0 then
		for i=1,#funs do
			if funs[i][1]~=999 then 
				max=max+funs[i][3]
			else
				max=funs[i][3]
			end
			if funs[i][1]~=999 and funs[i][1](c,e,mg) then
				chk=true
			end
		end
	end
	if max>99 then max=99 end
	local res=chk and (Auxiliary.TimeleapCheckGoal(tp,sg,bc,ct,table.unpack(funs))
		or (ct<max and mg:IsExists(Auxiliary.TimeleapMaterialFilter,1,sg,filter,e,tp,sg,mg,bc,ct,table.unpack(funs))))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.TimeleapCheckGoal(tp,sg,bc,ct,...)
	local funs,min={...},1
	if #funs>0 then
		for i=1,#funs do
			if funs[i][1]~=999 and not sg:IsExists(funs[i][1],funs[i][2],nil) then return false end
			if funs[i][1]~=999 then 
				min=min+funs[i][2]
			else
				min=funs[i][2]
			end
		end
	end
	return ct>=min and Duel.GetLocationCountFromEx(tp,tp,sg,bc)>0
end
function Auxiliary.TimeleapTarget(filter,...)
	local funs,min,max={...},1,1
	for i=1,#funs do
		if funs[i][1]~=999 then
			min=min+funs[i][2] 
			max=max+funs[i][3]
		else
			min=funs[i][2] 
			max=funs[i][3]
		end
	end
	if max>99 then max=99 end
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetMatchingGroup(Card.IsCanBeTimeleapMaterial,tp,LOCATION_MZONE,0,nil,c)
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_TIMELEAP_MATERIAL)}
				for _,te in ipairs(ce) do
					local tc=te:GetHandler()
					if tc then bg:AddCard(tc) end
				end
				if #bg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					bg:Select(tp,#bg,#bg,nil)
				end
				local sg=Group.CreateGroup()
				sg:Merge(bg)
				local finish=false
				while not (sg:GetCount()>=max) do
					finish=Auxiliary.TimeleapCheckGoal(tp,sg,c,#sg,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.TimeleapMaterialFilter,sg,filter,e,tp,sg,mg,c,#sg,table.unpack(funs))
					if #cg==0 then break end
					local cancel=not finish
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
					local tc=cg:SelectUnselect(sg,tp,finish,cancel,min,max)
					if not tc then break end
					if not bg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
							if (sg:GetCount()>=max) then finish=true end
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
function Auxiliary.TimeleapOperation(customop)
	return  function(e,tp,eg,ep,ev,re,r,rp,c)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				if not customop then
					Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+0x10000000000)
				else
					customop(e,tp,eg,ep,ev,re,r,rp,c,g)
				end
				g:DeleteGroup()
			end
end
function Card.GetFuture(c)
	if not Auxiliary.Timeleaps[c] then return 0 end
	local te=c:IsHasEffect(EFFECT_FUTURE)
	if type(te:GetValue())=='function' then
		return te:GetValue()(te,c)
	else
		return te:GetValue()
	end
end
function Card.IsFuture(c,future)
	return c:GetFuture()==future
end
function Auxiliary.FutureVal(future)
	return  function(e,c)
				local future=future
				--insert modifications here
				return future
			end
end
