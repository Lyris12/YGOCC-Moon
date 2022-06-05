function Auxiliary.OptionalContinuous(op,id,desc)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not Duel.SelectYesNo(tp,aux.Stringid(id,desc)) then return end
				return op(e,tp,eg,ep,ev,re,r,rp)
			end
end

-----------------------------------------------------------------------
--SINGLE TRIGGERS
function Card.Trigger(c,forced,desc,ctg,defaultprop,prop,event,ctlim,cond,cost,tg,op,typechange,reset,notreg)
	local trigger_type=(type(typechange)=="number") and EFFECT_TYPE_CONTINUOUS or (not forced) and EFFECT_TYPE_TRIGGER_O or EFFECT_TYPE_TRIGGER_F
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	if ctg then
		if type(ctg)=="table" then
			e1:SetCategory(ctg[1])
			if #ctg>1 then
				e1:SetCustomCategory(ctg[2])
			end
		else
			e1:SetCategory(ctg)
		end
	end
	if prop~=nil then
		if type(prop)=="boolean" then
			if prop==true then
				if not defaultprop then defaultprop=0 end
				e1:SetProperty(EFFECT_FLAG_DELAY+defaultprop)
				
			elseif defaultprop then
				e1:SetProperty(defaultprop)
			end
		else
			e1:SetProperty(prop)
		end
	end	
	e1:SetType(EFFECT_TYPE_SINGLE+trigger_type)
	e1:SetCode(event)
	if ctlim then
		if type(ctlim)=="table" then
			local flag=#ctlim>2 and ctlim[3] or 0
			e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
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
		if type(typechange)=="number" and not forced then
			op=aux.OptionalContinuous(op,c:GetOriginalCode(),typechange)
		end
		e1:SetOperation(op)
	end
	if reset then
		e1:SetReset(reset)
	end
	if not notreg then
		c:RegisterEffect(e1)
	end
	return e1
end

function Card.DestroyedTrigger(c,forced,desc,ctg,prop,ctlim,cond,cost,tg,op,typechange,reset)
	local event=EVENT_DESTROYED
	local e1=c:Trigger(forced,desc,ctg,EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL,prop,event,ctlim,cond,cost,tg,op,typechange,reset)
	return e1
end
function Card.LeaveTrigger(c,forced,desc,ctg,prop,ctlim,cond,cost,tg,op,typechange,reset)
	local event=EVENT_LEAVE_FIELD
	local e1=c:Trigger(forced,desc,ctg,EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL,prop,event,ctlim,cond,cost,tg,op,typechange,reset)
	return e1
end
function Card.PositionTrigger(c,forced,desc,ctg,prop,ctlim,cond,cost,tg,op,typechange,reset)
	local event=EVENT_POS_CHANGE
	local e1=c:Trigger(forced,desc,ctg,EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL,prop,event,ctlim,cond,cost,tg,op,typechange,reset)
	return e1
end
function Card.SentToGYTrigger(c,forced,desc,ctg,prop,ctlim,cond,cost,tg,op,typechange,reset)
	local event=EVENT_TO_GRAVE
	local e1=c:Trigger(forced,desc,ctg,EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL,prop,event,ctlim,cond,cost,tg,op,typechange,reset)
	return e1
end
function Card.SummonedTrigger(c,forced,ns,ss,fs,desc,ctg,prop,ctlim,cond,cost,tg,op,typechange,reset)
	local event=(ns==true) and EVENT_SUMMON_SUCCESS or (ss==true) and EVENT_SPSUMMON_SUCCESS or (fs==true) and EVENT_FLIP_SUMMON_SUCCESS or EVENT_SUMMON_SUCCESS
	local e1=c:Trigger(forced,desc,ctg,EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL,prop,event,ctlim,cond,cost,tg,op,typechange,reset,true)
	local e2,e3
	if ns then
		c:RegisterEffect(e1)
	end
	if ss then
		e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(e2)
	end
	if fs then
		e3=e1:Clone()
		e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		c:RegisterEffect(e3)
	end
	return e1,e2,e3
end
function Card.TributedForATributeSummonTrigger(c,forced,f,desc,ctg,prop,ctlim,cond,cost,tg,op,typechange,reset)
	local event=EVENT_BE_MATERIAL
	newcond =	function(e,tp,eg,ep,ev,re,r,rp)
					local c=e:GetHandler()
					local rc=c:GetReasonCard()
					return c:IsReason(REASON_SUMMON) and (not f or f(rc,e,tp,eg,ep,ev,re,r,rp)) and (not cond or cond(e,tp,eg,ep,ev,re,r,rp,c,rc))
				end
	local e1=c:Trigger(forced,desc,ctg,EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL,prop,event,ctlim,newcond,cost,tg,op,typechange,reset)
	return e1
end

