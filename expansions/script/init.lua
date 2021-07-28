--Not yet finalized values
--Custom constants
EFFECT_DEFAULT_CALL					=31993443
EFFECT_EXTRA_GEMINI					=86433590
EFFECT_AVAILABLE_LMULTIPLE			=86433612
EFFECT_MULTIPLE_LMATERIAL			=86433613
EFFECT_RANDOM_TARGET				=39759371
EFFECT_CANNOT_BANISH_FD_EFFECT		=856
TYPE_CUSTOM							=0

CTYPE_CUSTOM						=0

EVENT_XYZATTACH						=EVENT_CUSTOM+9966607
EVENT_LP_CHANGE						=EVENT_CUSTOM+68007397

EFFECT_COUNT_SECOND_HOPT			=10000000

REASON_FAKE_FU_BANISH=0x10000000000
FLAG_FACEDOWN_BANISH=21932999
FLAG_FAKE_FU_BANISH=21933000

--Commonly used cards
CARD_BLUEEYES_SPIRIT				=59822133
CARD_CYBER_DRAGON					=70095154
CARD_PYRO_CLOCK						=1082946
CARD_INLIGHTENED_PSYCHIC_HELMET		=102400006
CARD_NEBULA_TOKEN					=218201917
CARD_DRAGON_EGG_TOKEN				=20157305
CARD_BLACK_GARDEN					=71645242
CARD_EVIL_DRAGON_ANANTA				=8400623

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
REASON_EXTRA					  =REASON_FUSION+REASON_SYNCHRO+REASON_XYZ+REASON_LINK

--Custom Functions
function Card.IsCustomType(c,tpe,scard,sumtype,p)
	return (c:GetType(scard,sumtype,p)>>32)&tpe>0
end
function Card.IsCustomReason(c,rs)
	return (c:GetReason()>>32)&rs>0
end
function GetID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local scard=_G[str]
	local s_id=tonumber(string.sub(str,2))
	return scard,s_id
end
--overwrite functions
local is_type, card_remcounter, duel_remcounter, effect_set_target_range, effect_set_reset, add_xyz_proc, add_xyz_proc_nlv, duel_overlay, duel_set_lp, duel_select_target, duel_banish, card_check_remove_overlay_card, is_reason, duel_check_tribute, select_tribute,card_sethighlander, card_is_facedown = 
	Card.IsType, Card.RemoveCounter, Duel.RemoveCounter, Effect.SetTargetRange, Effect.SetReset, Auxiliary.AddXyzProcedure, Auxiliary.AddXyzProcedureLevelFree, Duel.Overlay, Duel.SetLP, Duel.SelectTarget, Duel.Remove, Card.CheckRemoveOverlayCard, Card.IsReason, Duel.CheckTribute, Duel.SelectTribute, Card.SetUniqueOnField, Card.IsFacedown

dofile("expansions/script/proc_evolute.lua") --Evolutes
dofile("expansions/script/proc_conjoint.lua") --Conjoints
dofile("expansions/script/proc_pandemonium.lua") --Pandemoniums
dofile("expansions/script/proc_polarity.lua") --Polarities
dofile("expansions/script/proc_spatial.lua") --Spatials
dofile("expansions/script/proc_corona.lua") --Coronas
dofile("expansions/script/proc_skill.lua") --Skills
dofile("expansions/script/proc_deckmaster.lua") --Deck Masters
dofile("expansions/script/proc_bigbang.lua") --Bigbangs
dofile("expansions/script/proc_timeleap.lua") --Time Leaps
dofile("expansions/script/proc_relay.lua") --Relays
dofile("expansions/script/proc_harmony.lua") --Harmonies
dofile("expansions/script/proc_accent.lua") --Accents
dofile("expansions/script/proc_bypath.lua") --Bypaths
dofile("expansions/script/proc_toxia.lua") --Toxias
dofile("expansions/script/proc_annotee.lua") --Annotees
dofile("expansions/script/proc_chroma.lua") --Chromas
dofile("expansions/script/proc_perdition.lua") --Perditions
dofile("expansions/script/proc_impure.lua") --Impures
dofile("expansions/script/proc_runic.lua") --Runic
dofile("expansions/script/proc_magick.lua") --Magick
dofile("expansions/script/proc_xros.lua") --Xroses
dofile("expansions/script/muse_proc.lua") --"Muse"
dofile("expansions/script/tables.lua") --Special Tables

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
-- Card.RegisterEffect=function(c,e,forced)
	-- if c:IsStatus(STATUS_INITIALIZING) and not e then return end
	-- registereff(c,e,forced)
	-- local m=_G["c"..c:GetOriginalCode()]
	-- if not m then return false end
	-- if not m.default_call_table then
		-- m.default_call_table={}
	-- end
	-- local etable=m.default_call_table
	-- table.insert(etable,e)
	-- -- local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
	-- -- if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
	-- -- local ex=Effect.CreateEffect(c)
	-- -- ex:SetType(EFFECT_TYPE_SINGLE)
	-- -- ex:SetProperty(prop)
	-- -- ex:SetCode(EFFECT_DEFAULT_CALL)
	-- -- ex:SetLabelObject(e)
	-- -- ex:SetLabel(c:GetOriginalCode())
	-- -- registereff(c,ex,forced)
