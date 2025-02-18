--New EFFECTS
EFFECT_CANNOT_ACTIVATE_LMARKER=8000
EFFECT_CANNOT_DEACTIVATE_LMARKER=8001
EFFECT_PRE_LOCATION=8002
EFFECT_NO_ARCHETYPE=8003
EFFECT_GLITCHY_EXTRA_LINK_MATERIAL	    		= 8005
EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG				= 8006
EFFECT_GLITCHY_HACK_CODE 						= 8007
EFFECT_NAME_DECLARED							= 8008
EFFECT_GLITCHY_CANNOT_DISABLE					= 8009
EFFECT_GLITCHY_FUSION_SUBSTITUTE 				= 8010
EFFECT_GLITCHY_CANNOT_CHANGE_ATK				= 8011
EFFECT_GLITCHY_ADD_CUSTOM_SETCODE				= 8012
EFFECT_GLITCHY_ADD_ORIGINAL_CUSTOM_SETCODE		= 8013
EFFECT_GLITCHY_PREVIOUS_CUSTOM_SETCODE			= 8014
EFFECT_GLITCHY_ADD_FUSION_CUSTOM_SETCODE		= 8015
EFFECT_GLITCHY_ADD_LINK_CUSTOM_SETCODE			= 8016

FLAG_UNCOUNTED_NORMAL_SUMMON			= 8000
FLAG_UNCOUNTED_NORMAL_SET				= 8001

EFFECT_BECOME_HOPT=99977755
EFFECT_SYNCHRO_MATERIAL_EXTRA=26134837
EFFECT_SYNCHRO_MATERIAL_MULTIPLE=26134838
EFFECT_REVERSE_WHEN_IF=48928491

UNIVERSAL_GLITCHY_TOKEN = 1231

--TABLES
function Auxiliary.FindInTable(tab,a,...)
	local extras={...}
	if a then
		table.insert(extras,a)
	end
	
	for _,param in ipairs(extras) do
		for pos,elem in ipairs(tab) do
			if elem==param then
				return pos
			end
		end
	end
	
	return false
end
function Auxiliary.ClearTable(tab)
	local size=#tab
	if size>0 then
		for k=1,size do
			table.remove(tab)
		end
	end
end
function Auxiliary.ClearTableRecursive(tab)
	for k,v in pairs(tab) do
		if type(v)=="table" then
			aux.ClearTableRecursive(v)
		end
		tab[k]=nil
	end
end

--SORTING
function Effect.IsInitialSingle(e)
	return e:IsHasType(EFFECT_TYPE_SINGLE) and e:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE) and e:IsHasProperty(EFFECT_FLAG_INITIAL)
end
function Auxiliary.EffectSort(e1,e2)
	local isSingle1 = e1:IsInitialSingle() and 1 or 0
	local isSingle2 = e2:IsInitialSingle() and 1 or 0
	if isSingle1 ~= isSingle2 then
		return isSingle1 > isSingle2
	end
	return e1:GetFieldID() < e2:GetFieldID()
end

--DAMAGE and LP CHANGES
EFFECT_CHANGE_RECOVER							= 1508
EFFECT_GLITCHY_ALSO_EFFECT_DAMAGE				= 100000300		--[[If a player takes damage, the damage is also inflicted to the opponent (the original damage the player would have taken).
																Made for "Dynastygian Sabotage - Weapons Jam"]]
EFFECT_MODIFY_LP_CHANGE							= 100000362		--[[Modifies the amount of LP changed by Duel.SetLP. Made for "Power Vacuum Blade"]]

EVENT_LP_CHANGE		= EVENT_CUSTOM+68007397

LP_REASON_UPDATE	= 0x1
LP_REASON_BECOME	= 0x2

local duel_recover, duel_damage, _SetLP = Duel.Recover, Duel.Damage, Duel.SetLP

Duel.Recover = function(p,v,r,step,...)
	if Duel.IsPlayerAffectedByEffect(p,EFFECT_CHANGE_RECOVER) then
		for _,e in ipairs({Duel.IsPlayerAffectedByEffect(p,EFFECT_CHANGE_RECOVER)}) do
			local val=e:GetValue()
			if val and (aux.GetValueType(val)=="number" or val(e,r,v)) then
				if aux.GetValueType(val)~="number" then
					v=val(e,r,v)
				end
			end
		end
	end
	local alsodam=Duel.IsPlayerAffectedByEffect(p,EFFECT_REVERSE_RECOVER) and Duel.IsPlayerAffectedByEffect(p,EFFECT_GLITCHY_ALSO_EFFECT_DAMAGE)
	local tempdam=step
	if alsodam then
		step=true
	end
	local rec=duel_recover(p,v,r,step,...)
	if rec==0 and alsodam then
		duel_damage(1-p,v,r,true,...)
		if not tempdam then
			Duel.RDComplete()
		end
	end
	return rec
end
Duel.Damage = function(p,v,r,step,...)
	if Duel.IsPlayerAffectedByEffect(p,EFFECT_REVERSE_DAMAGE) and Duel.IsPlayerAffectedByEffect(p,EFFECT_CHANGE_RECOVER) then
		for _,e in ipairs({Duel.IsPlayerAffectedByEffect(p,EFFECT_CHANGE_RECOVER)}) do
			local val=e:GetValue()
			if val and (aux.GetValueType(val)=="number" or val(e,r|REASON_RDAMAGE,v)) then
				if aux.GetValueType(val)~="number" then
					v=val(e,r|REASON_RDAMAGE,v)
				end
			end
		end
	end
	local alsodam=Duel.IsPlayerAffectedByEffect(p,EFFECT_GLITCHY_ALSO_EFFECT_DAMAGE)
	local tempdam=step
	if alsodam then
		step=true
	end
	local dam=duel_damage(p,v,r,step,...)
	if dam>0 and alsodam then
		duel_damage(1-p,v,r,true,...)
		if not tempdam then
			Duel.RDComplete()
		end
	end
	return dam
end
Duel.SetLP = function(p,val,r,rp)
	if not r then r=LP_REASON_UPDATE end
	if not rp then rp=current_triggering_player end
	local eset={Duel.IsPlayerAffectedByEffect(p,EFFECT_MODIFY_LP_CHANGE)}
	for _,e in ipairs(eset) do
		local chk=e:Evaluate(p,val,r,rp,0)
		if chk then
			val=e:Evaluate(p,val,r,rp,1)
			break
		end
	end
	local prev=Duel.GetLP(p)
	local res = _SetLP(p,val)
	if not rule and Duel.GetLP(p)~=prev then
		Duel.RaiseEvent(self_reference_effect:GetHandler(),EVENT_LP_CHANGE,nil,REASON_EFFECT,rp,p,Duel.GetLP(p)-prev)
	end
	return res
end

--EFFECTS THAT CAN BE ACTIVATED BY AFFECTING THE CARD USED AS COST, EVEN WHEN THERE ARE NO OTHER VALID TARGETS
aux.LocationAfterCostEffects = {
[EFFECT_CANNOT_SPECIAL_SUMMON]=true;
[EFFECT_CANNOT_SSET]=true;
[EFFECT_CANNOT_TO_DECK]=true;
}

local _IsLocation, _GetLocation = Card.IsLocation, Card.GetLocation

