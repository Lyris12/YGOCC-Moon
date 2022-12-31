DRIVE_STRINGS					=34842

TYPE_DRIVE						=0x40000000000000
TYPE_CUSTOM						=TYPE_CUSTOM|TYPE_DRIVE
CTYPE_DRIVE						=0x400000
CTYPE_CUSTOM					=CTYPE_CUSTOM|CTYPE_DRIVE

SUMMON_TYPE_DRIVE				=SUMMON_TYPE_SPECIAL+348

REASON_DRIVE	= 0x80000000000

FLAG_ENGAGE = 348
FLAG_ZERO_ENERGY = 349

EFFECT_DRIVE_ORIGINAL_ENERGY 	= 34843
EFFECT_DRIVE_ENERGY 			= 34844
EFFECT_UPDATE_ENERGY			= 34845
EFFECT_CHANGE_ENERGY			= 34846

EVENT_ENGAGE					= EVENT_CUSTOM+34843

Auxiliary.Drives={}

local get_type, get_orig_type, get_prev_type_field, get_reason, get_fusion_type, get_synchro_type, get_xyz_type, get_link_type, get_ritual_type = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetReason, Card.GetFusionType, Card.GetSynchroType, Card.GetXyzType, Card.GetLinkType, Card.GetRitualType

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Drives[c] then
		tpe=tpe|TYPE_DRIVE
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Drives[c] then
		tpe=tpe|TYPE_DRIVE
		
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Drives[c] then
		tpe=tpe|TYPE_DRIVE
		
	end
	return tpe
end

Card.GetReason=function(c)
	local rs=get_reason(c)
	local rc=c:GetReasonCard()
	if rc and Auxiliary.Drives[rc] then
		rs=rs|REASON_DRIVE
	end
	return rs
end
Card.GetFusionType=function(c)
	local tpe=get_fusion_type(c)
	if Auxiliary.Drives[c] then
		tpe=tpe|TYPE_DRIVE
		
	end
	return tpe
end
Card.GetSynchroType=function(c)
	local tpe=get_synchro_type(c)
	if Auxiliary.Drives[c] then
		tpe=tpe|TYPE_DRIVE
		
	end
	return tpe
end
Card.GetXyzType=function(c)
	local tpe=get_xyz_type(c)
	if Auxiliary.Drives[c] then
		tpe=tpe|TYPE_DRIVE
		
	end
	return tpe
end
Card.GetLinkType=function(c)
	local tpe=get_link_type(c)
	if Auxiliary.Drives[c] then
		tpe=tpe|TYPE_DRIVE
		
	end
	return tpe
end
Card.GetRitualType=function(c)
	local res=get_ritual_type(c)
	if Auxiliary.Drives[c] then
		tpe=tpe|TYPE_DRIVE
		
	end
	return tpe
end


function Auxiliary.AddOrigDriveType(c)
	table.insert(Auxiliary.Drives,c)
	Auxiliary.Customs[c]=true
	Auxiliary.Drives[c]=true
end
function Auxiliary.AddDriveProc(c,energy)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(DRIVE_STRINGS,0))
	e1:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(Auxiliary.EngageCondition)
	e1:SetOperation(Auxiliary.EngageOperation)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(DRIVE_STRINGS,1))
	e1:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_BOTH_SIDE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(Auxiliary.DriveEffectCondition())
	e1:SetTarget(function(ce,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end Duel.SetChainLimit(aux.FALSE) end)
	e1:SetOperation(Auxiliary.CheckEnergyOperation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_DRIVE_ORIGINAL_ENERGY)
	e2:SetValue(energy)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_DRIVE_ENERGY)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(DRIVE_STRINGS,2))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(Auxiliary.DriveCondition)
	e4:SetValue(SUMMON_TYPE_DRIVE)
	c:RegisterEffect(e4)
end
function Auxiliary.DriveSelfToGraveCon(e)
	local c=e:GetHandler()
	if not c:IsEngaged() then
		e:Reset()
		return false
	end
	return c:GetEnergy()==0
end

--DRIVE SUMMON
function Auxiliary.DriveCondition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return c:IsEngaged() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetEnergy()==c:GetLevel()
end