-- end
Auxiliary.kaiju_procs={}
global_target_range_effect_table={}
Effect.SetTargetRange=function(e,self,oppo)
	global_target_range_effect_table[e]={self,oppo}
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
Duel.Remove=function(cc,pos,r)
	local cc=Group.CreateGroup()+cc
	local tg=cc:Clone()
	for c in aux.Next(tg) do
		if (not pos or pos&POS_FACEDOWN~=0) and r&REASON_EFFECT~=0 then
			local ef={c:IsHasEffect(EFFECT_CANNOT_BANISH_FD_EFFECT)}
			for _,te1 in ipairs(ef) do
				local cf=te1:GetValue()
				local typ=aux.GetValueType(cf)
				if typ=="function" then
					if cf(te1,c:GetReasonEffect(),c:GetReasonPlayer()) then 
						cc=cc-c 
					end
				elseif cf>0 then 
					cc=cc-c 
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
	return duel_banish(cc,pos,r)
end
Card.CheckRemoveOverlayCard=function(c,tp,ct,r)
	if Duel.IsPlayerAffectedByEffect(tp,25149863) and bit.band(r,REASON_COST)~=0 then
		Duel.RegisterFlagEffect(tp,25149863,0,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE,1)
		Duel.SetFlagEffectLabel(tp,25149863,ct)
	end
	return card_check_remove_overlay_card(c,tp,ct,r)
end
Duel.CheckTribute=function(c,min,max,mg,p,zone)
	if not max then max=min end
	if not p then p=c:GetControler() end
	if not zone then zone=0x1f001f end
	local ef={Duel.IsPlayerAffectedByEffect(c:GetControler(),EFFECT_MUST_USE_MZONE)}
	for _,e in ipairs(ef) do
		local ev=e:GetValue()
		if type(ev)=='function' then zone=zone&ev(e) else zone=zone&ev end
	end
	zone=zone&(0x1f<<16*p)
	if zone>0x1f then zone=zone>>16 end
	return duel_check_tribute(c,min,max,mg,p,zone)
