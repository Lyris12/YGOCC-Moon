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

--Commonly used cards
CARD_BLUEEYES_SPIRIT				=59822133
CARD_CYBER_DRAGON					=70095154
CARD_PYRO_CLOCK						=1082946
CARD_INLIGHTENED_PSYCHIC_HELMET		=102400006
CARD_NEBULA_TOKEN					=218201917
CARD_DRAGON_EGG_TOKEN				=20157305
CARD_BLACK_GARDEN					=71645242
CARD_EVIL_DRAGON_ANANTA				=8400623

--Custom Type Tables
Auxiliary.Customs={} --check if card uses custom type, indexing card
Auxiliary.CannotBeEDMatCodes = {}

--overwrite constants
TYPE_EXTRA							=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK

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
local is_type, card_remcounter, duel_remcounter, effect_set_target_range, add_xyz_proc, add_xyz_proc_nlv, duel_overlay, duel_set_lp, duel_select_target, duel_banish, card_check_remove_overlay_card, is_reason, duel_check_tribute, select_tribute,card_sethighlander = 
	Card.IsType, Card.RemoveCounter, Duel.RemoveCounter, Effect.SetTargetRange, Auxiliary.AddXyzProcedure, Auxiliary.AddXyzProcedureLevelFree, Duel.Overlay, Duel.SetLP, Duel.SelectTarget, Duel.Remove, Card.CheckRemoveOverlayCard, Card.IsReason, Duel.CheckTribute, Duel.SelectTribute, Card.SetUniqueOnField

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
dofile("expansions/script/tables.lua")	--Special Tables

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
	if (scard and c:GetType(scard,sumtype,p)&otpe>0)
		or (not scard and c:GetType()&otpe>0) then return true end
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
	local ct=0
	for c in aux.Next(tg) do
		if pos&POS_FACEDOWN~=0 then
			if r&REASON_EFFECT~=0 then
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
			if c:SwitchSpace() then
				ct=ct+duel_banish(c,POS_FACEUP,r)
				cc=cc-c
			end
		end
	end
	return duel_banish(cc,pos,r)+ct
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

--Glitchy's custom auxs and functions
--DO NOT USE THESE UNLESS YOU KNOW WHAT YOU'RE DOING

if not glitchy_effect_table then glitchy_effect_table={} end
if not glitchy_archetype_table then glitchy_archetype_table={} end

GLCATEGORY_ED_DRAW=0x8000
GLCATEGORY_ACTIVATE_LMARKER=0x10000
GLCATEGORY_DEACTIVATE_LMARKER=0x20000

EFFECT_CANNOT_ACTIVATE_LMARKER=8000
EFFECT_CANNOT_DEACTIVATE_LMARKER=8001

EVENT_ACTIVATE_LINK_MARKER=9000
EVENT_DEACTIVATE_LINK_MARKER=9000

Auxiliary.GLSpecialInfos={}
function Auxiliary.GLSetSpecialInfo(e,category,g,ct,p,loc)
	if not g then
		Auxiliary.GLSpecialInfos[e]={category,nil,ct,p,loc}
	else
		Auxiliary.GLSpecialInfos[e]={category,g,ct,0,0}
	end
end

function Effect.SetGlitchyCategory(e,category)
	if not glitchy_effect_table[e] then glitchy_effect_table[e]={0} end
	glitchy_effect_table[1]=category
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
	local egroup2={c:IsHasEffect(EFFECT_CHANGE_SETCODE)}
	for _,ce in ipairs(egroup2) do
		setcode=setcode|ce:GetValue()
	end
	
	if glitchy_archetype_table[c]~=nil and c:GetFlagEffect(777)<=0 then
		setcode=glitchy_archetype_table[c]
	else
		for i=1,#ARCHETYPES do
			if c:IsSetCard(i) then
				table.insert(val,ARCHETYPES[i])
			end
		end
		for i=1,#CUSTOM_ARCHETYPES do
			if c:IsSetCard(i) then
				table.insert(val,CUSTOM_ARCHETYPES[i])
			end
		end
		if #val>0 then
			for i=1,#val do
				setcode=setcode|val[i]
			end
		end
		glitchy_archetype_table[c]=setcode
		c:RegisterFlagEffect(777,0,EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_UNCOPYABLE,1)
	end
	return setcode
end


function Card.GLGetLevel(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	elseif c:IsType(TYPE_LINK) then return c:GetLink()
	elseif c:IsType(TYPE_EVOLUTE) then return c:GetStage()
	elseif c:IsType(TYPE_TIMELEAP) then return c:GetFuture()
	else return c:GetLevel() end
end