function Card.SetLocationAfterCost(c,loc)
	local s=getmetatable(c)
	s.LocationAfterCost=loc
end
function Card.IsLocationAfterCost(c,loc)
	if not c.LocationAfterCost then return _IsLocation(c,loc) end
	local s=getmetatable(c)
	return s.LocationAfterCost&loc~=0
end
function Card.GetLocationAfterCost(c)
	local s=getmetatable(c)
	if not s.LocationAfterCost then return _GetLocation(c) end
	return s.LocationAfterCost
end

Card.IsLocation = function(c,loc)
	if self_reference_effect and c.LocationAfterCost then
		local code=self_reference_effect:GetCode()
		if aux.LocationAfterCostEffects[code]==true then
			return c:IsLocationAfterCost(loc)
		end
	end
	return _IsLocation(c,loc)
end
Card.GetLocation = function(c)
	local locs=_GetLocation(c)
	if self_reference_effect and c.LocationAfterCost then
		local code=self_reference_effect:GetCode()
		if aux.LocationAfterCostEffects[code]==true then
			locs=locs|c:GetLocationAfterCost()
		end
	end
	return locs
end
-------------------------------------------------------------------------------------
-------------------------------DISCARD EFFECTS FIX-------------------------------------
local _DiscardHand, _SendtoGrave = Duel.DiscardHand, Duel.SendtoGrave

function Auxiliary.CanBeDiscarded(f,r)
	local reason=r&(~REASON_DISCARD)
	return	function(c,...)
				return c:IsDiscardable(reason) and (not f or f(c,...))
			end
end

Duel.DiscardHand = function(p,f,min,max,r,exc,...)
	return _DiscardHand(p,aux.CanBeDiscarded(f,r),min,max,r,exc,...)
end
Duel.SendtoGrave = function(tg,reason,...)
	if reason&REASON_DISCARD>0 then
		if aux.GetValueType(tg)=="Card" then
			tg=Group.FromCards(tg)
		end
		local g=tg:Clone()
		g:Remove(aux.NOT(aux.CanBeDiscarded(nil,reason)),nil)
		return _SendtoGrave(g,reason,...)
	else
		return _SendtoGrave(tg,reason,...)
	end
end

-------------------------------------------------------------------------------------
-------------------------------PROXY EFFECTS FIX-------------------------------------
Auxiliary.EffectBeingApplied = nil
Auxiliary.ProxyEffect = nil
Auxiliary.SwapTargetAndMatchingCardSelection = false


function Duel.SetProxyEffect(e,te)
	Auxiliary.ProxyEffect = e
	Auxiliary.EffectBeingApplied = te
end
function Duel.ResetProxyEffect()
	Auxiliary.ProxyEffect = nil
	Auxiliary.EffectBeingApplied = nil
end

local _SetLabel, _SetLabelObject, _GetLabel, _GetLabelObject = --, _SelectTarget, _GetFirstTarget, _GetChainInfo =
Effect.SetLabel, Effect.SetLabelObject, Effect.GetLabel, Effect.GetLabelObject --, Duel.SelectTarget, Duel.GetFirstTarget, Duel.GetChainInfo

Effect.SetLabel = function(e,l1,...)
	if aux.GetValueType(aux.EffectBeingApplied)=="Effect" and aux.GetValueType(aux.ProxyEffect)=="Effect" and aux.ProxyEffect==e then
		return _SetLabel(aux.EffectBeingApplied,l1,...)
	else
		return _SetLabel(e,l1,...)
	end
end
Effect.SetLabelObject = function(e,obj)
	if aux.GetValueType(aux.EffectBeingApplied)=="Effect" and aux.GetValueType(aux.ProxyEffect)=="Effect" and aux.ProxyEffect==e then
		return _SetLabelObject(aux.EffectBeingApplied,obj)
	else
		return _SetLabelObject(e,obj)
	end
end
Effect.GetLabel = function(e)
	if aux.GetValueType(aux.EffectBeingApplied)=="Effect" and aux.GetValueType(aux.ProxyEffect)=="Effect" and aux.ProxyEffect==e then
		return _GetLabel(aux.EffectBeingApplied)
	else
		return _GetLabel(e)
	end
end
Effect.GetLabelObject = function(e)
	if aux.GetValueType(aux.EffectBeingApplied)=="Effect" and aux.GetValueType(aux.ProxyEffect)=="Effect" and aux.ProxyEffect==e then
		return _GetLabelObject(aux.EffectBeingApplied)
	else
		return _GetLabelObject(e)
	end
end

-- Duel.SelectTarget = function(p,f,pov,loc1,loc2,min,max,exc,...)
	-- if not aux.SwapTargetAndMatchingCardSelection then
		-- return _SelectTarget(p,f,pov,loc1,loc2,min,max,exc,...)
	-- else
		-- local g=Duel.GetMatchingGroup(f,pov,loc1,loc2,exc,...):Filter(Card.IsCanBeEffectTarget,nil,aux.ProxyEffect)
		-- local res=g:Select(p,min,max,nil)
		-- Duel.HintSelection(res)
		-- for etc in aux.Next(res) do
			-- etc:CreateEffectRelation(aux.ProxyEffect)
			-- Duel.RaiseSingleEvent(etc,EVENT_BECOME_TARGET,aux.ProxyEffect,REASON_EFFECT,aux.ProxyEffect:GetHandlerPlayer(),0,0)
		-- end
		-- Duel.RaiseEvent(res,EVENT_BECOME_TARGET,aux.ProxyEffect,REASON_EFFECT,aux.ProxyEffect:GetHandlerPlayer(),0,0)
		-- aux.PseudoTargetGroup=res
		-- aux.PseudoTargetGroup:KeepAlive()
		-- return res
	-- end
-- end

-- Duel.GetFirstTarget = function()
	-- if aux.SwapTargetAndMatchingCardSelection then
		-- local tc=aux.PseudoTargetGroup:Filter(Card.IsRelateToEffect,nil,aux.ProxyEffect):GetFirst()
		-- aux.PseudoTargetGroup:DeleteGroup()
		-- return tc
	-- else
		-- return _GetFirstTarget()
	-- end
-- end

-- Duel.GetChainInfo = function(ch,...)
	-- if aux.SwapTargetAndMatchingCardSelection and aux.GetValueType(aux.ProxyEffect)=="Effect" then
		-- local res={}
		-- local x={...}
		-- for _,info in ipairs(x) do
			-- if info~=CHAININFO_TARGET_CARDS then
				-- table.insert(res,_GetChainInfo(ch,info))
			-- else
				-- local g=aux.PseudoTargetGroup:Filter(Card.IsRelateToEffect,nil,aux.ProxyEffect)
				-- aux.PseudoTargetGroup:DeleteGroup()
				-- table.insert(res,g)
			-- end
		-- end
		-- return table.unpack(res)
	-- else
		-- return _GetChainInfo(ch,...)
	-- end
-- end

-----------------------------------------------------------------------------------------------------------
-------------------------------PREVENT COUNT LIMIT OVERLAP-------------------------------------------------
aux.EffectCountLimitFlagTable = {}

local _SetCountLimit = Effect.SetCountLimit