end
Duel.SelectTribute=function(sp,c,min,max,mg,p)
	if not p then p=c:GetControler() end
	local zone=0x1f001f
	local ef={Duel.IsPlayerAffectedByEffect(sp,EFFECT_MUST_USE_MZONE)}
	for _,e in ipairs(ef) do
		local ev=e:GetValue()
		if type(ev)=='function' then zone=zone&ev(e) else zone=zone&ev end
	end
	zone=zone&(0x1f<<16*p)
	if zone>0x1f then zone=zone>>16 end
	local rg=mg~=nil and mg or Duel.GetTributeGroup(c)
	local sg=Group.CreateGroup()
	if rg:IsExists(Auxiliary.TribCheckRecursive,1,nil,sp,rg,sg,c,0,min,max,p,zone) then
		local finish=false
		while #sg<max do
			finish=Auxiliary.TributeGoal(sp,sg,c,#sg,min,max,p,zone)
			local cg=rg:Filter(Auxiliary.TribCheckRecursive,sg,sp,rg,sg,c,#sg,min,max,p,zone)
			if #cg==0 then break end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TRIBUTE)
			local tc=cg:SelectUnselect(sg,sp,finish,false,min,max)
			if not tc then break end
			if not sg:IsContains(tc) then
				sg:AddCard(tc)
				if #sg>=max then finish=true end
			else sg:RemoveCard(tc) end
		end
	end
	return #sg>0 and sg or select_tribute(sp,c,min,max,rg,p)
end
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
function Auxiliary.CannotBeEDMaterial(c,f,range,isrule,reset)
	local property = 0
	if (isrule == nil or isrule == true) then
		property = property+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE
	end
	if range ~=nil then
		property = property+EFFECT_FLAG_SINGLE_RANGE
	end
	for _,val in ipairs(Auxiliary.CannotBeEDMatCodes) do
		local restrict = Effect.CreateEffect(c)
		restrict:SetType(EFFECT_TYPE_SINGLE)
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
			restrict:SetReset(reset)
		end
		c:RegisterEffect(restrict)
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
--Random Target Auxiliary
function Auxiliary.CheckPrevRandom(c)
	return c:GetFlagEffect(39759371)>0
end
function Auxiliary.RandomTargetFilter(c)
	return c:GetFlagEffect(39759371)>0 and c:GetFlagEffectLabel(39759371)==999
end

--Hardcode AZW Phalanx Unicorn (39510) allow equipped monster to activate its effect without detaching
local ocheck,oremove=Card.CheckRemoveOverlayCard,Card.RemoveOverlayCard
function Card.CheckRemoveOverlayCard(c,p,ct,r)
	local tc=c:GetEquipGroup()
	if tc and tc:FilterCount(Card.IsHasEffect,nil,39510)>0 and r and (r&REASON_COST>0) then
		return true
	else
		return ocheck(c,p,ct,r)
	end
end
function Card.RemoveOverlayCard(c,p,minct,maxct,r)
	local tc=c:GetEquipGroup()
	if tc and tc:FilterCount(Card.IsHasEffect,nil,39510)>0 and r and (r&REASON_COST>0) and (not ocheck(c,p,minct,r) or Duel.SelectYesNo(p,aux.Stringid(39510,0))) then
		return 0
	else
		return oremove(c,p,minct,maxct,r)
	end
end

----------------------------------------------------------------------------------------------------------------
--AUXS AND FUNCTIONS PORTED FROM EDOPRO (CAN BE EXPANDED FOR FACILITATING SCRIPT COMPATIBILITY BETWEEN THE SIMS)
----------------------------------------------------------------------------------------------------------------
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
function Auxiliary.SelectUnselectLoop(c,sg,mg,e,tp,minc,maxc,rescon)
	local res
	if #sg>=maxc then return false end
	sg:AddCard(c)
	if rescon then
		local _,stop=rescon(sg,e,tp,mg)
		if stop then 
			sg:RemoveCard(c)
			return false
		end
	end
	if #sg<minc then
		res=mg:IsExists(Auxiliary.SelectUnselectLoop,1,sg,sg,mg,e,tp,minc,maxc,rescon)
	elseif #sg<maxc then
		res=(not rescon or rescon(sg,e,tp,mg)) or mg:IsExists(Auxiliary.SelectUnselectLoop,1,sg,sg,mg,e,tp,minc,maxc,rescon)
	else
		res=(not rescon or rescon(sg,e,tp,mg))
	end
	sg:RemoveCard(c)
	return res
end
function Auxiliary.SelectUnselectGroup(g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,finishcon,breakcon,cancelable)
	local minc=minc or 1
	local maxc=maxc or #g
	if chk==0 then return g:IsExists(Auxiliary.SelectUnselectLoop,1,nil,Group.CreateGroup(),g,e,tp,minc,maxc,rescon) end
	local hintmsg=hintmsg and hintmsg or 0
	local sg=Group.CreateGroup()
	while true do
		local finishable = #sg>=minc and (not finishcon or finishcon(sg,e,tp,g))
		local mg=g:Filter(Auxiliary.SelectUnselectLoop,sg,sg,g,e,tp,minc,maxc,rescon)
		if (breakcon and breakcon(sg,e,tp,mg)) or #mg<=0 or #sg>=maxc then break end
		Duel.Hint(HINT_SELECTMSG,seltp,hintmsg)
		local tc=mg:SelectUnselect(sg,seltp,finishable,finishable or (cancelable and #sg==0),minc,maxc)
		if not tc then break end
		if sg:IsContains(tc) then
			sg:RemoveCard(tc)
		else
			sg:AddCard(tc)
		end
	end
	return sg
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

function Duel.IsMainPhase()
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function Duel.GetTargetCards(e)
	return Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
end
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

--Glitchy's custom auxs and functions
if not glitchy_effect_table then glitchy_effect_table={} end
if not glitchy_archetype_table then glitchy_archetype_table={} end

--constant aliases
RACE_PSYCHIC=RACE_PSYCHO
RACE_WINGEDBEAST=RACE_WINDBEAST
EFFECT_TYPE_TRIGGER=EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_TRIGGER_F
EFFECT_TYPE_QUICK=EFFECT_TYPE_QUICK_O+EFFECT_TYPE_QUICK_F
EFFECT_TYPE_CHAIN_STARTER=EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_QUICK_O+EFFECT_TYPE_QUICK_F+EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_IGNITION

--glitchy custom categories (apply with e:SetGlitchyCategory)
GLCATEGORY_PLACE_SELF_AS_CONTINUOUS_TRAP=0x1
GLCATEGORY_ED_DRAW=0x8000
GLCATEGORY_ACTIVATE_LMARKER=0x10000
GLCATEGORY_DEACTIVATE_LMARKER=0x20000
GLCATEGORY_SYNCHRO_SUMMON=0x40000

--glitchy's custom effects
EFFECT_CANNOT_ACTIVATE_LMARKER=8000
EFFECT_CANNOT_DEACTIVATE_LMARKER=8001
EFFECT_PRE_LOCATION=8002
EFFECT_NO_ARCHETYPE=8003
EFFECT_BECOME_HOPT=99977755
EFFECT_SYNCHRO_MATERIAL_EXTRA=26134837
EFFECT_SYNCHRO_MATERIAL_MULTIPLE=26134838

--glitchy's custom events
EVENT_ACTIVATE_LINK_MARKER=9000
EVENT_DEACTIVATE_LINK_MARKER=9001

--zone constants
EXTRA_MONSTER_ZONE=0x60

--resets
RESETS_STANDARD_DISABLE=RESETS_STANDARD|RESET_DISABLE

--Duel Effects without player target range
DUEL_EFFECT_NOP={EFFECT_DISABLE_FIELD}

if not Auxiliary.GLSpecialInfos then Auxiliary.GLSpecialInfos={} end
function Duel.SetGLOperationInfo(e,category,g,ct,p,loc,fromloc)
	if not g then
		Auxiliary.GLSpecialInfos[e]={category,nil,ct,p,loc,fromloc}
	else
		Auxiliary.GLSpecialInfos[e]={category,g,ct,0,0,fromloc}
	end
end
function Auxiliary.GLSetSpecialInfo(e,category,g,ct,p,loc,fromloc)
	Duel.SetGLOperationInfo(e,category,g,ct,p,loc,fromloc)
end
function Auxiliary.SetGLOperationInfo(e,category,g,ct,p,loc,fromloc)
	Duel.SetGLOperationInfo(e,category,g,ct,p,loc,fromloc)
end

function Effect.GLSetCategory(e,category)
	if not glitchy_effect_table[e] then glitchy_effect_table[e]={0} end
	glitchy_effect_table[e][1]=glitchy_effect_table[e][1]|category
end
function Effect.SetGlitchyCategory(e,category)
	Effect.GLSetCategory(e,category)
end

function Effect.GLGetTargetRange(e)
	if not global_target_range_effect_table[e] then return 0,0 end
	local s=global_target_range_effect_table[e][1]
	local o=global_target_range_effect_table[e][2]
	return s,o
end

function Effect.GLGetReset(e)
	if not global_reset_effect_table[e] then return 0,0 end
	local reset=global_reset_effect_table[e][1]
	local rct=global_reset_effect_table[e][2]
	return reset,rct
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
local synchro_proc, synchro_mix_proc = Auxiliary.AddSynchroProcedure, Auxiliary.AddSynchroMixProcedure

SYNCHRO_MIX_FUNCTION_COUNT=3

Auxiliary.AddSynchroProcedure=function(c,f1,f2,minc,maxc)
	if c.extradeckproc==nil then
		local mt=getmetatable(c)
		mt.extradeckproc={}
	end
	local syn={"Synchro",f1,f2,minc,maxc}
	table.insert(c.extradeckproc,syn)
	if f1==nil then f1=aux.Tuner(nil) end
	if f2==nil then f2=false end
	Auxiliary.XSynchroProcedure(c,false,f2,minc,maxc,nil,aux.Tuner(f1))
end

Auxiliary.AddSynchroMixProcedure=function(c,f1,f2,f3,f4,minc,maxc,gc)
	if c.extradeckproc==nil then
		local mt=getmetatable(c)
		mt.extradeckproc={}
	end
	local syn={"SynchroMix",f1,f2,f3,f4,minc,maxc,gc}
	table.insert(c.extradeckproc,syn)
	Auxiliary.XSynchroProcedure(c,false,f4,minc,maxc,gc,f1,f2,f3)
	--synchro_mix_proc(c,f1,f2,f3,f4,minc,maxc,gc)
end

--Synchro monster, f1~f3 each 1 MONSTER + f4 min to max monsters
function Auxiliary.XSynchroProcedure(c,metacheck,f,minc,maxc,gc,...)
	local fx={...}
	if metacheck then
		if c.extradeckproc==nil then
			local mt=getmetatable(c)
			mt.extradeckproc={}
		end
		local syn={"XSynchro",f,minc,maxc,gc,table.unpack(fx)}
		table.insert(c.extradeckproc,syn)
	end
	if not minc then minc=1 end
	if not maxc then maxc=99 end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1164)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Auxiliary.XSynMixCondition(f,minc,maxc,gc,table.unpack(fx)))
	e1:SetTarget(Auxiliary.XSynMixTarget(f,minc,maxc,gc,table.unpack(fx)))
	e1:SetOperation(Auxiliary.XSynMixOperation(f,minc,maxc,gc,table.unpack(fx)))
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e1)
end
function Auxiliary.XSynMaterialFilter(c,syncard)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsFaceup() and c:IsCanBeSynchroMaterial(syncard)
	else
		if c:IsLocation(LOCATION_REMOVED) and not c:IsFaceup() then return false end
		local egroup={c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_EXTRA)}
		for _,ce in ipairs(egroup) do
			if ce and (not ce:GetTarget() or ce:GetTarget()(syncard)) and c:IsCanBeSynchroMaterial(syncard) then
				return true
			end
		end
		return false
	end
