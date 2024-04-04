---------------------------------------
--[[Card.IsAffectedByEffect]]
function Card.IsAffectedByEffect(c,code,cc)
	local eset={c:IsHasEffect(code)}
	for _,e in ipairs(eset) do
		local val=e:GetValue()
		if not val or type(val)=="number" or val(e,cc) then
			return true
		end
	end
	
	return false
end

--[[Card.CheckCostCondition
Checks if the conditions defined by the Cost Functions of all the effects with the code (ecode) are ALL satisfied by passing (e,c,tp)
]]
function Card.CheckCostCondition(c,ecode,tp)
	local eset={Duel.IsPlayerAffectedByEffect(tp,ecode)}
	local eset_card={c:IsHasEffect(ecode)}
	for _,e in ipairs(eset_card) do
		table.insert(eset,e)
	end
	
	local res = true
	local oreason = self_reference_effect
	local op = current_triggering_player
	
	for i,e in ipairs(eset) do
		self_reference_effect = e
		current_triggering_player = tp
		local cost=e:GetCost()
		if cost and not cost(e,c,tp) then
			res=false
			break
		end
	end
	
	self_reference_effect = oreason
	current_triggering_player = op
	return res
end

--FLIP SUMMONS
--[[Card.IsCanBeFlipSummoned]]
function Card.IsCanBeFlipSummoned(c,tp,ignore_limit)
	if not ignore_limit then
		if c:IsStatus(STATUS_SUMMON_TURN|STATUS_FLIP_SUMMON_TURN|STATUS_SPSUMMON_TURN|STATUS_FORM_CHANGED) or c:GetAttackAnnouncedCount()>0 then
			return false
		end
	end
	if not c:IsLocation(LOCATION_MZONE) or not c:IsFacedown() 
	or not c:CheckUniqueOnField(tp,LOCATION_MZONE) or not Duel.IsPlayerCanFlipSummon(tp,c)
	or c:IsForbidden()
	or c:IsHasEffect(EFFECT_CANNOT_FLIP_SUMMON) or c:IsHasEffect(EFFECT_CANNOT_CHANGE_POSITION)
	or not c:CheckCostCondition(EFFECT_FLIPSUMMON_COST,tp) then
		return false
	end
	
	return true
end

--[[Duel.FlipSummon]]
function Duel.FlipSummon(tp,c)
	if not c:IsLocation(LOCATION_MZONE) or not c:IsFacedown() or not c:CheckUniqueOnField(tp,LOCATION_MZONE) then
		return
	end
	local eset={c:IsHasEffect(EFFECT_FLIPSUMMON_COST)}
	if #eset>0 then
		for _,e in ipairs(eset) do
			local op=e:GetOperation()
			if op then
				op(e,tp)
			end
		end
	end
	
	if c:IsFacedown() and Duel.ChangePosition(c,POS_FACEUP_ATTACK)>0 then
		c:SetStatus(STATUS_FLIP_SUMMON_TURN,true)
		--needs workaround to update flip summon state count
		Duel.AdjustInstantly()
		Duel.RaiseSingleEvent(c,EVENT_FLIP,nil,0,tp,tp,0)
		Duel.RaiseSingleEvent(c,EVENT_FLIP_SUMMON_SUCCESS,nil,0,tp,tp,0)
		Duel.RaiseSingleEvent(c,EVENT_CHANGE_POS,nil,0,tp,tp,0)
		Duel.RaiseEvent(c,EVENT_FLIP,nil,0,tp,tp,0)
		Duel.RaiseEvent(c,EVENT_FLIP_SUMMON_SUCCESS,nil,0,tp,tp,0)
		Duel.RaiseEvent(c,EVENT_CHANGE_POS,nil,0,tp,tp,0)
		Duel.AdjustAll()
		return true
	
	else
		return false
	end
end
-- ---------------------------------------
CODE_CUSTOM,CODE_COUNTER,CODE_PHASE,CODE_VALUE = 1,2,3,4
function Effect.GetCodeType(code)
	if code&EVENT_CUSTOM>0 then
		return CODE_CUSTOM
	elseif code&0xf0000 then
		return CODE_COUNTER
	elseif code&0xf000 then
		return CODE_PHASE
	else
		return CODE_VALUE
	end