Effect.SetCountLimit = function(e,ct,...)
	local x={...}
	local flag = #x>0 and x[1] or 0
	if type(flag)=="table" or #x>1 then
		local id=type(flag)=="table" and flag[1] or flag
		local mod=type(flag)=="table" and flag[2] or 0
		local tempflag = #x>1 and x[2] or 0
		flag=id+mod*100+tempflag
	end
	local owner
	local etype=e:GetType()
	if etype&EFFECT_TYPE_XMATERIAL>0 then
		e:SetType(0)
		owner=e:GetOwner()
		e:SetType(etype)
	else
		owner=e:GetOwner()
	end
	if owner:IsStatus(STATUS_INITIALIZING) and flag>EFFECT_COUNT_CODE_SINGLE then
		local code=owner:GetOriginalCodeRule()
		local pureflag=flag
		local extraflags=0
		local flagtable={EFFECT_COUNT_CODE_OATH,EFFECT_COUNT_CODE_DUEL,EFFECT_COUNT_CODE_CHAIN}
		for _,f in ipairs(flagtable) do
			if flag&f>0 then
				pureflag = pureflag&(~f)
				extraflags = extraflags|f
			end
		end
		
		if not aux.EffectCountLimitFlagTable[pureflag] then
			aux.EffectCountLimitFlagTable[pureflag]=code
			
		elseif aux.EffectCountLimitFlagTable[pureflag]~=code then
			while aux.EffectCountLimitFlagTable[pureflag] do
				pureflag=pureflag+1
				if pureflag>MAX_ID then
					pureflag=MIN_ID
				end
			end
			aux.EffectCountLimitFlagTable[pureflag]=code
		end
		
		--Debug.Message(tostring(code)..": "..tostring(pureflag|extraflags))
		return _SetCountLimit(e,ct,pureflag|extraflags)
	
	else
		return _SetCountLimit(e,ct,...)
	end
end

-------------------------------------------------------------------------------------
-------------------------------CUSTOM ARCHETYPES-------------------------------------
function Auxiliary.IsCustomSetCardTemplate(effect_code,c,hex,...)
	if not c:IsHasEffect(effect_code) then return false end
	
	local setcodes={...}
	if hex then
		table.insert(setcodes,1,hex)
	end
	
	local ct=#setcodes
	
	local egroup={c:IsHasEffect(effect_code)}
	for _,e in ipairs(egroup) do
		if e and e.GetValue and aux.GetValueType(e)=="Effect" then
			local value=e:GetValue()
			if value then
				local settype0,setsubtype0 = value&0xfff, value%0xf000
				for i=1,ct do
					local setc=setcodes[i]
					local settype1,setsubtype1 = setc&0xfff, setc%0xf000
					if settype1==settype0 and (setsubtype1==0 or setsubtype1==setsubtype0) then
						return true
					end
				end
			end
		end
	end
	
	return false
end
function Card.IsCustomSetCard(c,hex,...)
	return aux.IsCustomSetCardTemplate(EFFECT_GLITCHY_ADD_CUSTOM_SETCODE,c,hex,...)
end
function Card.IsOriginalCustomSetCard(c,hex,...)
	return aux.IsCustomSetCardTemplate(EFFECT_GLITCHY_ADD_ORIGINAL_CUSTOM_SETCODE,c,hex,...)
end
function Card.IsPreviousCustomSetCard(c,hex,...)
	return aux.IsCustomSetCardTemplate(EFFECT_GLITCHY_PREVIOUS_CUSTOM_SETCODE,c,hex,...)
end
function Card.IsFusionCustomSetCard(c,hex,...)
	return aux.IsCustomSetCardTemplate(EFFECT_GLITCHY_ADD_FUSION_CUSTOM_SETCODE,c,hex,...)
end
function Card.IsLinkCustomSetCard(c,hex,...)
	return aux.IsCustomSetCardTemplate(EFFECT_GLITCHY_ADD_LINK_CUSTOM_SETCODE,c,hex,...)
end

function Card.GetCustomSetCard(c)
	if not c:IsHasEffect(EFFECT_GLITCHY_ADD_CUSTOM_SETCODE) then return false end
	
	local setcodes={}
	local egroup={c:IsHasEffect(EFFECT_GLITCHY_ADD_CUSTOM_SETCODE)}
	for _,e in ipairs(egroup) do
		if e and e.GetValue and aux.GetValueType(e)=="Effect" then
			local value=e:GetValue()
			if value then
				table.insert(setcodes,value)
			end
		end
	end
	
	if #setcodes>0 then
		return table.unpack(setcodes)
	else
		return 0
	end
end

aux.RegisteredCustomSetCards = {}
function Duel.RegisterCustomSetCard(c,id1,id2,hex,...)
	local setcodes={}
	if hex then
		table.insert(setcodes,1,hex)
	end
	
	for i,setcode in ipairs(setcodes) do
		if c then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_GLITCHY_ADD_ORIGINAL_CUSTOM_SETCODE)
			e1:SetValue(setcode)
			c:RegisterEffect(e1,true)
		end
		
		if #aux.RegisteredCustomSetCards==0 or not aux.FindInTable(aux.RegisteredCustomSetCards,setcode) then
			table.insert(aux.RegisteredCustomSetCards,setcode)
			local e2=Effect.GlobalEffect()
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_IGNORE_RANGE)
			e2:SetCode(EFFECT_GLITCHY_ADD_CUSTOM_SETCODE)
			e2:SetTarget(	function(e,card)
								local codes={card:GetCode()}
								for i,code in ipairs(codes) do
									if code>=id1 and code<=id2 then
										return true
									end
								end
								return false
							end
						)
			e2:SetValue(setcode)
			Duel.RegisterEffect(e2,0)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_GLITCHY_ADD_FUSION_CUSTOM_SETCODE)
			e3:SetTarget(	function(e,card)
								local codes={card:GetFusionCode()}
								for i,code in ipairs(codes) do
									if code>=id1 and code<=id2 then
										return true
									end
								end
								return false
							end
						 )
			Duel.RegisterEffect(e3,0)
			local e4=e2:Clone()
			e4:SetCode(EFFECT_GLITCHY_ADD_LINK_CUSTOM_SETCODE)
			e4:SetTarget(	function(e,card)
								local codes={card:GetLinkCode()}
								for i,code in ipairs(codes) do
									if code>=id1 and code<=id2 then
										return true
									end
								end
								return false
							end
						 )
			Duel.RegisterEffect(e4,0)
			
			local e5=Effect.GlobalEffect()
			e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE)
			e5:SetCode(EVENT_LEAVE_FIELD_P)
			e5:SetOperation(aux.RegisterPreviousCustomSetCard)
			Duel.RegisterEffect(e5,0)
		end
	end

end
function Auxiliary.RegisterPreviousCustomSetCard(e,tp,eg,ep,ev,re,r,rp)
	for c in aux.Next(eg) do
		local egroup={c:IsHasEffect(EFFECT_GLITCHY_ADD_CUSTOM_SETCODE)}
		for _,e in ipairs(egroup) do
			if e and e.GetValue and aux.GetValueType(e)=="Effect" then
				local value=e:GetValue()
				if value then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SET_AVAILABLE)
					e1:SetCode(EFFECT_GLITCHY_PREVIOUS_CUSTOM_SETCODE)
					e1:SetValue(value)
					e1:SetReset(RESET_EVENT|RESET_TOFIELD)
					c:RegisterEffect(e1,true)
				end
			end
		end
	end