end
function Auxiliary.XGetSynMaterials(tp,syncard)
	local mg=Duel.GetMatchingGroup(Auxiliary.XSynMaterialFilter,tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_SZONE+LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA+LOCATION_REMOVED,nil,syncard)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		local mg2=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND,0,nil,syncard)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	return mg
end
function Auxiliary.XSynMixCondition(f,minc,maxc,gc,...)
	local fx={...}
	return	function(e,c,smat,mg1,min,max)
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
				local mg
				local mgchk=false
				if mg1 then
					mg=mg1
					mgchk=true
				else
					mg=Auxiliary.XGetSynMaterials(tp,c)
				end
				if smat~=nil then mg:AddCard(smat) end
				return mg:IsExists(Auxiliary.XSynMixFilterRecursive,1,nil,f,minc,maxc,c,mg,smat,gc,mgchk,nil,1,table.unpack(fx))
			end
end
function Auxiliary.XSynMixFilterRecursive(c,f,minc,maxc,syncard,mg,smat,gc,mgchk,exg,index,...)
	local fx={...}
	local exg=exg
	if exg==nil then
		exg=Group.CreateGroup()
		exg:KeepAlive()
	end
	if index>#fx then
		return mg:IsExists(Auxiliary.XSynMixFilterFinal,1,exg,f,minc,maxc,syncard,mg,smat,gc,mgchk,exg)
	else
		exg:AddCard(c)
		local indexskip,safelock=1,false
		if c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE) then
			local egroup={c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)}
			for _,ce in ipairs(egroup) do
				if safelock then break end
				if ce and (not ce:GetTarget() or ce:GetTarget()(syncard)) and ((type(ce:GetValue())=="function" and ce:GetValue()(c,f,minc,maxc,syncard)>1) or ce:GetValue()>1) then
					local skip=(type(ce:GetValue())=="function") and ce:GetValue()(c,f,minc,maxc,syncard) or ce:GetValue()
					local check=0
					for i=index,#fx do
						if fx[i]~=nil and (not fx[i] or fx[i](c,syncard)) then
							check=check+1
						end
					end
					if check>=skip then
						indexskip=indexskip+skip-1
						safelock=true
					end
				end
			end
		end
		local check=(fx[index]~=nil and (fx[index]==false or fx[index](c,syncard)) and mg:IsExists(Auxiliary.XSynMixFilterRecursive,1,exg,f,minc,maxc,syncard,mg,smat,gc,mgchk,exg,index+indexskip,table.unpack(fx)))
		exg:RemoveCard(c)
		return check
	end