end

function Effect.GetSpellSpeed(e)
	local type=e:GetType()
	if type&EFFECT_TYPE_ACTIONS==0 then
		return 0
		
	elseif type&(EFFECT_TYPE_TRIGGER_F|EFFECT_TYPE_TRIGGER_O|EFFECT_TYPE_IGNITION)>0 then
		return 1
	
	elseif type&(EFFECT_TYPE_QUICK_F|EFFECT_TYPE_QUICK_O)>0 then
		return 2
		
	elseif type&EFFECT_TYPE_ACTIVATE>0 then
		local c=e:GetHandler()
		if c:IsOriginalType(TYPE_MONSTER) then
			return 0
		elseif c:IsOriginalType(TYPE_SPELL) then
			if c:IsOriginalType(TYPE_QUICKPLAY) then
				return 2
			else
				return 1
			end
		elseif c:IsOriginalType(TYPE_TRAP) then
			if c:IsOriginalType(TYPE_COUNTER) then
				return 3
			else
				return 2
			end
		end
	end
	
	return 0
end

function Effect.InRange(e,c)
	if e:IsHasType(EFFECT_TYPE_XMATERIAL) then
		return e:GetHandler():GetOverlayTarget()
	else
		return c:IsLocation(e:GetRange())
	end
end

function Effect.IsActionCheck(e,tp)
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ACTIVATE)}
	for _,fe in ipairs(eset) do
		if fe:Evaluate(fe,e,tp) then
			return false
		end
	end
	
	eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_ACTIVATE_COST)}
	for _,fe in ipairs(eset) do
		local tg=fe:GetTarget()
		if not tg or tg(fe,e,tp) then
			local cost=fe:GetCost()
			if cost and not cost(fe,e,tp) then
				return false
			end
		end
	end
	
	return true
end

function Effect.IsCanBeForbidden(e)
	if e:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE) and not e:IsHasProperty(EFFECT_FLAG_CANNOT_NEGATE) then
		return false
	end
	if e:GetCode()==EFFECT_CHANGE_CODE then
		return false
	end
	return true
end

function Effect.IsChainable(e,tp)
	if not e:IsHasType(EFFECT_TYPE_ACTIONS) then return false end
	local type=e:GetType()
	local sp=e:GetSpellSpeed()
	
	if type&EFFECT_TYPE_ACTIVATE>0 and sp<=1 and not e:IsHasProperty(0,EFFECT_FLAG2_COF) then
		return false
	
	elseif Duel.GetCurrentChain()>0 then
		local c=e:GetHandler()
		local te=Duel.GetChainInfo(#Duel.GetCurrentChain,CHAININFO_TRIGGERING_EFFECT)
		if not e:IsHasProperty(EFFECT_FLAG_FIELD_ONLY) and type&EFFECT_TYPE_TRIGGER_O>0 and c:IsLocation(LOCATION_HAND) then
			if te:GetSpellSpeed()>2 then
				return false
			end
		elseif sp<te:GetSpellSpeed() then
			return false
		end
	end
	
	for _,chlim in ipairs(Core.ChainLimit) do 
		local f,p = chlim[1],chlim[2]
		if f and not f(e,p,tp) then
			return false
		end
	end
	for _,chlimp in ipairs(Core.ChainLimitP) do 
		local f,p = chlimp[1],chlimp[2]
		if f and not f(e,p,tp) then
			return false
		end
	end
	
	return true
end

Auxiliary.ContinuousEvents = {EVENT_ADJUST, EVENT_BREAK_EFFECT, EVENT_TURN_END}
function Effect.IsContinuousEvent(code)
	if code&EVENT_CUSTOM>0 or code&0xf0000>0 then return false end
	if code&0xf000 then
		return code&EVENT_PHASE_START>0
	else
		return aux.FindInTable(aux.ContinuousEvents,code)
	end
end
 
--[[Effect.IsFitTargetFunction
Checks if the card (c) satisfies the condition set by the Target Function of (e), by passing (e,c) only
]]
function Effect.IsFitTargetFunction(e,c)
	local tg=e:GetTarget()
	if tg then
		return tg(e,c)
	end
	return true
end	