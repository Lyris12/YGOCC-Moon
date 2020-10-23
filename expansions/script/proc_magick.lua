--Design and code by Kinny (wait, who?)
--Not yet finalized values
--Custom constants
--Curently using Corona values
TYPE_MAGICK = 0x8000000000000
TYPE_CUSTOM =TYPE_CUSTOM|TYPE_MAGICK
CTYPE_MAGICK			=0x80000
CTYPE_CUSTOM			=CTYPE_CUSTOM|CTYPE_MAGICK
TYPE_EXTRA  =TYPE_EXTRA|TYPE_MAGICK
--TODO
SUMMON_TYPE_MAGICK = 67
EFFECT_CANNOT_BE_MAGICK_MATERIAL = 593
EFFECT_ADDITIONAL_MAGICK_MATERIAL = 594
EFFECT_ADDITIONAL_MAGICK_LOCATION = 595
EFFECT_IS_PERFORMING = 596
EFFECT_MULTI_MAGICK_MATERIAL = 597
REASON_MAGICK = 0x100000000
EVENT_MAGICK = EVENT_CUSTOM+36
EVENT_PERFORM_MAGICK = EVENT_CUSTOM+37
EVENT_ACTIVATE_MAGICK_EFFECT = EVENT_CUSTOM+38

CATEGORY_MAGICK = 0x400000000

CARD_MAGICK_TOKEN = 28916106

--Custom Tables
Auxiliary.Magicks={} --number as index = card, card as index = function() is_synchro
table.insert(aux.CannotBeEDMatCodes,EFFECT_CANNOT_BE_MAGICK_MATERIAL)
Auxiliary.PerformedMagicks={}
Auxiliary.PerformedMagicks[0]={}
Auxiliary.PerformedMagicks[1]={}
Auxiliary.MagickPlayers={}
Auxiliary.RegisteredMagicks={}
Auxiliary.NormalMagicks={}
Auxiliary.MagickListeners={}

function Auxiliary.AddOrigMagickType(c)
	table.insert(Auxiliary.Magicks,c)
	Auxiliary.Customs[c]=true
	Auxiliary.Magicks[c]=true
end
function Auxiliary.AddToPerformed(c,tp)
	Auxiliary.PerformedMagicks[tp][c:GetOriginalCodeRule()] = true
end
function Auxiliary.RemoveFromPerformed(c,tp)
	Auxiliary.PerformedMagicks[tp][c:GetOriginalCodeRule()] = nil
end
function Card.HasBeenPerformed(c,tp)
	return Auxiliary.PerformedMagicks[tp][c:GetOriginalCodeRule()] ~= nil
end

function Auxiliary.AddMagickProcEvent(c,event,f,cost,effect,...)
	if f==nil then
		Auxiliary.AddMagickProcCustom(c,function(e,tp,eg,ep,ev,re,r,rp) return Duel.CheckEvent(event) end,cost,effect,...)
	else
		Auxiliary.AddMagickProcCustom(c,function(e,tp,eg,ep,ev,re,r,rp) return f(Duel.CheckEvent(event,true)) end,cost,effect,...)
	end
end
function Auxiliary.AddMagickProcChain(c,count,cost,effect,...)
	Auxiliary.AddMagickProcCustom(c,function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetCurrentChain()>=count end,cost,effect,...)
end
function Auxiliary.AddMagickProcLocation(c,location,cost,effect,...)
	Auxiliary.AddMagickProcCustom(c,function(e,tp,eg,ep,ev,re,r,rp) return re:GetActivateLocation()==location end,cost,effect,...)
end
function Auxiliary.AddMagickProcMagick(c,cost,effect,...)
	Auxiliary.MagickListeners[c]=true
	Auxiliary.AddMagickProcCustom(c,function(e,tp,eg,ep,ev,re,r,rp) return false end,cost,effect,...)