end
function Auxiliary.XSynMixFilterFinal(c,f,minc,maxc,syncard,mg1,smat,gc,mgchk,exg)
	if f and not f(c,syncard) then return false end
	local sg=exg:Clone()
	sg:AddCard(c)
	local mg=mg1:Clone()
	if f then
		mg=mg:Filter(f,sg,syncard)
	else
		mg:Sub(sg)
	end
	local ctfix=1
	if c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE) then
		local egroup={c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)}
		local safelock=false
		for _,ce in ipairs(egroup) do
			if safelock then break end
			if ce and (not ce:GetTarget() or ce:GetTarget()(syncard)) and ((type(ce:GetValue())=="function" and ce:GetValue()(c,nil,minc,nil,syncard)>1) or ce:GetValue()>1) then
				local skip=(type(ce:GetValue())=="function") and ce:GetValue()(c,f,minc,maxc,syncard) or ce:GetValue()
				ctfix=ctfix+skip-1
				safelock=true
			end
		end
	end
	return Auxiliary.XSynMixCheck(mg,sg,minc-ctfix,maxc-ctfix,syncard,smat,gc,mgchk)
end
function Auxiliary.XSynMixCheck(mg,sg1,minc,maxc,syncard,smat,gc,mgchk)
	local tp=syncard:GetControler()
	local sg=Group.CreateGroup()
	--Debug.Message(tostring(minc).." "..tostring(syncard:GetCode()))
	if minc==0 and Auxiliary.XSynMixCheckGoal(tp,sg1,0,0,syncard,sg,smat,gc,mgchk) then return true end
	if maxc==0 then return false end
	return mg:IsExists(Auxiliary.XSynMixCheckRecursive,1,nil,tp,sg,mg,0,minc,maxc,syncard,sg1,smat,gc,mgchk)