-----------------------------------------------------------------------
--FIELD TRIGGERS
function Card.FieldTrigger(c,forced,desc,ctg,prop,event,range,ctlim,cond,cost,tg,op,typechange,reset,notreg)
	local trigger_type=(type(typechange)=="number") and EFFECT_TYPE_CONTINUOUS or (type(typechange)=="boolean") and EFFECT_TYPE_ACTIVATE or (not forced) and EFFECT_TYPE_TRIGGER_O or EFFECT_TYPE_TRIGGER_F
	if trigger_type==EFFECT_TYPE_ACTIVATE then
		if type(prop)=="boolean" and prop then prop=EFFECT_FLAG_DELAY end
		return c:Activate(desc,ctg,prop,event,ctlim,cond,cost,tg,op,reset)
	end
	
	local range = range and range or (c:IsOriginalType(TYPE_MONSTER)) and LOCATION_MZONE or (c:IsOriginalType(TYPE_FIELD)) and LOCATION_FZONE or LOCATION_SZONE
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	if ctg then
		if type(ctg)=="table" then
			e1:SetCategory(ctg[1])
			if #ctg>1 then
				e1:SetCustomCategory(ctg[2])
			end
		else
			e1:SetCategory(ctg)
		end
	end
	if prop~=nil and prop then
		if type(prop)=="boolean" then
			e1:SetProperty(EFFECT_FLAG_DELAY)
		else
			e1:SetProperty(prop)
		end
	end	
	e1:SetType(EFFECT_TYPE_FIELD+trigger_type)
	e1:SetCode(event)
	e1:SetRange(range)
	if ctlim then
		if type(ctlim)=="table" then
			local flag=#ctlim>2 and ctlim[3] or 0
			e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
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
		if type(typechange)=="number" and not forced then
			op=aux.OptionalContinuous(op,c:GetOriginalCode(),typechange)
		end
		e1:SetOperation(op)
	end
	if reset then
		e1:SetReset(reset)
	end
	if not notreg then
		c:RegisterEffect(e1)
	end
	return e1
end

function Card.DestroyedFieldTrigger(c,forced,desc,ctg,prop,range,ctlim,cond,cost,tg,op,typechange,reset)
	local event=EVENT_DESTROYED
	local e1=c:FieldTrigger(forced,desc,ctg,prop,event,range,ctlim,cond,cost,tg,op,typechange,reset)
	return e1
end
function Card.LeaveFieldTrigger(c,forced,desc,ctg,prop,range,ctlim,cond,cost,tg,op,typechange,reset)
	local event=EVENT_LEAVE_FIELD
	local e1=c:FieldTrigger(forced,desc,ctg,prop,event,range,ctlim,cond,cost,tg,op,typechange,reset)
	return e1
end
function Card.PositionFieldTrigger(c,forced,desc,ctg,prop,range,ctlim,cond,cost,tg,op,typechange,reset)
	local event=EVENT_CHANGE_POS
	local e1=c:FieldTrigger(forced,desc,ctg,prop,event,range,ctlim,cond,cost,tg,op,typechange,reset)
	return e1
end
function Card.SentToGYFieldTrigger(c,forced,desc,ctg,prop,range,ctlim,cond,cost,tg,op,typechange,reset)
	local event=EVENT_TO_GRAVE
	local e1=c:FieldTrigger(forced,desc,ctg,prop,event,range,ctlim,cond,cost,tg,op,typechange,reset)
	return e1
end
function Card.SummonedFieldTrigger(c,forced,ns,ss,fs,desc,ctg,prop,range,ctlim,cond,cost,tg,op,typechange,reset)
	local event=(ns==true) and EVENT_SUMMON_SUCCESS or (ss==true) and EVENT_SPSUMMON_SUCCESS or (fs==true) and EVENT_FLIP_SUMMON_SUCCESS or EVENT_SUMMON_SUCCESS
	local e1=c:FieldTrigger(forced,desc,ctg,prop,event,range,ctlim,cond,cost,tg,op,typechange,reset,true)
	local e2,e3
	if ns then
		c:RegisterEffect(e1)
	end
	if ss then
		e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(e2)
	end
	if fs then
		e3=e1:Clone()
		e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		c:RegisterEffect(e3)
	end
	return e1,e2,e3
end
function Card.TributedForATributeSummonFieldTrigger(c,forced,f,desc,ctg,prop,range,ctlim,cond,cost,tg,op,typechange,reset)
	local event=EVENT_BE_MATERIAL
	local func = function(card,eff,tp,eg,ep,ev,re,r,rp) return card:IsReason(REASON_SUMMON) and (not f or f(card,eff,tp,eg,ep,ev,re,r,rp)) end
	newcond = function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(func,1,nil,e,tp,eg,ep,ev,re,r,rp) and (not cond or cond(e,tp,eg,ep,ev,re,r,rp)) end
	local e1=c:FieldTrigger(forced,desc,ctg,prop,event,range,ctlim,newcond,cost,tg,op,typechange,reset)
	return e1
end

function Card.PhaseTrigger(c,forced,phase,desc,ctg,prop,range,ctlim,cond,cost,tg,op,typechange,reset)
	if not phase then phase=PHASE_END end
	if not ctlim then ctlim=1 end
	local event=EVENT_PHASE+phase
	local e1=c:FieldTrigger(forced,desc,ctg,prop,event,range,ctlim,cond,cost,tg,op,typechange,reset)
	return e1
end