--ENGAGING PROCEDURE
function Card.IsCanEngage(c,tp,ignore_ruling)
	return (not c:IsLocation(LOCATION_HAND) or not c:IsEngaged()) and (ignore_ruling or not Duel.IsExistingMatchingCard(Card.IsEngaged,tp,LOCATION_HAND,0,1,c))
end
function Card.IsEngaged(c)
	for _,e in ipairs({c:IsHasEffect(EFFECT_PUBLIC)}) do
		if e and e.GetLabel and e:GetLabel()==FLAG_ENGAGE then
			return true
		end
	end
	return c:HasFlagEffect(FLAG_ENGAGE)
end
function Card.Engage(c,e,tp)
	if not c:IsLocation(LOCATION_HAND) or not c:IsCanEngage(tp) then return end
	Duel.Hint(HINT_CARD,tp,c:GetOriginalCode())
	aux.CheckEnergyOperation(c,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetLabel(FLAG_ENGAGE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	c:RegisterFlagEffect(FLAG_ENGAGE,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(DRIVE_STRINGS,3))
	Duel.RaiseEvent(c,EVENT_ENGAGE,e,REASON_RULE,tp,tp,0)
	--
	local e5=Effect.CreateEffect(e:GetHandler())
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_ADJUST)
	e5:SetRange(LOCATION_HAND)
	e5:SetCondition(Auxiliary.DriveSelfToGraveCon)
	e5:SetOperation(function(ce) Duel.SendtoGrave(ce:GetHandler(),REASON_RULE) end)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e5)
end
function Auxiliary.EngageCondition(e,tp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_HAND) and c:IsCanEngage(tp)
end
function Auxiliary.EngageOperation(e,tp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_HAND) or not c:IsCanEngage(tp) then return end
	Duel.Hint(HINT_CARD,tp,c:GetOriginalCode())
	aux.CheckEnergyOperation(e,tp)
	Duel.ConfirmCards(1-tp,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetLabel(FLAG_ENGAGE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
	c:RegisterFlagEffect(FLAG_ENGAGE,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(DRIVE_STRINGS,3))
	Duel.RaiseEvent(c,EVENT_ENGAGE,e,REASON_RULE,tp,tp,0)
	Duel.RaiseSingleEvent(c,EVENT_ENGAGE,e,REASON_RULE,tp,tp,0)
	--
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_ADJUST)
	e5:SetRange(LOCATION_HAND)
	e5:SetCondition(Auxiliary.DriveSelfToGraveCon)
	e5:SetOperation(	function(ce)
							local cc=ce:GetHandler()
							cc:RegisterFlagEffect(FLAG_ZERO_ENERGY,RESET_EVENT+RESETS_STANDARD-RESET_TOGRAVE,EFFECT_FLAG_IGNORE_IMMUNE,1)
							if Duel.SendtoGrave(cc,REASON_RULE)<=0 or not cc:IsLocation(LOCATION_GRAVE) then
								cc:ResetFlagEffect(FLAG_ZERO_ENERGY)
							end
						end
					)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e5)
	Duel.AdjustAll()
end

function Duel.GetEngagedCard(tp)
	local g=Duel.GetMatchingGroup(Card.IsEngaged,tp,LOCATION_HAND,0,nil)
	if #g==1 then
		return g:GetFirst()
	else
		return
	end
end

--CHECK ENERGY
function Auxiliary.CheckEnergyOperation(e,tp)
	local c = aux.GetValueType(e)=="Effect" and e:GetHandler() or e
	local en=c:GetEnergy()
	Duel.Hint(HINT_SOUND,0,aux.Stringid(DRIVE_STRINGS,4))
	if en<=20 and en>0 then
		c:SetTurnCounter(en)
	else
		Duel.Hint(HINT_NUMBER,tp,en)
	end
end

--DRIVE EFFECTS
function Auxiliary.DriveEffectCondition(cond)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return e:GetHandler():IsEngaged() and (not cond or cond(e,tp,eg,ep,ev,re,r,rp))
			end
end
function Auxiliary.OverDriveEffectCondition(cond)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				return c:IsEngaged() and c:GetEnergy()<c:GetLevel() and (not cond or cond(e,tp,eg,ep,ev,re,r,rp))
			end