end
function Auxiliary.XSynMixCheckRecursive(c,tp,sg,mg,ct,minc,maxc,syncard,sg1,smat,gc,mgchk)
	sg:AddCard(c)
	local ctfix=1
	if c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE) then
		local egroup={c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)}
		local safelock=false
		for _,ce in ipairs(egroup) do
			if safelock then break end
			if ce and (not ce:GetTarget() or ce:GetTarget()(syncard)) and ((type(ce:GetValue())=="function" and ce:GetValue()(c,nil,minc,nil,syncard)>1) or ce:GetValue()>1) then
				local skip=(type(ce:GetValue())=="function") and ce:GetValue()(c,f,minc,maxc,syncard) or ce:GetValue()
				ctfix=ctfix+skip-1
				safelock=true
			end
		end
	end
	ct=ct+ctfix
	local res=Auxiliary.XSynMixCheckGoal(tp,sg,minc,ct,syncard,sg1,smat,gc,mgchk)
		or (ct<maxc and mg:IsExists(Auxiliary.XSynMixCheckRecursive,1,sg,tp,sg,mg,ct,minc,maxc,syncard,sg1,smat,gc,mgchk))
	sg:RemoveCard(c)
	ct=ct-ctfix
	return res
end
function Auxiliary.XSynMixCheckGoal(tp,sg,minc,ct,syncard,sg1,smat,gc,mgchk)
	if ct<minc then return false end
	local g=sg:Clone()
	g:Merge(sg1)
	if Duel.GetLocationCountFromEx(tp,tp,g,syncard)<=0 then return false end
	if gc and not gc(g) then return false end
	if smat and not g:IsContains(smat) then return false end
	if not Auxiliary.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL) then return false end
	
	-- local ctfix=0
	-- local gg=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MATERIAL_MULTIPLE)
	-- if #gg>0 then
		-- for c in aux.Next(gg) do
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
		-- end
	-- end
			
	if not g:CheckWithSumEqual(Card.GetSynchroLevel,syncard:GetLevel(),g:GetCount(),g:GetCount(),syncard)
		and (not g:IsExists(Card.IsHasEffect,1,nil,89818984)
		or not g:CheckWithSumEqual(Auxiliary.GetSynchroLevelFlowerCardian,syncard:GetLevel(),g:GetCount(),g:GetCount(),syncard))
		then return false end
	local hg=g:Filter(Card.IsLocation,nil,LOCATION_HAND):Filter(Card.IsControler,nil,tp)
	local hct=hg:GetCount()
	if hct>0 and not mgchk then
		local found=false
		for c in aux.Next(g) do
			local he,hf,hmin,hmax=c:GetHandSynchro()
			if he then
				found=true
				if hf and hg:IsExists(Auxiliary.SynLimitFilter,1,c,hf,he,syncard) then return false end
				if (hmin and hct<hmin) or (hmax and hct>hmax) then return false end
			end
		end
		if not found then return false end
	end
	local eg1=g:Filter(Card.IsLocation,nil,LOCATION_SZONE+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA+LOCATION_REMOVED):Filter(Card.IsControler,nil,tp):Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MATERIAL_EXTRA)
	local eg2=g:Filter(Card.IsLocation,nil,LOCATION_SZONE+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA+LOCATION_REMOVED+LOCATION_HAND):Filter(Card.IsControler,nil,1-tp):Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MATERIAL_EXTRA)
	eg1:Merge(eg2)
	local ect=eg1:GetCount()
	if ect>0 and not mgchk then
		local found=false
		for c in aux.Next(g) do
			local egroup={c:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_EXTRA)}
			local found=false
			for _,ce in ipairs(egroup) do
				if ce then
					local hf,hmin,hmax=ce:GetValue(),target_range_table[ce][1],target_range_table[ce][2]
					found=true
					if hf and hg:IsExists(Auxiliary.SynLimitFilter,1,c,hf,ce,syncard) then return false end
					if (hmin and ect<hmin) or (hmax and ect>hmax) then return false end
				end
			end
		end
		if not found then return false end
	end
	for c in aux.Next(g) do
		local le,lf,lloc,lmin,lmax=c:GetTunerLimit()
		if le then
			local lct=g:GetCount()-1
			if lloc then
				local llct=g:FilterCount(Card.IsLocation,c,lloc)
				if llct~=lct then return false end
			end
			if lf and g:IsExists(Auxiliary.SynLimitFilter,1,c,lf,le,syncard) then return false end
			if (lmin and lct<lmin) or (lmax and lct>lmax) then return false end
		end
	end
	return true