end
---------------------------------------------------------------------------------
-------------------------------DELAYED EVENT-------------------------------------

local _rmde = Auxiliary.RegisterMergedDelayedEvent

Auxiliary.RegisterMergedDelayedEvent = function(c,code,event,g)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	return _rmde(c,code,event,g)
end

EVENT_COUNTER_ID = 0
aux.EventCounter = {}
EVENT_ID = 0
MERGED_ID = 1
aux.MustUpdateEventID = {}
aux.MergedDelayedEventInfotable = {}

--[[Raises custom event with a compound Event Group containing all cards that raised the specified event at different times during a Chain.
Handles correct interactions with Trigger Effects whose resolution depends on the specific card that raised the event (eg. Union Hangar)
c 								= The card that needs to check for the event
code 							= The code of the custom event that will be raised. A progressive ID might be needed in some cases, for example when check_if_already_in_location is set (see
								Dismay from the Dark)
event							= The event that must be checked. You can specify multiple events by passing a table
f								= Filter for the cards that are involved in the "event(s)"
flag							= Specify the id for the flag effect that is used internally by this function
range							= If specified, these checks will only be performed while "c" is in the "range". Otherwise, the checks are always performed during the Duel
								 (the latter case applies for private-location Trigger Effects)
evgcheck						= You can specify an additional check for the compound Event Group before raising the custom event. If this check is not passed, the custom event is not raised.
check_if_already_in_location	= If a location is specified, the respective AddThisCardInLocationAlreadyCheck will be performed
operation						= You can invoke a function before raising the custom event. The function must return the Event Value of the custom event.
simult_check					= You can specify an id for an additional flag that separately keeps track of cards that were simultaneously involved in an instance of the specified event.
forced							= Raises the custom event even if the final group is empty (required for mandatory Trigger Effects)
customevgop						= Allows to call a custom function when the cards involved in the local Event Groups are receiving the flag
								(useful for effects that must keep track of certain properties the cards had in a previous location, see BRAIN Boot Sector)
]]
function Auxiliary.RegisterMergedDelayedEventGlitchy(c,code,event,f,flag,range,evgcheck,check_if_already_in_location,operation,simult_check,forced,customevgop)
	if type(event)~="table" then event={event} end
	if not f then f=aux.TRUE end
	if not flag then flag=c:GetOriginalCode() end
	local se
	if check_if_already_in_location then
		if check_if_already_in_location&LOCATION_GRAVE>0 then
			se=aux.AddThisCardInGraveAlreadyCheck(c)
		elseif check_if_already_in_location&LOCATION_FZONE>0 then
			se=aux.AddThisCardInFZoneAlreadyCheck(c)
		elseif check_if_already_in_location&LOCATION_MZONE>0 then
			se=aux.AddThisCardInMZoneAlreadyCheck(c)
		elseif check_if_already_in_location&LOCATION_SZONE>0 then
			se=aux.AddThisCardInSZoneAlreadyCheck(c)
		elseif check_if_already_in_location&LOCATION_PZONE>0 then
			se=aux.AddThisCardInPZoneAlreadyCheck(c)
		end
	end
	
	local g=Group.CreateGroup()
	g:KeepAlive()
	
	if forced then
		EVENT_COUNTER_ID = EVENT_COUNTER_ID + 1
		aux.EventCounter[EVENT_COUNTER_ID]=0
	end
	
	local updateflag=false
	local private_range=not range and 1 or range&LOCATIONS_PRIVATE
	local public_range=not range and 0 or range&(~private_range)
	
	if private_range>0 then
		updateflag=true
		local mt=getmetatable(c)
		local ge1
		for _,ev in ipairs(event) do
			if mt[ev]~=true then
				mt[ev]=true
				ge1=Effect.CreateEffect(c)
				ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				ge1:SetCode(ev)
				ge1:SetLabel(code)
				ge1:SetLabelObject(g)
				ge1:SetOperation(Auxiliary.MergedDelayEventCheckGlitchy1(ev,flag,f,nil,evgcheck,nil,operation,simult_check,forced,customevgop,EVENT_COUNTER_ID))
				Duel.RegisterEffect(ge1,0)
			end
		end
		if ge1 then
			local ge2=ge1:Clone()
			ge2:SetCode(EVENT_CHAIN_END)
			ge2:SetOperation(Auxiliary.MergedDelayEventCheckGlitchy2(flag,nil,evgcheck,nil,operation,forced,EVENT_COUNTER_ID))
			Duel.RegisterEffect(ge2,0)
		end
		if simult_check then
			aux.MustUpdateEventID[c]=false
			local ge3=Effect.CreateEffect(c)
			ge3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			ge3:SetCode(EVENT_BREAK_EFFECT)
			ge3:SetOperation(aux.SignalEventIDUpdate)
			Duel.RegisterEffect(ge3,0)
			local ge4=ge3:Clone()
			ge4:SetCode(EVENT_CHAIN_SOLVED)
			Duel.RegisterEffect(ge4,0)
			local ge5=ge3:Clone()
			ge5:SetCode(EVENT_CHAINING)
			Duel.RegisterEffect(ge5,0)
		end
	end
		
	if public_range>0 then
		if updateflag then code=code+100 flag=flag+100 end
		local ge1
		for _,ev in ipairs(event) do
			ge1=Effect.CreateEffect(c)
			ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			ge1:SetCode(ev)
			--ge1:SetRange(range)
			ge1:SetLabel(code)
			ge1:SetLabelObject(g)
			ge1:SetOperation(Auxiliary.MergedDelayEventCheckGlitchy1(ev,flag,f,public_range,evgcheck,se,operation,simult_check,forced,customevgop,EVENT_COUNTER_ID))
			Duel.RegisterEffect(ge1,0)
		end
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_CHAIN_END)
		ge2:SetOperation(Auxiliary.MergedDelayEventCheckGlitchy2(flag,public_range,evgcheck,se,operation,forced,EVENT_COUNTER_ID))
		Duel.RegisterEffect(ge2,0)
		if simult_check then
			aux.MustUpdateEventID[c]=false
			local ge3=Effect.CreateEffect(c)
			ge3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			ge3:SetCode(EVENT_BREAK_EFFECT)
			ge3:SetOperation(aux.SignalEventIDUpdate)
			Duel.RegisterEffect(ge3,0)
			local ge4=ge3:Clone()
			ge4:SetCode(EVENT_CHAIN_SOLVED)
			Duel.RegisterEffect(ge4,0)
			local ge5=ge3:Clone()
			ge5:SetCode(EVENT_CHAINING)
			Duel.RegisterEffect(ge5,0)
		end
	end
	
end
function Auxiliary.SignalEventIDUpdate(e,tp,eg,ep,ev,re,r,rp)
	aux.MustUpdateEventID[e:GetOwner()] = true