end
function Auxiliary.DriveEffectCost(ct,cost)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then return c:IsCanUpdateEnergy(ct,tp,REASON_COST) and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,chk)) end
				c:UpdateEnergy(ct,tp,REASON_COST)
				if cost then
					cost(e,tp,eg,ep,ev,re,r,rp,chk)
				end
			end
end
function Auxiliary.OverDriveEffectCost(cost)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then return (not cost or cost(e,tp,eg,ep,ev,re,r,rp,chk)) end
				c:ChangeEnergy(0,tp,REASON_COST)
				if cost then
					cost(e,tp,eg,ep,ev,re,r,rp,chk)
				end
			end
end

function Card.DriveEffect(c,energycost,desc,category,typ,property,event,condition,cost,target,operation,hold_registration)
	local typ = typ or EFFECT_TYPE_IGNITION
	local property = type(property)~="boolean" and property or property==true and EFFECT_FLAG_CARD_TARGET
	local event = (not event and typ~=EFFECT_TYPE_IGNITON) and EVENT_FREE_CHAIN or event
	local e=Effect.CreateEffect(c)
	if desc then
		e:Desc(desc)
	end
	if category then
		e:SetCategory(category)
	end
	e:SetType(typ)
	if property then
		e:SetProperty(property)
	end
	if event then
		e:SetCode(event)
	end
	e:SetRange(LOCATION_HAND)
	if typ~=EFFECT_TYPE_SINGLE and typ~=EFFECT_TYPE_FIELD and typ&EFFECT_TYPE_CONTINUOUS==0 then
		e:HOPT()
	end
	e:SetCondition(aux.DriveEffectCondition(condition))
	if energycost~=0 then
		e:SetCost(aux.DriveEffectCost(energycost,cost))
	elseif cost then
		e:SetCost(cost)
	end
	if target then
		if type(target)=="table" then
			e:SetTargetRange(target[1],target[2])
			e:SetTarget(target[3])
		else
			e:SetTarget(target)
		end
	end
	if typ~=EFFECT_TYPE_SINGLE and typ~=EFFECT_TYPE_FIELD then
		e:SetOperation(operation)
	else
		e:SetValue(operation)
	end
	if not hold_registration then
		c:RegisterEffect(e)
	end
	return e
end
function Card.OverDriveEffect(c,desc,category,typ,property,event,condition,cost,target,operation,hold_registration)
	local typ = typ or EFFECT_TYPE_IGNITION
	local property = type(property)~="boolean" and property or property==true and EFFECT_FLAG_CARD_TARGET
	local event = (not event and typ~=EFFECT_TYPE_IGNITON) and EVENT_FREE_CHAIN or nil
	local e=Effect.CreateEffect(c)
	if desc then
		e:Desc(desc)
	end
	if category then
		e:SetCategory(category)
	end
	e:SetType(typ)
	if property then
		e:SetProperty(property)
	end
	if event then
		e:SetCode(event)
	end
	e:SetRange(LOCATION_HAND)
	e:HOPT()
	e:SetCondition(aux.OverDriveEffectCondition(condition))
	e:SetCost(aux.OverDriveEffectCost(cost))
	if target then
		e:SetTarget(target)
	end
	e:SetOperation(operation)
	if not hold_registration then
		c:RegisterEffect(e)
	end
	return e
end
--ENERGY
function Card.GetEnergy(c)
	if not Auxiliary.Drives[c] then return false end
	local energy=0
	local te=c:IsHasEffect(EFFECT_DRIVE_ENERGY)
	if type(te:GetValue())=='function' then
		energy=te:GetValue()(te,c)
	else
		energy=te:GetValue()
	end
	if c:IsHasEffect(EFFECT_UPDATE_ENERGY) or c:IsHasEffect(EFFECT_CHANGE_ENERGY) then
		local l={}
		if c:IsHasEffect(EFFECT_UPDATE_ENERGY) then
			for _,v in ipairs({c:IsHasEffect(EFFECT_UPDATE_ENERGY)}) do
				table.insert(l,v)
			end
		end
		if c:IsHasEffect(EFFECT_CHANGE_ENERGY) then
			for _,v in ipairs({c:IsHasEffect(EFFECT_CHANGE_ENERGY)}) do
				table.insert(l,v)
			end
		end
		table.sort(l, function(a,b) return a:GetFieldID() < b:GetFieldID() end)
		for _,ce in ipairs(l) do
			if ce:GetCode()==EFFECT_UPDATE_ENERGY then
				local val=ce:GetValue()
				if aux.GetValueType(val)=="number" then
					energy=energy+val
				else
					energy=energy+val(ce,c)
				end
			else
				local val=ce:GetValue()
				if aux.GetValueType(val)=="number" then
					energy=val
				else
					energy=val(ce,c)
				end
			end
		end
	end
	return energy