end
function Auxiliary.XSynMixTarget(f,minc,maxc,gc,...)
	local fx={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg1,min,max)
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local g=Group.CreateGroup()
				g:KeepAlive()
				local mg
				if mg1 then
					mg=mg1
				else
					mg=Auxiliary.XGetSynMaterials(tp,c)
				end
				if smat~=nil then mg:AddCard(smat) end
				if #fx>0 then
					local fct=#fx
					for index=1,#fx do
						if index>fct then break end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
						local cc=mg:FilterSelect(tp,Auxiliary.XSynMixFilterRecursive,1,1,g,f,minc,maxc,c,mg,smat,gc,nil,g,index,table.unpack(fx)):GetFirst()
						local indexskip,safelock=1,false
						if cc:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE) then
							local egroup={cc:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)}
							for _,ce in ipairs(egroup) do
								if safelock then break end
								if ce and (not ce:GetTarget() or ce:GetTarget()(c)) and ((type(ce:GetValue())=="function" and ce:GetValue()(cc,f,minc,maxc,c)>1) or ce:GetValue()>1) then
									local skip=(type(ce:GetValue())=="function") and ce:GetValue()(cc,f,minc,maxc,c) or ce:GetValue()
									local check=0
									for i=1,#fx do
										if fx[i]~=nil and (not fx[i] or fx[i](cc,c)) then
											check=check+1
										end
									end
									if check>=skip then
										fct=fct-skip+1
										safelock=true
									end
								end
							end
						end
						g:AddCard(cc)
					end
				end
				local gf=Group.CreateGroup()
				local fct=maxc-1
				for i=0,maxc-1 do
					if i>fct then break end
					local mg2=mg:Clone()
					if f then
						mg2=mg2:Filter(f,g,c)
					else
						mg2:Sub(g)
					end
					local cg=mg2:Filter(Auxiliary.XSynMixCheckRecursive,gf,tp,gf,mg2,i,minc,maxc,c,g,smat,gc)
					if cg:GetCount()==0 then break end
					local minct=1
					if Auxiliary.SynMixCheckGoal(tp,gf,minc,i,c,g,smat,gc) then
						minct=0
					end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
					local tg=cg:Select(tp,minct,1,nil)
					local cc=tg:GetFirst()
					local indexskip,safelock=1,false
					if cc:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE) then
						local egroup={cc:IsHasEffect(EFFECT_SYNCHRO_MATERIAL_MULTIPLE)}
						for _,ce in ipairs(egroup) do
							if safelock then break end
							if ce and (not ce:GetTarget() or ce:GetTarget()(c)) and ((type(ce:GetValue())=="function" and ce:GetValue()(cc,f,minc,maxc,c)>1) or ce:GetValue()>1) then
								local skip=(type(ce:GetValue())=="function") and ce:GetValue()(cc,f,minc,maxc,c) or ce:GetValue()
								fct=fct-skip+1
								safelock=true
							end
						end
					end
					if tg:GetCount()==0 then break end
					gf:Merge(tg)
				end
				g:Merge(gf)
				if g:GetCount()>0 then
					e:SetLabelObject(g)
					return true
				else return false end
			end