end
function Auxiliary.MergedDelayEventCheckGlitchy1(event,id,f,range,evgcheck,se,operation,simult_check,forced,customevgop,eid)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetOwner()
				local tp=c:GetControler()
				
				if range then
					if range==LOCATION_ENGAGED then
						if not c:IsLocation(LOCATION_HAND) or not c:IsEngaged() then
							return
						end
					else
						if not c:IsLocation(range) then
							return
						end
						if c:IsLocation(LOCATION_SZONE) and not c:IsHasEffect(EFFECT_CARD_HAS_RESOLVED) then
							return
						end
					end
				end
				local label = (range) and c:GetFieldID() or 0
				local engage_label = (range==LOCATION_ENGAGED) and c:GetEngagedID() or 0
				local g=e:GetLabelObject()
				if aux.GetValueType(g)~="Group" then return end
				local obj = aux.GetValueType(se)=="Effect" and se:GetLabelObject() or nil
				local evg=eg:Filter(f,nil,e,tp,eg,ep,ev,re,r,rp,obj,event)
				--Debug.Message(#evg)
				local flagID=id
				
				for tc in aux.Next(evg) do
					if type(id)=="function" then
						flagID=id(event,tc,e,tp)
					end
					tc:RegisterFlagEffect(flagID,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,EFFECT_FLAG_SET_AVAILABLE,1,label)
					if simult_check then
						tc:RegisterFlagEffect(simult_check,RESET_PHASE+PHASE_END,EFFECT_FLAG_SET_AVAILABLE,1,EVENT_ID)
					end
					if engage_label~=0 then
						tc:RegisterFlagEffect(flagID,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,EFFECT_FLAG_SET_AVAILABLE,1,engage_label)
					end
					if customevgop then
						customevgop(tc,e,tp,eg,ep,ev,re,r,rp,evg)
					end
				end
				if aux.MustUpdateEventID[c]==true then
					if forced and type(aux.EventCounter[eid])=="number" and #evg>0 then
						aux.EventCounter[eid] = aux.EventCounter[eid] + 1
					end
					EVENT_ID = EVENT_ID + 1
					aux.MustUpdateEventID[c]=false
				end
				
				g:Merge(evg)				--Debug.Message('gsize '..tostring(#g))
				if Duel.GetCurrentChain()==0 and not Duel.CheckEvent(EVENT_CHAIN_SOLVED) and not Duel.CheckEvent(EVENT_CHAIN_END) then
					--Debug.Message('nochain')
					local flags	
					if type(id)=="function" then
						flags={id()}
					else
						flags={id}
					end
					local G=Group.CreateGroup()
					for _,cid in ipairs(flags) do
						local _eg=g:Clone()
						_eg=_eg:Filter(Card.HasFlagEffectLabel,nil,cid,label)
						if engage_label~=0 then
							_eg=_eg:Filter(Card.HasFlagEffectLabel,nil,cid,engage_label)
						end
						--Debug.Message("NOCHAIN_FILTERED_COUNT "..tostring(cid)..": "..tostring(#_eg))
						G:Merge(_eg)
					end
					if g and #g>0 and (#G>0 or forced) then
						if not evgcheck or evgcheck(G,e,tp,ep,ev,re,r,rp) then
							--Debug.Message('a')
							local customev=ev
							if operation then
								customev=operation(e,tp,G,ep,ev,re,r,rp,obj,event)
							end
							local counter=(type(aux.EventCounter[eid])=="number" and aux.EventCounter[eid]>0) and aux.EventCounter[eid] or 1
							for i=1,counter do
								Duel.RaiseEvent(G,EVENT_CUSTOM+e:GetLabel(),re,r,rp,ep,customev)
							end
						end
						for tc in aux.Next(G) do
							for _,cid in ipairs(flags) do
								--tc:ResetFlagEffect(cid)
								tc:GetFlagEffectWithSpecificLabel(cid,label,true)
							end
						end
						MERGED_ID = MERGED_ID + 1
					end
					if type(aux.EventCounter[eid])=="number" then
						aux.EventCounter[eid]=0
					end
					g:Clear()
				end
			end
end
function Auxiliary.MergedDelayEventCheckGlitchy2(id,range,evgcheck,se,operation,forced,eid)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetOwner()
				local tp=c:GetControler()
				if range then					
					if range==LOCATION_ENGAGED then
						if not c:IsLocation(LOCATION_HAND) or not c:IsEngaged() then
							return
						end
					else
						if not c:IsLocation(range) then
							return
						end
						if c:IsLocation(LOCATION_SZONE) and not c:IsHasEffect(EFFECT_CARD_HAS_RESOLVED) then
							return
						end
					end
				end
				local label = (range) and c:GetFieldID() or 0
				local engage_label = (range==LOCATION_ENGAGED) and c:GetEngagedID() or 0
				local g=e:GetLabelObject()
				if aux.GetValueType(g)~="Group" then return end
				--Debug.Message('test')
				if #g>0 then
					local flags
					if type(id)=="function" then
						flags={id()}
					else
						flags={id}
					end
					local G=Group.CreateGroup()
					for _,cid in ipairs(flags) do
						local _eg=g:Clone()
						--Debug.Message("FLAG: "..tostring(cid))
						_eg=_eg:Filter(Card.HasFlagEffectLabel,nil,cid,label)
						--Debug.Message("FILTERED GROUP COUNT: "..tostring(#_eg))
						if engage_label~=0 then
							_eg=_eg:Filter(Card.HasFlagEffectLabel,nil,cid,engage_label)
							--Debug.Message(#_eg)
						end
						G:Merge(_eg)
					end
				    if g and #g>0 and (#G>0 or forced) then
						--Debug.Message('b')
						if not evgcheck or evgcheck(G,e,tp,ep,ev,re,r,rp) then
							local customev=ev
							if operation then
								local obj = aux.GetValueType(se)=="Effect" and se:GetLabelObject() or nil
								customev=operation(e,tp,G,ep,ev,re,r,rp,obj)
							end
							local counter=(type(aux.EventCounter[eid])=="number" and aux.EventCounter[eid]>0) and aux.EventCounter[eid] or 1
							for i=1,counter do
								--Debug.Message(i)
								Duel.RaiseEvent(G,EVENT_CUSTOM+e:GetLabel(),re,r,rp,ep,customev)
							end
						end
						for tc in aux.Next(G) do
							for _,cid in ipairs(flags) do
								--Debug.Message("RESETTED: "..tostring(cid))
								--tc:ResetFlagEffect(cid)
								tc:GetFlagEffectWithSpecificLabel(cid,label,true)
							end
						end
						MERGED_ID = MERGED_ID + 1
					end
					if type(aux.EventCounter[eid])=="number" then
						aux.EventCounter[eid]=0
					end
					g:Clear()
				end
			end
end

function Auxiliary.SimultaneousEventGroupCheck(g,simult_check,og,gcheck)
	local sg=g:Filter(Card.HasFlagEffect,nil,simult_check)
	if #sg~=#g or sg:GetClassCount(Card.GetFlagEffectLabel,simult_check)>1 then return false end
	local val=sg:GetFirst():GetFlagEffectLabel(simult_check)
	if g:FilterCount(Card.HasFlagEffectLabel,nil,simult_check,val)~=og:FilterCount(Card.HasFlagEffectLabel,nil,simult_check,val) then
		return false
	end
	return not gcheck or gcheck(g)
end
function Auxiliary.SelectSimultaneousEventGroup(g,tp,flag,ct,e,excflag,gcheck,nohint)
	local ct=ct and ct or 1
	local fid=e and e:GetHandler():GetFieldID() or 0
	if excflag then
		g=g:Filter(aux.NOT(Card.HasFlagEffectLabel),nil,excflag,fid)
	end
	if #g==0 then return end
	if #g==1 then
		if not nohint then Duel.HintSelection(g) end
		if excflag then
			g:GetFirst():RegisterFlagEffect(excflag,RESET_CHAIN,0,1,fid)
		end
		return g
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local tg=g:SelectSubGroup(tp,aux.SimultaneousEventGroupCheck,false,ct,#g,flag,g,gcheck)
		if not nohint then Duel.HintSelection(tg) end
		if excflag then
			for tc in aux.Next(tg) do
				tc:RegisterFlagEffect(excflag,RESET_CHAIN,0,1,fid)
			end
		end
		return tg
	end
end

---------------------------------------------------------------------------------
-------------------------------CONTACT FUSION---------------------------------
function Auxiliary.AddContactFusionProcedureGlitchy(c,desc,rule,sumtype,filter,self_location,opponent_location,mat_operation,...)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	local self_location=self_location or 0
	local opponent_location=opponent_location or 0
	
	local condition
	if type(mat_operation)=="table" then
		condition=mat_operation[1]
		mat_operation=mat_operation[#mat_operation]
	end
	
	local operation_params={...}
	
	local prop=EFFECT_FLAG_UNCOPYABLE
	if rule then
		prop=prop|EFFECT_FLAG_CANNOT_DISABLE
	end
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(c:GetOriginalCode(),desc)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(prop)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(Auxiliary.ContactFusionConditionGlitchy(filter,self_location,opponent_location,sumtype,condition))
	e2:SetOperation(Auxiliary.ContactFusionOperationGlitchy(filter,self_location,opponent_location,sumtype,mat_operation,operation_params))
	e2:SetValue(sumtype)
	c:RegisterEffect(e2)
	return e2
end
function Auxiliary.ContactFusionMaterialFilterGlitchy(c,fc,filter,sumtype)
	return c:IsCanBeFusionMaterial(fc,sumtype) and (not filter or filter(c,fc))
end
function Auxiliary.ContactFusionConditionGlitchy(filter,self_location,opponent_location,sumtype,condition)
	local chkfnf = sumtype==SUMMON_TYPE_FUSION and 0 or 0x200
	return	function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=Duel.GetMatchingGroup(Auxiliary.ContactFusionMaterialFilterGlitchy,tp,self_location,opponent_location,c,c,filter,sumtype)
				return (sumtype==0 or c:IsCanBeSpecialSummoned(e,sumtype,tp,false,false)) and c:CheckFusionMaterial(mg,nil,tp|chkfnf)
					and (not condition or condition(e,c,tp,mg))
			end
end
function Auxiliary.ContactFusionOperationGlitchy(filter,self_location,opponent_location,sumtype,mat_operation,operation_params)
	local chkfnf = sumtype==SUMMON_TYPE_FUSION and 0 or 0x200
	if type(mat_operation)=="function" then
		return	function(e,tp,eg,ep,ev,re,r,rp,c)
					local mg=Duel.GetMatchingGroup(Auxiliary.ContactFusionMaterialFilterGlitchy,tp,self_location,opponent_location,c,c,filter,sumtype)
					local g=Duel.SelectFusionMaterial(tp,c,mg,nil,tp|chkfnf)
					c:SetMaterial(g)
					mat_operation(g,table.unpack(operation_params))
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,c)
					local mg=Duel.GetMatchingGroup(Auxiliary.ContactFusionMaterialFilterGlitchy,tp,self_location,opponent_location,c,c,filter,sumtype)
					local g=Duel.SelectFusionMaterial(tp,c,mg,nil,tp|chkfnf)
					c:SetMaterial(g)
					operation_params[1](g,e,tp,eg,ep,ev,re,r,rp,c)
				end
	end
end

function Auxiliary.ContactFusionMaterialsToDeck(g,_,tp)
	local cg=g:Filter(Card.IsFacedown,nil)
	if cg:GetCount()>0 then
		Duel.ConfirmCards(1-tp,cg)
	end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

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

function Auxiliary.nbcon2(tp,ev,re)
	local rc=re:GetHandler()
	return Duel.IsPlayerCanRemove(tp) and (not rc:IsRelateToChain(ev) or rc:IsAbleToRemove())
end
function Auxiliary.nbtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.nbcon2(tp,ev,re) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
	if re:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_ACTION)
	else
		e:SetCategory(e:GetCategory()&~CATEGORY_GRAVE_ACTION)
	end
end
function Auxiliary.dbtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.nbcon2(tp,ev,re) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
	if re:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_ACTION)
	else
		e:SetCategory(e:GetCategory()&~CATEGORY_GRAVE_ACTION)
	end
end

-----------------------------------------------------------------------
-------------------------------PLACE ON FIELD-------------------------------

EFFECT_CANNOT_PLACE_ON_FIELD = 221594318

function Card.IsCanPlaceOnField(c,placer,receiver,loc,re,r)
	local eset={Duel.IsPlayerAffectedByEffect(placer,EFFECT_CANNOT_PLACE_ON_FIELD)}
	for _,e in ipairs(eset) do
		local val=e:GetValue()
		if not val or type(val)=="number" or val(e,c,placer,receiver,loc,re,r) then
			return false
		end
	end
	return true
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

CHEATCODE_OVERRIDE_ACTIVE_TYPE	 	= 0x1
CHEATCODE_OVERRIDE_REASON_EFFECT 	= 0x2
CHEATCODE_OVERRIDE_REASON_CARD 		= 0x4
CHEATCODE_SET_CHAIN_ID				= 0x8

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
function Effect.SetCheatCode(e,code,temp,val)
	local c=e:GetHandler()
	if not c then
		c=e:GetOwner()
	end
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
	if val then
		e:SetCheatCodeValue(code,val)
	end
end
function Card.GetCheatCode(c)
	if not c then return 0 end
	local code = (not c.cheat_code_table) and 0 or c.cheat_code_table
	local temp = (not c.cheat_code_table_temp or not c.cheat_code_table_temp[c:GetFieldID()]) and 0 or c.cheat_code_table_temp[c:GetFieldID()]
	return code|temp
end
function Effect.GetCheatCode(e)
	local c=e:GetHandler()
	if not c then
		c=e:GetOwner()
	end
	if not c then return 0 end
	local code = (not c.cheat_code_effect_table or not c.cheat_code_effect_table[e]) and 0 or c.cheat_code_effect_table[e]
	local temp = (not c.cheat_code_effect_table_temp or not c.cheat_code_effect_table_temp[e:GetFieldID()]) and 0 or c.cheat_code_effect_table_temp[e:GetFieldID()]
	return code|temp
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
	if not c then
		c=e:GetOwner()
	end
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
	if not c or not c:IsHasCheatCode(code) or not c.cheat_code_table_values or not c.cheat_code_table_values[code] then return false end
	return c.cheat_code_table_values[code]
end
function Effect.GetCheatCodeValue(e,code)
	local c=e:GetHandler()
	if not c then
		c=e:GetOwner()
	end
	if not c or not e:IsHasCheatCode(code) or not c.cheat_code_effect_table_values or not c.cheat_code_effect_table_values[e] or not c.cheat_code_effect_table_values[e][code] then return false end
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

-------------------------------SYNCHRO-------------------------------
function Auxiliary.SynchroMaterialCustomForNonTuner(c,customf,loc1,loc2,tg,tg_alt,op,op_alt)
	local ifTuner=Effect.CreateEffect(c)
	ifTuner:SetType(EFFECT_TYPE_SINGLE)
	ifTuner:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	ifTuner:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	ifTuner:SetValue(1)
	ifTuner:SetCondition(aux.IsTunerCond)
	ifTuner:SetTarget(tg)
	ifTuner:SetOperation(op)
	c:RegisterEffect(ifTuner)
	local ifNonTuner=Effect.CreateEffect(c)
	ifNonTuner:SetType(EFFECT_TYPE_SINGLE)
	ifNonTuner:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	ifNonTuner:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	ifNonTuner:SetValue(1)
	ifNonTuner:SetLabelObject(c)
	ifNonTuner:SetTarget(tg_alt)
	ifNonTuner:SetOperation(op_alt)
	local grant=Effect.CreateEffect(c)
	grant:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	grant:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	grant:SetRange(LOCATION_MZONE)
	grant:SetTargetRange(loc1,loc2)
	grant:SetCondition(aux.NOT(aux.IsTunerCond))
	grant:SetTarget(customf)
	grant:SetLabelObject(ifNonTuner)
	c:RegisterEffect(grant)
	local ed=Effect.CreateEffect(c)
	ed:SetType(EFFECT_TYPE_FIELD)
	ed:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	ed:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
	ed:SetRange(LOCATION_MZONE)
	ed:SetTargetRange(loc1,loc2)
	ed:SetCondition(aux.NOT(aux.IsTunerCond))
	ed:SetTarget(customf)
	ed:SetValue(1)
	c:RegisterEffect(ed)
	return ifTuner,ifNonTuner,grant,ed
end
function Auxiliary.IsTunerCond(e)
	local c=e:GetHandler()
	return c:IsType(TYPE_TUNER)
end

-------------------------------LINKS-----------------------------------

local _LExtraFilter,_LCheckGoal,_GetLinkCount = aux.LExtraFilter,aux.LCheckGoal,aux.GetLinkCount

Auxiliary.LExtraFilter=function(c,f,lc,tp)
	if not c:IsCanBeLinkMaterial(lc) or f and not f(c) then return false end
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in pairs(le) do
		if not c:IsOnField() or not c:IsFacedown() or te:IsHasProperty(EFFECT_FLAG_SET_AVAILABLE) then
			local tf=te:GetValue()
			local related,valid=tf(te,lc,nil,c,tp)
			if related then return true end
		end
	end
	return false
end
Auxiliary.LCheckGoal=function(sg,tp,lc,gf,lmat)
	if lc:IsHasEffect(EFFECT_MULTIPLE_LMATERIAL) then
		return sg:CheckWithSumEqual(Auxiliary.GetLinkCount,lc:GetLink(),#sg,#sg,lc)
			and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg,lc,tp))
			and not sg:IsExists(Auxiliary.LUncompatibilityFilter,1,nil,sg,lc,tp)
			and (not lmat or sg:IsContains(lmat))
	else
		return _LCheckGoal(sg,tp,lc,gf,lmat)
	end
end
function Auxiliary.GetLinkCount(c,lc)
	if lc then
		for _,e in ipairs({lc:IsHasEffect(EFFECT_MULTIPLE_LMATERIAL)}) do
			local tg=e:GetTarget()
			if not tg or tg(e,c) then
				local val=e:Evaluate(c)
				if val then
					return 1+0x10000*val
				end
			end
		end
		return _GetLinkCount(c)
	else
		return _GetLinkCount(c)
	end
end




-- function Auxiliary.ExtraLinkFilter0(c,ce,tg,lc)
	-- return c:IsCanBeLinkMaterial(lc) and tg(ce,c)
-- end

-- local _LinkCondition, _LinkTarget, _LinkOperation, _LCheckGoal =
-- Auxiliary.LinkCondition, Auxiliary.LinkTarget, Auxiliary.LinkOperation, Auxiliary.LCheckGoal

-- Auxiliary.LinkCondition = function(f,minc,maxc,gf)
	-- return	function(e,c,og,lmat,min,max)
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
				-- local mg=nil
				-- if og then
					-- mg=og:Filter(Auxiliary.LConditionFilter,nil,f,c,e)
				-- else
					-- mg=Auxiliary.GetLinkMaterials(tp,f,c,e)
				-- end
				-- if lmat~=nil then
					-- if not Auxiliary.LConditionFilter(lmat,f,c,e) then return false end
					-- mg:AddCard(lmat)
				-- end
				-- local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- if fg:IsExists(Auxiliary.MustMaterialCounterFilter,1,nil,mg) then return false end
				-- Duel.SetSelectedCard(fg)
				
				-- if Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) then
					-- local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)}
					-- local all_mats=Group.CreateGroup()
					-- for _,ce in ipairs(egroup) do
						-- if ce and ce.GetLabel then
							-- local id=ce:GetLabel()
							-- local chk_lnk=ce:GetValue()
							-- if aux.GetValueType(chk_lnk)=="function" then
								-- chk_lnk=chk_lnk(ce,c,mg,nil,tp)
							-- end
							-- if chk_lnk then
								-- local mats=Duel.GetMatchingGroup(aux.ExtraLinkFilter0,tp,0xff,0xff,nil,ce,ce:GetTarget(),c)
								-- if #mats>0 then
									-- for ec1 in aux.Next(mats) do
										-- if not mg:IsContains(ec1) then
											-- if ec1:GetFlagEffect(1006)<=0 then
												-- ec1:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
											-- end
											-- local flag=Effect.CreateEffect(ce:GetHandler())
											-- flag:SetType(EFFECT_TYPE_SINGLE)
											-- flag:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
											-- flag:SetCode(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)
											-- flag:SetValue(id)
											-- flag:SetReset(RESET_CHAIN)
											-- ec1:RegisterEffect(flag)
										-- end
									-- end
									-- all_mats:Merge(mats)
								-- end
							-- end
						-- end
					-- end
					-- all_mats:Merge(mg)
					-- local res=all_mats:CheckSubGroup(Auxiliary.LCheckGoal,minc,maxc,tp,c,gf,lmat)
					-- for ec2 in aux.Next(all_mats) do
						-- if ec2:GetFlagEffect(1006)>0 then
							-- ec2:ResetFlagEffect(1006)
						-- end
						-- for _,flag in ipairs({ec2:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
							-- if flag and flag.GetLabel then
								-- flag:Reset()
							-- end
						-- end
					-- end
					-- return res
				-- else			
					-- return mg:CheckSubGroup(Auxiliary.LCheckGoal,minc,maxc,tp,c,gf,lmat)
				-- end
			-- end
-- end

-- Auxiliary.LinkTarget = function(f,minc,maxc,gf)
	-- return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,lmat,min,max)
				-- local minc=minc
				-- local maxc=maxc
				-- if min then
					-- if min>minc then minc=min end
					-- if max<maxc then maxc=max end
					-- if minc>maxc then return false end
				-- end
				-- local mg=nil
				-- if og then
					-- mg=og:Filter(Auxiliary.LConditionFilter,nil,f,c,e)
				-- else
					-- mg=Auxiliary.GetLinkMaterials(tp,f,c,e)
				-- end
				-- if lmat~=nil then
					-- if not Auxiliary.LConditionFilter(lmat,f,c,e) then return false end
					-- mg:AddCard(lmat)
				-- end
				-- local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- Duel.SetSelectedCard(fg)
				
				-- if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) then
					-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					-- local cancel=Duel.IsSummonCancelable()
					-- local sg=mg:SelectSubGroup(tp,Auxiliary.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
					-- if sg then
						-- sg:KeepAlive()
						-- e:SetLabelObject(sg)
						-- return true
					-- else
						-- return false
					-- end
				-- else
					-- local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)}
					-- local all_mats=Group.CreateGroup()
					-- for _,ce in ipairs(egroup) do
						-- if ce and ce.GetLabel then
							-- local id=ce:GetLabel()
							-- local chk_lnk=ce:GetValue()
							-- if aux.GetValueType(chk_lnk)=="function" then
								-- chk_lnk=chk_lnk(ce,c,mg,nil,tp)
							-- end
							-- if chk_lnk then
								-- local mats=Duel.GetMatchingGroup(aux.ExtraLinkFilter0,tp,0xff,0xff,nil,ce,ce:GetTarget(),c)
								-- if #mats>0 then
									-- for ec1 in aux.Next(mats) do
										-- if not mg:IsContains(ec1) then
											-- if ec1:GetFlagEffect(1006)<=0 then
												-- ec1:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
											-- end
											-- local flag=Effect.CreateEffect(ce:GetHandler())
											-- flag:SetType(EFFECT_TYPE_SINGLE)
											-- flag:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
											-- flag:SetCode(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)
											-- flag:SetValue(id)
											-- flag:SetReset(RESET_CHAIN)
											-- ec1:RegisterEffect(flag)
										-- end
									-- end
									-- all_mats:Merge(mats)
								-- end
							-- end
						-- end
					-- end
					-- all_mats:Merge(mg)
					
					-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					-- local cancel=Duel.IsSummonCancelable()
					-- local chosen_mats=all_mats:SelectSubGroup(tp,Auxiliary.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
					-- for ec2 in aux.Next(all_mats) do
						-- if ec2:GetFlagEffect(1006)>0 then
							-- ec2:ResetFlagEffect(1006)
						-- end
						-- for _,flag in ipairs({ec2:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
							-- if flag and flag.GetLabel then
								-- flag:Reset()
							-- end
						-- end
					-- end
					
					-- local extra_mats=Group.CreateGroup()
					-- local valid_effs,extra_opt={},{}
					-- for mc in aux.Next(chosen_mats) do
						-- for _,ce in ipairs(egroup) do
							-- if --[[not mg:IsContains(mc) and ]]ce and ce.GetLabel and ce:GetTarget()(ce,mc) then
								-- --register card as possible extra material
								-- extra_mats:AddCard(mc)
								-- mc:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
								-- --register description
								-- local d=ce:GetDescription()
								-- for _,desc in ipairs(extra_opt) do
									-- if desc==d then
										-- d=false
										-- break
									-- end
								-- end
								-- if d then
									-- table.insert(extra_opt,d)
									-- table.insert(valid_effs,ce)
								-- end
							-- end
						-- end
					-- end
					-- if #extra_opt>0 and (chosen_mats:IsExists(aux.NOT(aux.IsInGroup),1,nil,mg) or Duel.SelectYesNo(tp,aux.Stringid(1006,0))) then
						-- local ecount=0
						-- while aux.GetValueType(extra_mats)=="Group" and #extra_mats>0 and #extra_opt>0 and (ecount==0 or chosen_mats:IsExists(aux.PureExtraFilterLoop,1,nil,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) or Duel.SelectYesNo(tp,aux.Stringid(1006,0))) do
							-- local opt=Duel.SelectOption(tp,table.unpack(extra_opt))+1
							-- local eff=valid_effs[opt]
							-- local _,max=eff:GetValue()(eff,nil)
							-- if not max or max==0 then max=#extra_mats end
							-- local emats=extra_mats:SelectSubGroup(tp,aux.ExtraMaterialFilterGoal,false,1,max,extra_mats)
							-- --local emats=extra_mats:FilterSelect(tp,aux.ExtraMaterialFilterSelect,1,max,nil,eff,eff:GetTarget())
							-- if #emats>0 then
								-- for tc in aux.Next(emats) do
									-- local e1=Effect.CreateEffect(tc)
									-- e1:SetType(EFFECT_TYPE_SINGLE)
									-- e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
									-- e1:SetCode(EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)
									-- e1:SetLabel(ecount)
									-- e1:SetOperation(eff:GetOperation())
									-- e1:SetReset(RESET_CHAIN)
									-- tc:RegisterEffect(e1,true)
									-- extra_mats:RemoveCard(tc)
								-- end
							-- end
							-- table.remove(extra_opt,opt)
							-- table.remove(valid_effs,opt)
							-- ecount=ecount+1
						-- end
					-- end
					-- for ec4 in aux.Next(chosen_mats) do
						-- if ec4:GetFlagEffect(1006)>0 and not ec4:IsHasEffect(EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) then
							-- ec4:ResetFlagEffect(1006)
						-- end
					-- end
					
					-- if chosen_mats then
						-- chosen_mats:KeepAlive()
						-- e:SetLabelObject(chosen_mats)
						-- return true
					-- else
						-- return false
					-- end
				-- end
			-- end
-- end

-- Auxiliary.LinkOperation = function(f,minc,maxc,gf)
	-- return	function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				-- local g=e:GetLabelObject()
				-- c:SetMaterial(g)
				-- Auxiliary.LExtraMaterialCount(g,c,tp)
				
				-- local rg=g:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
				-- g:Sub(rg)
				-- local opt=0
				-- Duel.SendtoGrave(rg,REASON_MATERIAL+REASON_LINK)
				
				-- local ecount=0
				-- while #g>0 do
					-- local extra_g=Group.CreateGroup()
					-- local extra_op=false
					-- for tc in aux.Next(g) do
						-- local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)
						-- if ce and ce.GetLabel then
							-- extra_g:AddCard(tc)
							-- if not extra_op then
								-- extra_op=ce:GetOperation()
							-- end
						-- end
					-- end
					-- if #extra_g>0 then
						-- g:Sub(extra_g)
						-- for tc in aux.Next(extra_g) do
							-- tc:ResetFlagEffect(1006)
						-- end
						-- extra_op(extra_g)
						-- extra_g:DeleteGroup()
					-- end
					-- ecount=ecount+1
				-- end

				-- g:DeleteGroup()
			-- end
-- end

-- Auxiliary.LCheckGoal = function(sg,tp,lc,gf,lmat)
	-- for _,e in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)}) do
		-- local id=e:GetLabel()
		-- local val=e:GetValue()
		-- if val then
			-- local _,valmax=val(e,nil)
			-- if not (not sg or not sg:IsExists(aux.ExtraMaterialMaxCheck,valmax+1,nil,id)) then
				-- return false
			-- end
		-- end
	-- end
	-- return _LCheckGoal(sg,tp,lc,gf,lmat)
-- end