end
function Auxiliary.AddMagickProcCustom(c,magick_con,magick_cost,magick_effect,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	Auxiliary.AddOrigMagickType(c)
	if magick_con==nil then magick_con=Auxililary.TRUE end
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
				--max=99
			end
			table.insert(list,{t[#t],min,max})
			table.remove(t)
		end
		if #t<2 then break end
	end
	
	local mt=getmetatable(c)
	mt.magick_con = magick_con
	if not magick_cost then mt.magick_cost=Auxiliary.MagickMatCost
	else mt.magick_cost = magick_cost end
	mt.magick_materials = list
	if magick_effect then mt.magick_effect = magick_effect end

	local id=c:GetOriginalCodeRule()
	if Auxiliary.RegisteredMagicks[id]==nil then 
		Auxiliary.RegisteredMagicks[id]=true
		local chk=Effect.GlobalEffect()
		chk:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		chk:SetCode(EVENT_CHAINING)
		chk:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
		chk:SetLabel(id)
		chk:SetOperation(Auxiliary.MagickReg(magick_con))
		Duel.RegisterEffect(chk,0)
		local chk2=chk:Clone()
		Duel.RegisterEffect(chk2,1)
	end
		
	if not magick_global_check then
		magick_global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetCondition(Auxiliary.MagickCondition)
		ge1:SetOperation(Auxiliary.MagickOperation)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		Duel.RegisterEffect(ge2,1)

		local ge3=Effect.GlobalEffect()
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge3:SetOperation(function() Auxiliary.PerformedMagicks[0]={} Auxiliary.PerformedMagicks[1]={} end)
		Duel.RegisterEffect(ge3,0)  
	end
end
function Auxiliary.MagickCondition(e,tp,eg,ep,ev,re,r,rp)
	return ev==1
end
function Auxiliary.MagickRegCon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsCanBePerformed(tp) then return false end
	local te=c:IsHasEffect(EFFECT_ADDITIONAL_MAGICK_LOCATION)
	if te then return c:IsLocation(LOCATION_HAND+LOCATION_EXTRA+te:GetRange())
	else return c:IsLocation(LOCATION_HAND+LOCATION_EXTRA) end
end
function Auxiliary.MagickReg(magick_con)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if rp==tp and magick_con(e,tp,eg,ep,ev,re,r,rp) then
			local mark=Effect.CreateEffect(re:GetHandler())
			mark:SetType(EFFECT_TYPE_SINGLE)
			mark:SetCode(EFFECT_IS_PERFORMING)
			mark:SetValue(e:GetLabel())
			mark:SetReset(RESET_EVENT+RESET_CHAIN)
			re:GetHandler():RegisterEffect(mark,true)
		end
	end
end
function Auxiliary.MagickOperation(e,tp,eg,ep,ev,re,r,rp)
	local sg=Auxiliary.GetAvaliableMagick(e,tp)
	while #sg>0 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=sg:SelectUnselect(Group.CreateGroup(),tp,true,true,1,1)
		if not sc then return false end
		local res=false
		while sc and not res do
			res=sc.magick_cost(e,tp,eg,ep,ev,re,r,rp,1,sc)
			if res then
				if sc:IsType(TYPE_MONSTER) then Duel.SpecialSummon(sc,SUMMON_TYPE_MAGICK,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
				else Duel.SSet(tp,sc) end
				if sc:IsFacedown() then Duel.ConfirmCards(1-tp,sc) end
				--TODO: Field Spell handling
				Auxiliary.AddToPerformed(sc,tp)
				sc:CompleteProcedure()
				local performers = Duel.GetMatchingGroup(Card.IsPerforming,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,nil,sc)
	
				if type(sc.magick_effect)=='userdata' then
					local token=Duel.CreateToken(tp,CARD_MAGICK_TOKEN)
					Auxiliary.PerformMagickEffect(sc,token,sc.magick_effect,e,tp,eg,ep,ev,re,r,rp)
				elseif type(sc.magick_effect)=='table' then
					local token=Duel.CreateToken(tp,CARD_MAGICK_TOKEN)
					for _,te in ipairs(sc.magick_effect) do
						Auxiliary.PerformMagickEffect(sc,token,te,e,tp,eg,ep,ev,re,r,rp)
					end
				end
				
				local pc=performers:GetFirst()
				while pc do
					Duel.RaiseSingleEvent(pc,EVENT_PERFORM_MAGICK,e,REASON_RULE,tp,tp,0)
					pc=performers:GetNext()
				end
				Duel.RaiseEvent(sc,EVENT_MAGICK,e,REASON_RULE,tp,tp,1)
				return true
			else sc=nil end
		end
	end
end
function Auxiliary.PerformMagickEffect(sc,token,effect,e,tp,eg,ep,ev,re,r,rp)
	if (effect:GetCondition() and not effect:GetCondition(e,tp,eg,ep,ev,re,r,rp)) then return false end
	local magick_effect=effect:Clone()
	magick_effect:SetProperty(EFFECT_FLAG_CLIENT_HINT+effect:GetProperty())
	magick_effect:SetRange(LOCATION_EXTRA)
	magick_effect:SetType(EFFECT_TYPE_FIELD+effect:GetType())
	magick_effect:SetCode(EVENT_MAGICK)
	if effect:GetTarget() then magick_effect:SetTarget(Auxiliary.CreateMagickTarget(effect:GetTarget())) end
	magick_effect:SetOperation(Auxiliary.CreateMagickOperation(effect:GetOperation()))
	
	local cleanup=Effect.CreateEffect(token)
	cleanup:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	cleanup:SetCode(EVENT_CHAIN_END)
	cleanup:SetRange(LOCATION_EXTRA)
	cleanup:SetLabel(0)
	cleanup:SetOperation(Auxiliary.CleanupOperation)
	token:SetMaterial(sc:GetMaterial())
	token:RegisterEffect(magick_effect,true)
	token:RegisterEffect(cleanup,true)
	Duel.SendtoExtraP(token,tp,REASON_RULE)
end
function Auxiliary.CleanupOperation(e)
	if e:GetLabel()>0 then
		if e:GetHandler() then Duel.Exile(e:GetHandler(),REASON_RULE) end
		e:Reset()
	else
		e:SetLabel(1)
	end
end
function Auxiliary.GetAvaliableMagick(e,tp)
	local mats=Auxiliary.GetMagickMaterial(tp)
	local g1=Duel.GetMatchingGroup(Auxiliary.MagickSummonFilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil,e,tp,mats)
	local g2=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,EFFECT_ADDITIONAL_MAGICK_LOCATION):Filter(Auxiliary.MagickSummonFilter,nil,e,tp,mats)
	g1:Merge(g2)
	return g1
end
function Card.IsCanBePerformed(c,tp)
	return not c:HasBeenPerformed(tp) --TODO
end
function Auxiliary.CreateMagickTarget(f)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chk==0 then return f(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
		f(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local c=e:GetHandler()
		if c then
			c:ReleaseEffectRelation(e)
			--Duel.Exile(c,REASON_RULE)
		end
	end
end
function Auxiliary.CreateMagickOperation(f)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Exile(e:GetHandler(),REASON_RULE)
		f(e,tp,eg,ep,ev,re,r,rp)
		e:Reset()
	end
end
function Card.IsPerforming(c,mc)
	if c:IsHasEffect(EFFECT_IS_PERFORMING) then
		local tef={c:IsHasEffect(EFFECT_IS_PERFORMING)}
		for _,te in ipairs(tef) do
			if te:GetValue()==mc:GetOriginalCodeRule() then return true end
		end
	end
end
function Auxiliary.GetMagickMaterial(tp,c)
	if c then return Duel.GetMatchingGroup(Auxiliary.MagickMaterialFilter,tp,LOCATION_ONFIELD,0,nil,c:GetOriginalCodeRule())
	else return Duel.GetMatchingGroup(Auxiliary.MagickMaterialFilter,tp,LOCATION_ONFIELD,0,nil)
	end
end
function Auxiliary.MagickMaterialFilter(c,sumc)
	return c:IsCanBeMagickMaterial(sumc)
end
function Card.IsCanBeMagickMaterial(c,sumc)
	return not c:IsHasEffect(EFFECT_CANNOT_BE_MAGICK_MATERIAL)
end
function Card.HasPerformer(c,tp)
	return Duel.IsExistingMatchingCard(Card.IsPerforming,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c)
end
function Auxiliary.MagickSummonFilter(c,e,tp,matg)
	return c:IsType(TYPE_MAGICK)
		and (c:HasPerformer(tp) or (Auxiliary.MagickListeners[c]~=nil and Duel.CheckEvent(EVENT_MAGICK)))
		and c:IsCanBePerformed(tp)
		and ((c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_MAGICK,tp,false,false))
		or c:IsSSetable())
		and matg:IsExists(Auxiliary.MagickRecursiveFilter,1,nil,tp,Group.CreateGroup(),matg,c,0,table.unpack(c.magick_materials))
end
function Auxiliary.MagickLPCost(val)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c)
		if chk==0 then return Duel.CheckLPCost(tp,val) end
		c:SetMaterial(Group.CreateGroup())
		Duel.PayLPCost(tp,val)
		return true
	end
end
function Auxiliary.MagickMatCost(e,tp,eg,ep,ev,re,r,rp,chk,c)
	if chk==0 then return Auxiliary.GetMagickMaterial(tp,c):IsExists(Auxiliary.MagickRecursiveFilter,1,nil,tp,Group.CreateGroup(),matg,c,0,table.unpack(c.magick_materials)) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local mg=Auxiliary.SelectMagickMaterial(c,e,tp)
	if #mg>0 then
		c:SetMaterial(mg)
		Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_MAGICK)
		return true
	else return false end
end
function Auxiliary.MagickRecursiveFilter(c,tp,sg,mg,bc,ct,...)
	sg:AddCard(c)
	ct=ct+1
	local funs,max,chk={...},0
	for i=1,#funs do
		max=max+funs[i][3]
		if funs[i][1](c,bc,mg) then
			chk=true
		end
	end
	if max>99 then max=99 end
	local res=chk and (Auxiliary.MagickCheckGoal(tp,sg,bc,ct,...)
		or (ct<max and mg:IsExists(Auxiliary.MagickRecursiveFilter,1,sg,tp,sg,mg,bc,ct,...)))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.MagickCheckGoal(tp,sg,bc,ct,...)
	local funs,min={...},0
	for i=1,#funs do
		if not sg:IsExists(funs[i][1],funs[i][2],nil,bc,sg) then return false end
		min=min+funs[i][2]
	end
	if sg:GetMagickMaterialCount(bc,ct)<min then return false end
	if bc:IsType(TYPE_MONSTER) then
		if bc:IsLocation(LOCATION_EXTRA) then return Duel.GetLocationCountFromEx(tp,tp,sg,bc)>0
		else return Duel.GetLocationCount(tp,LOCATION_MZONE)>(0-#sg:Filter(Card.IsLocation,nil,LOCATION_MZONE)) end
	elseif not bc:IsType(TYPE_FIELD) then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>(0-#sg:Filter(Card.IsLocation,nil,LOCATION_SZONE))
	else return true end
end
function Group.GetMagickMaterialCount(g,sc,ct)
	local _r = ct
	local c=g:GetFirst()
	while c do
		if c:IsHasEffect(EFFECT_MULTI_MAGICK_MATERIAL) then
			local tef={c:IsHasEffect(EFFECT_MULTI_MAGICK_MATERIAL)}
			for _,te in ipairs(tef) do
				local tev=te:GetValue()
				if type(tev)=='function' then _r = _r+tev(g,sc,ct)-1
				elseif type(tev)=='number' then _r = _r+tev-1 end
			end
		end
		c=g:GetNext()
	end
	return _r
end
function Auxiliary.SelectMagickMaterial(c,e,tp)
	local funs,min,max=c.magick_materials,0,0
	for i=1,#funs do min=min+funs[i][2] max=max+funs[i][3] end
	if max>99 then max=99 end
	local mg=Auxiliary.GetMagickMaterial(tp,c)
	local mg2=Group.CreateGroup() --TODO
	if #mg2>0 then mg:Merge(mg2) end
	local bg=Group.CreateGroup()
	--TODO
	if #bg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
		bg:Select(tp,#bg,#bg,nil)
	end
	local sg=Group.CreateGroup()
	sg:Merge(bg)
	local ct=sg:GetMagickMaterialCount(c,0)
	local finish=false
	while not (ct>=max) do
		finish=Auxiliary.MagickCheckGoal(tp,sg,c,#sg,table.unpack(funs))
		local cg=mg:Filter(Auxiliary.MagickRecursiveFilter,sg,tp,sg,mg,c,#sg,table.unpack(funs))
		if #cg==0 then break end
		local cancel=not finish
		--Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		Duel.Hint(HINT_NUMBER,tp,ct)
		local tc=cg:SelectUnselect(sg,tp,finish,cancel,min,max)
		if tc then
			if not bg:IsContains(tc) then
				if not sg:IsContains(tc) then
					sg:AddCard(tc)
					ct=sg:GetMagickMaterialCount(c,#sg)
					if (ct>=min) then finish=true end
				else
					sg:RemoveCard(tc)
					ct=sg:GetMagickMaterialCount(c,#sg)
				end
			elseif #bg>0 and ct<=#bg then
				return Group.CreateGroup()
			end
		elseif finish or ct<=#bg then break end
	end
	return sg
end
function Auxiliary.EnableNormalMagick(c)
	Auxiliary.NormalMagicks[c]=true
	if not normal_magick_global then
		normal_magick_global=true
		local e0=Effect.GlobalEffect()
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e0:SetCode(EVENT_PREDRAW)
		e0:SetCountLimit(1,TYPE_MAGICK+EFFECT_COUNT_CODE_DUEL)
		e0:SetOperation(Auxiliary.NormalMagickOverwrite)
		Duel.RegisterEffect(e0,0)
	end
end
function Auxiliary.NormalMagickOverwrite()
	local g=Duel.GetMatchingGroup(function(c) return Auxiliary.NormalMagicks[c]~=nil end,0,0x5f,0x5f,nil)
	g:ForEach(function(c) pcall(Card.SetCardData,c,CARDDATA_TYPE,TYPE_MONSTER+TYPE_NORMAL) end)
	Duel.ShuffleDeck(0)
	Duel.ShuffleDeck(1)
end

--overwrite functions
local get_type, get_orig_type, get_prev_type_field = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Magicks[c] then
		tpe=tpe|TYPE_MAGICK
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Magicks[c] then
		tpe=tpe|TYPE_MAGICK
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Magicks[c] then
		tpe=tpe|TYPE_MAGICK
	end
	return tpe
end