end
function Auxiliary.XSynMixOperation(f,minct,maxc,gc,...)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
				g:DeleteGroup()
			end
end
-----------------

--EFFECT TABLES
--Global Card Effect Table
if not global_card_effect_table_global_check then
	global_card_effect_table_global_check=true
	global_card_effect_table={}
	Card.register_global_card_effect_table = Card.RegisterEffect
	function Card:RegisterEffect(e)
		if not global_card_effect_table[self] then global_card_effect_table[self]={} end
		table.insert(global_card_effect_table[self],e)
		if e:GetCode()==EFFECT_DISABLE_FIELD and e:GetLabel()==0 and e:GetOperation() then
			local op=e:GetOperation()
			e:SetOperation(Auxiliary.SetOperationResultAsLabel(op))
		end
		self.register_global_card_effect_table(self,e)
	end
end

--Global Card Effect Table (for Duel.RegisterEffect)
if not global_duel_effect_table_global_check then
	global_duel_effect_table_global_check=true
	global_duel_effect_table={}
	Duel.register_global_duel_effect_table = Duel.RegisterEffect
	Duel.RegisterEffect = function(e,tp)
							if not global_duel_effect_table[tp] then global_duel_effect_table[tp]={} end
							table.insert(global_duel_effect_table[tp],e)
							local s,o=e:GLGetTargetRange()
							if not e:IsHasProperty(EFFECT_FLAG_PLAYER_TARGET) and s==0 and o==0 then
								for i=1,#DUEL_EFFECT_NOP do
									if e:GetCode()==DUEL_EFFECT_NOP[i] then e:SetProperty(e:GetProperty()|EFFECT_FLAG_PLAYER_TARGET) e:SetTargetRange(1,0) end
								end
							end
							return Duel.register_global_duel_effect_table(e,tp)
	end
end