end
function Card.GetOriginalEnergy(c)
	if not Auxiliary.Drives[c] then return false end
	local energy=0
	local te=c:IsHasEffect(EFFECT_DRIVE_ORIGINAL_ENERGY)
	if type(te:GetValue())=='function' then
		energy=te:GetValue()(te,c)
	else
		energy=te:GetValue()
	end
	return energy
end

function Card.IsHasEnergy(c)
	return Auxiliary.Drives[c] and c:IsHasEffect(EFFECT_DRIVE_ENERGY)
end
function Card.IsEnergy(c,...)
	for _,en in ipairs({...}) do
		if c:GetEnergy()==en then return true end
	end
	return false
end
function Card.IsEnergyAbove(c,en)
	return c:IsHasEnergy() and c:GetEnergy()>=en
end
function Card.IsEnergyBelow(c,en)
	return c:IsHasEnergy() and c:GetEnergy()<=en
end
function Card.IsCanUpdateEnergy(c,ct,p,r)
	return c:IsHasEnergy() and (ct>=0 or c:IsEnergyAbove(math.abs(ct)))
end
function Card.IsCanChangeEnergy(c,ct,p,r)
	return c:IsHasEnergy() and not c:IsEnergy(ct)
end
function Card.IsCanResetEnergy(c,p,r)
	local ct=c:GetOriginalEnergy()
	return ct and c:IsHasEnergy() and not c:IsEnergy(ct)
end

function Card.UpdateEnergy(c,val,p,r,reset,rc)
	local reset = (type(reset)=="number" or not reset) and reset or 0
	local rc = rc and rc or c
	
	local en=c:GetEnergy()
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_UPDATE_ENERGY)
	e:SetValue(val)
	if reset then
		if r&REASON_EFFECT>0 then
			reset = rc==c and reset|RESET_DISABLE or reset
		end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	if r&REASON_TEMPORARY==0 then
		aux.CheckEnergyOperation(e,p)
	end
	if reset then
		return e,c:GetEnergy()-en
	else
		return e
	end
end
function Card.ChangeEnergy(c,val,p,r,reset,rc)
	local reset = (type(reset)=="number" or not reset) and reset or 0
	local rc = rc and rc or c
	
	local en=c:GetEnergy()
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_CHANGE_ENERGY)
	e:SetValue(val)
	if reset then
		if r&REASON_EFFECT>0 then
			reset = rc==c and reset|RESET_DISABLE or reset
		end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	if r&REASON_TEMPORARY==0 then
		aux.CheckEnergyOperation(e,p)
	end
	if reset then
		return e,c:GetEnergy()
	else
		return e
	end
end
function Card.ResetEnergy(c,p,r,reset,rc)
	local val=c:GetOriginalEnergy()
	if not val then return false end
	local e,en=c:ChangeEnergy(val,p,r,reset,rc)
	return e,en==val
end

--conditions
function Auxiliary.IsExistingEngagedCond(p)
	return	function(e,tp)
				local tp = type(tp)~=nil and tp or e:GetHandlerPlayer()
				local p = (not p or p==0) and tp or 1-tp
				return Duel.GetEngagedCard(p)~=nil
			end
end
function Card.DueToHavingZeroEnergy(c)
	return c:IsReason(REASON_RULE) and c:HasFlagEffect(FLAG_ZERO_ENERGY)
end
function Auxiliary.DueToHavingZeroEnergyCond(e)
	local c=e:GetHandler()
	return c:IsReason(REASON_RULE) and c:HasFlagEffect(FLAG_ZERO_ENERGY)
end