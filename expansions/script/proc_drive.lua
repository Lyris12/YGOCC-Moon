DRIVE_STRINGS					=34842

TYPE_DRIVE						=0x40000000000000
TYPE_CUSTOM						=TYPE_CUSTOM|TYPE_DRIVE
CTYPE_DRIVE						=0x400000
CTYPE_CUSTOM					=CTYPE_CUSTOM|CTYPE_DRIVE

SUMMON_TYPE_DRIVE				=SUMMON_TYPE_SPECIAL+348

REASON_DRIVE	= 0x80000000000

FLAG_ENGAGE = 348
FLAG_ZERO_ENERGY = 349

EFFECT_DRIVE_ORIGINAL_ENERGY 		= 34843
EFFECT_DRIVE_ENERGY 				= 34844
EFFECT_UPDATE_ENERGY				= 34845
EFFECT_CHANGE_ENERGY				= 34846
EFFECT_REPLACE_UPDATE_ENERGY_COST	= 34847
EFFECT_IGNORE_OVERDRIVE_COST		= 34848

EVENT_ENGAGE					= EVENT_CUSTOM+34843
EVENT_ENERGY_CHANGE				= EVENT_CUSTOM+29935986

Auxiliary.Drives={}

local get_type, get_orig_type, get_prev_type_field, get_active_type, is_active_type, get_reason, get_fusion_type, get_synchro_type, get_xyz_type, get_link_type, get_ritual_type = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Effect.GetActiveType, Effect.IsActiveType, Card.GetReason, Card.GetFusionType, Card.GetSynchroType, Card.GetXyzType, Card.GetLinkType, Card.GetRitualType

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
Effect.GetActiveType=function(e)
	local tpe=get_active_type(e)
	local c = e:GetType()&0x7f0>0 and e:GetHandler() or e:GetOwner()
	if not (e:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsType(TYPE_PENDULUM)) and c:IsType(TYPE_DRIVE) then
		tpe=tpe|TYPE_DRIVE
	end
	return tpe
end
Effect.IsActiveType=function(e,typ)
	return e:GetActiveType()&typ>0
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
	local echk=Effect.CreateEffect(c)
	echk:SetDescription(aux.Stringid(DRIVE_STRINGS,1))
	echk:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_CONTINUOUS)
	echk:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	echk:SetRange(LOCATION_HAND)
	echk:SetCondition(Auxiliary.DriveEffectConditionDeveloper())
	echk:SetTarget(	function(ce,tp,eg,ep,ev,re,r,rp,chk)
						if chk==0 then return true end
						Duel.SetChainLimit(aux.FALSE)
					end
				  )
	echk:SetOperation(Auxiliary.CheckEnergyOperationDeveloper)
	c:RegisterEffect(echk)
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
function Auxiliary.DriveSelfToGraveOp(cc)
	cc:RegisterFlagEffect(FLAG_ZERO_ENERGY,RESET_EVENT+RESETS_STANDARD-RESET_TOGRAVE,EFFECT_FLAG_IGNORE_IMMUNE,1)
	if Duel.SendtoGrave(cc,REASON_RULE)<=0 or not cc:IsLocation(LOCATION_GRAVE) then
		cc:ResetFlagEffect(FLAG_ZERO_ENERGY)
	end
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
		if e and e.GetLabel then
			local label,_=e:GetLabel()
			if label==FLAG_ENGAGE then
				return true
			end
		end
	end
	return c:HasFlagEffect(FLAG_ENGAGE)
end
function Card.Engage(c,e,tp)
	if not c:IsLocation(LOCATION_HAND) or not c:IsCanEngage(tp) then return end
	Duel.Hint(HINT_CARD,tp,c:GetOriginalCode())
	aux.CheckEnergyOperation(c,tp)
	local eid=e:GetFieldID()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetLabel(FLAG_ENGAGE,eid)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	c:RegisterFlagEffect(FLAG_ENGAGE,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(DRIVE_STRINGS,3))
	Duel.RaiseEvent(c,EVENT_ENGAGE,e,REASON_EFFECT,tp,tp,0)
	Duel.RaiseSingleEvent(c,EVENT_ENGAGE,e,REASON_EFFECT,tp,tp,0)
	--
	-- local e5=Effect.CreateEffect(e:GetHandler())
	-- e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	-- e5:SetCode(EVENT_ADJUST)
	-- e5:SetRange(LOCATION_HAND)
	-- e5:SetCondition(Auxiliary.DriveSelfToGraveCon)
	-- e5:SetOperation(function(ce) Duel.SendtoGrave(ce:GetHandler(),REASON_RULE) end)
	-- e5:SetReset(RESET_EVENT+RESETS_STANDARD)
	-- c:RegisterEffect(e5)
end
function Card.GetEngagedID(c)
	for _,e in ipairs({c:IsHasEffect(EFFECT_PUBLIC)}) do
		if e and e.GetLabel then
			local label1,label2=e:GetLabel()
			if label==FLAG_ENGAGE then
				return label2
			end
		end
	end
	return 0
end

function Auxiliary.EngageCondition(e,tp)
	local c=e:GetHandler()
	if tp~=c:GetControler() then return false end
	return c:IsLocation(LOCATION_HAND) and c:IsCanEngage(tp)
end
function Auxiliary.EngageOperation(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	if not c:IsLocation(LOCATION_HAND) or not c:IsCanEngage(tp) then return end
	Duel.Hint(HINT_CARD,tp,c:GetOriginalCode())
	aux.CheckEnergyOperation(e,tp)
	Duel.ConfirmCards(1-tp,c)
	local eid=e:GetFieldID()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetLabel(FLAG_ENGAGE,eid)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
	c:RegisterFlagEffect(FLAG_ENGAGE,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(DRIVE_STRINGS,3))
	Duel.RaiseEvent(c,EVENT_ENGAGE,e,REASON_RULE,tp,tp,0)
	Duel.RaiseSingleEvent(c,EVENT_ENGAGE,e,REASON_RULE,tp,tp,0)
	--
	-- local e5=Effect.CreateEffect(c)
	-- e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	-- e5:SetCode(EVENT_ADJUST)
	-- e5:SetRange(LOCATION_HAND)
	-- e5:SetCondition(Auxiliary.DriveSelfToGraveCon)
	-- e5:SetOperation(Auxiliary.DriveSelfToGraveOp)
	-- e5:SetReset(RESET_EVENT+RESETS_STANDARD)
	-- c:RegisterEffect(e5)
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
function Duel.GetEngagedCards()
	local g=Duel.GetMatchingGroup(Card.IsEngaged,tp,LOCATION_HAND,LOCATION_HAND,nil)
	return g
end

--CHECK ENERGY
function Auxiliary.CheckEnergyOperation(e,tp)
	local c = aux.GetValueType(e)=="Effect" and e:GetHandler() or e
	local en=c:GetEnergy()
	Duel.Hint(HINT_SOUND,0,aux.Stringid(DRIVE_STRINGS,4))
	if en<=20 and en>0 then
		c:SetTurnCounter(en)
	else
		Duel.AnnounceNumber(tp,en)
	end
end
function Auxiliary.CheckEnergyOperationDeveloper(e)
	local tp=e:GetHandler():GetControler()
	if Duel.GetTurnPlayer()~=tp then
		tp=1-tp
	end
	if not Duel.PlayerHasFlagEffect(tp,FLAG_ENGAGE) and not Duel.PlayerHasFlagEffect(tp,FLAG_ENGAGE+1) then
		if Duel.SelectYesNo(tp,aux.Stringid(DRIVE_STRINGS,5)) then
			Duel.RegisterFlagEffect(tp,FLAG_ENGAGE,0,0,1)
		end
		Duel.RegisterFlagEffect(tp,FLAG_ENGAGE+1,0,0,1)
	end
	aux.CheckEnergyOperation(e,tp)
end


--DRIVE EFFECTS
function Auxiliary.DriveEffectConditionDeveloper(cond)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return not Duel.PlayerHasFlagEffect(tp,FLAG_ENGAGE) and e:GetHandler():IsEngaged() and (not cond or cond(e,tp,eg,ep,ev,re,r,rp))
			end
end
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
DRIVE_SIMPLE_COST = false
function Auxiliary.DriveEffectCost(ct,cost,setlabel,ct2)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				DRIVE_SIMPLE_COST=true
				if setlabel then e:SetLabel(1) end
				local c=e:GetHandler()
				if chk==0 then
					local check = c:IsCanUpdateEnergy(ct,tp,REASON_COST,e,ct2) and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,chk))
					DRIVE_SIMPLE_COST=false
					return check
				end
				c:UpdateEnergy(ct,tp,REASON_COST,true,c,e,ct2)
				if cost then
					cost(e,tp,eg,ep,ev,re,r,rp,chk)
				end
			end
end
function Auxiliary.OverDriveEffectCost(cost,setlabel)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				DRIVE_SIMPLE_COST=true
				if setlabel then e:SetLabel(1) end
				local c=e:GetHandler()
				local enchk=c:IsCanChangeEnergy(0,tp,REASON_COST)
				local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_IGNORE_OVERDRIVE_COST)}
				if chk==0 then
					local ov_alt=false
					if enchk then
						for _,ce in ipairs{egroup} do
							if aux.GetValueType(ce)=="Effect" and ce:CheckCountLimit(tp) then
								ov_alt=true
								break
							end
						end
					end
					local check = (enchk or ov_alt) and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,chk))
					DRIVE_SIMPLE_COST=false
					return check
				end
				local available_effects = {}
				local g=Group.CreateGroup()
				Debug.Message(#egroup)
				for _,ce in ipairs(egroup) do
					if aux.GetValueType(ce)=="Effect" and ce:CheckCountLimit(tp) then
						g:AddCard(ce:GetOwner())
						table.insert(available_effects,ce)
					end
				end
				if #available_effects>0 and (not enchk or Duel.SelectYesNo(tp,STRING_ASK_IGNORE_OVERDRIVE_COST)) then
					local tc=g:Select(tp,1,1,nil):GetFirst()
					local specific_available_effects, options = {}, {}
					local ce
					for _,aveff in ipairs(available_effects) do
						if aveff:GetOwner()==tc then
							table.insert(specific_available_effects,aveff)
							table.insert(options,aveff:GetDescription())
						end
					end
					if #specific_available_effects>1 then
						ce=specific_available_effects[Duel.SelectOption(tp,table.unpack(options))+1]
					else
						ce=specific_available_effects[1]
					end
					Duel.Hint(HINT_CARD,tp,tc:GetOriginalCode())
					ce:UseCountLimit(tp)
				else
					c:ChangeEnergy(0,tp,REASON_COST,true)
				end
				if cost then
					cost(e,tp,eg,ep,ev,re,r,rp,chk)
				end
			end
end

if not DRIVE_EFFECTS_TABLE then
	DRIVE_EFFECTS_TABLE = {}
end
if not OVERDRIVE_EFFECTS_TABLE then
	OVERDRIVE_EFFECTS_TABLE = {}
end
function Card.DriveEffect(c,energycost,desc,category,typ,property,event,condition,cost,target,operation,hold_registration,setlabelcost,shopt)
	local energy_for_legal_activation
	if type(energycost)=="table" then
		energy_for_legal_activation = energycost[2]
		energycost = energycost[1]
		if energy_for_legal_activation==true then
			energy_for_legal_activation = math.abs(energycost) + 1
		end
	end
	local typ = typ or EFFECT_TYPE_IGNITION
	local property = type(property)~="boolean" and property or property==true and EFFECT_FLAG_CARD_TARGET
	local event = event
	local hint1,hint2
	
	if typ~=EFFECT_TYPE_IGNITION and not event then
		event=EVENT_FREE_CHAIN
	elseif type(event)=="table" then
		local ct=#event
		hint2 = event[ct]
		event = event[1]
		if ct==3 then
			hint1 = event[2]
		end
	elseif typ==EFFECT_TYPE_QUICK_O then
		hint2 = RELEVANT_TIMINGS
	end
	
	local e=Effect.CreateEffect(c)
	if desc then
		e:Desc(desc)
	end
	if category then
		if type(category)=="table" then
			e:SetCategory(category[1])
			e:SetCustomCategory(category[2])
		else
			e:SetCategory(category)
		end
	end
	e:SetType(typ)
	if property then
		e:SetProperty(property)
	end
	if event then
		e:SetCode(event)
	end
	if hint then
		e:SetHintTiming(hint1,hint2)
	end
	e:SetRange(LOCATION_HAND)
	if typ~=EFFECT_TYPE_SINGLE and typ~=EFFECT_TYPE_FIELD and typ&EFFECT_TYPE_CONTINUOUS==0 then
		if not shopt then
			e:HOPT()
		else
			e:SHOPT()
		end
	end
	e:SetCondition(aux.DriveEffectCondition(condition))
	if energycost~=0 then
		e:SetCost(aux.DriveEffectCost(energycost,cost,setlabelcost,energy_for_legal_activation))
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
	table.insert(DRIVE_EFFECTS_TABLE,e)
	return e
end
function Effect.IsDriveEffect(e)
	return aux.FindInTable(DRIVE_EFFECTS_TABLE,e)
end

function Card.OverDriveEffect(c,desc,category,typ,property,event,condition,cost,target,operation,hold_registration,setlabelcost,shopt)
	local typ = typ or EFFECT_TYPE_IGNITION
	local property = type(property)~="boolean" and property or property==true and EFFECT_FLAG_CARD_TARGET
	local event = event
	if typ~=EFFECT_TYPE_IGNITION and not event then
		event=EVENT_FREE_CHAIN
	end
	local e=Effect.CreateEffect(c)
	if desc then
		e:Desc(desc)
	end
	if category then
		if type(category)=="table" then
			e:SetCategory(category[1])
			e:SetCustomCategory(category[2])
		else
			e:SetCategory(category)
		end
	end
	e:SetType(typ)
	if property then
		e:SetProperty(property)
	end
	if event then
		e:SetCode(event)
	end
	e:SetRange(LOCATION_HAND)
	if not shopt then
		e:HOPT()
	else
		e:SHOPT()
	end
	e:SetCondition(aux.OverDriveEffectCondition(condition))
	e:SetCost(aux.OverDriveEffectCost(cost,setlabelcost))
	if target then
		e:SetTarget(target)
	end
	e:SetOperation(operation)
	if not hold_registration then
		c:RegisterEffect(e)
	end
	table.insert(DRIVE_EFFECTS_TABLE,e)
	table.insert(OVERDRIVE_EFFECTS_TABLE,e)
	return e
end
function Effect.IsOverDriveEffect(e)
	return aux.FindInTable(OVERDRIVE_EFFECTS_TABLE,e)
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

function Card.CheckZeroEnergySelfDestroy(c,ct)
	return ct<0 and c:IsEnergyBelow(math.abs(ct)) --futureproofing
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

function Duel.GetTotalEnergy()
	local g=Duel.GetEngagedCards()
	if not g or #g<=0 then return 0 end
	local ct=0
	for tc in aux.Next(g) do
		ct=ct+tc:GetEnergy()
	end
	return ct
end

function Card.IsCanUpdateEnergy(c,ct,p,r,e,ct2)
	if not c:IsHasEnergy() then return false end
	if not ct2 then ct2=ct end
	local enchk = ct>=0 or c:IsEnergyAbove(math.abs(ct2))
	if DRIVE_SIMPLE_COST and not enchk and r&REASON_COST==REASON_COST and r&REASON_REPLACE==0 then
		local egroup={Duel.IsPlayerAffectedByEffect(p,EFFECT_REPLACE_UPDATE_ENERGY_COST)}
		for _,ce in ipairs(egroup) do
			if ce and ce.SetLabel then
				local cond=ce:GetCondition()
				if ce:CheckCountLimit(p) and (not cond or cond(ce,c,e,p,ct)) then
					enchk=true
				end
			end
		end
	end
	return enchk
end
function Card.IsCanIncreaseOrDecreaseEnergy(c,ct,p,r)
	return c:IsCanUpdateEnergy(ct,p,r) or c:IsCanUpdateEnergy(-ct,p,r)
end
function Card.IsCanChangeEnergy(c,ct,p,r,e)
	return c:IsHasEnergy() and not c:IsEnergy(ct)
end
function Card.IsCanResetEnergy(c,p,r)
	local ct=c:GetOriginalEnergy()
	return ct and c:IsHasEnergy() and not c:IsEnergy(ct)
end

function Card.UpdateEnergy(c,val,p,r,reset,rc,e,val2)
	local reset = (type(reset)=="number" or not reset) and reset or 0
	local rc = rc and rc or c
	if not val2 then val2=val end
	
	local enchk = val>=0 or c:IsEnergyAbove(math.abs(val2))
	if r&REASON_COST==REASON_COST and r&REASON_REPLACE==0 then
		local available_effects = {}
		local g=Group.CreateGroup()
		local egroup={Duel.IsPlayerAffectedByEffect(p,EFFECT_REPLACE_UPDATE_ENERGY_COST)}
		for _,ce in ipairs(egroup) do
			if ce and ce.SetLabel then
				local cond=ce:GetCondition()
				if ce:CheckCountLimit(p) and (not cond or cond(ce,c,e,p,ct)) then
					g:AddCard(ce:GetOwner())
					table.insert(available_effects,ce)
				end
			end
		end
		if #available_effects>0 and (not enchk or Duel.SelectYesNo(p,STRING_ASK_REPLACE_UPDATE_ENERGY_COST)) then
			local tc=g:Select(p,1,1,nil):GetFirst()
			local specific_available_effects, options = {}, {}
			local ce
			for _,aveff in ipairs(available_effects) do
				if aveff:GetOwner()==tc then
					table.insert(specific_available_effects,aveff)
					table.insert(options,aveff:GetDescription())
				end
			end
			if #specific_available_effects>1 then
				ce=specific_available_effects[Duel.SelectOption(p,table.unpack(options))+1]
			else
				ce=specific_available_effects[1]
			end
			local op=ce:GetOperation()
			local res=op(ce,c,e,p,ct)
			if res then
				ce:UseCountLimit(p)
			end
			return res
		end
	end
	
	local en=c:GetEnergy()
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_UPDATE_ENERGY)
	e:SetCondition(aux.ResetIfNotEngaged(c:GetEngagedID()))
	e:SetValue(val)
	if reset then
		if r&REASON_EFFECT>0 then
			reset = rc==c and reset|RESET_DISABLE or reset
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset)
	end
	c:RegisterEffect(e)
	local diff=c:GetEnergy()-en
	if r&REASON_TEMPORARY==0 then
		aux.CheckEnergyOperation(c,p)
		Duel.RaiseEvent(c,EVENT_ENERGY_CHANGE,e,r,p,c:GetControler(),diff)
		if c:GetEnergy()==0 then
			Auxiliary.DriveSelfToGraveOp(c)
		end
	end
	if reset then
		return e,diff
	else
		return e
	end
end
function Card.IncreaseOrDecreaseEnergy(c,val,p,r,reset,rc,e,val2)
	local n={}
	for i=-1,1,2 do
		local signed_val=math.abs(val)*i
		if c:IsCanUpdateEnergy(signed_val,p,r) then
			table.insert(n,signed_val)
		end
	end
	if #n==0 then return end
	local val=Duel.AnnounceNumber(tp,table.unpack(n))
	return c:UpdateEnergy(val,p,r,reset,rc,e,val2)
end
	
function Card.ChangeEnergy(c,val,p,r,reset,rc)
	local reset = (type(reset)=="number" or not reset) and reset or 0
	local rc = rc and rc or c
	
	local en=c:GetEnergy()
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_CHANGE_ENERGY)
	e:SetCondition(aux.ResetIfNotEngaged(c:GetEngagedID()))
	e:SetValue(val)
	if reset then
		if r&REASON_EFFECT>0 then
			reset = rc==c and reset|RESET_DISABLE or reset
		end
		e:SetReset(RESET_EVENT|RESETS_STANDARD|reset)
	end
	c:RegisterEffect(e)
	local new_en=c:GetEnergy()
	if r&REASON_TEMPORARY==0 then
		aux.CheckEnergyOperation(c,p)
		Duel.RaiseEvent(c,EVENT_ENERGY_CHANGE,e,r,p,c:GetControler(),new_en-en)
		if c:GetEnergy()==0 then
			Auxiliary.DriveSelfToGraveOp(c)
		end
	end
	if reset then
		return e,new_en,new_en-en
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

--announce
function Duel.AnnounceEnergyUpdate(p,c,min,max,up,r,e)
	if not min then min=1 end
	if not max then max=c:GetEnergy() end
	if min<0 and max<0 and math.abs(min)<math.abs(max) then
		min,max = max,min
	end
	if not up then up=p end
	if not r then r=REASON_EFFECT end
	local n={}
	for i=min,max do
		if i~=0 and c:IsCanUpdateEnergy(i,up,r,e) then
			table.insert(n,i)
		end
	end
	Duel.HintMessage(tp,STRING_INPUT_ENERGY)
	local ct=Duel.AnnounceNumber(tp,table.unpack(n))
	return ct
end

--conditions
function Auxiliary.IsExistingEngagedCond(p)
	if p then
		return	function(e,tp)
					local tp = type(tp)~=nil and tp or e:GetHandlerPlayer()
					local p = (p==0) and tp or 1-tp
					return Duel.GetEngagedCard(p)~=nil
				end
	else
		return	function(e)
					return Duel.GetEngagedCards():GetCount()>0
				end
	end
end
function Card.DueToHavingZeroEnergy(c)
	return c:IsReason(REASON_RULE) and c:HasFlagEffect(FLAG_ZERO_ENERGY)
end
function Auxiliary.DueToHavingZeroEnergyCond(e)
	local c=e:GetHandler()
	return c:IsReason(REASON_RULE) and c:HasFlagEffect(FLAG_ZERO_ENERGY)
end
function Auxiliary.ResetIfNotEngaged(eid)
	return	function(e)
				local c=e:GetHandler()
				if not c:IsLocation(LOCATION_HAND) then return true end
				if not c:IsEngaged() or c:GetEngagedID()~=eid then
					e:Reset()
					return false
				end
				return true
			end
end

--costs
function Auxiliary.UpdateEnergyCost(min,max,f)
	if not min then min=1 end
	if max and min~=max then
		if min<0 and max<0 and math.abs(min)<math.abs(max) then
			min,max = max,min
		end
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					local ec=Duel.GetEngagedCard(tp)
					if chk==0 then
						if not ec or (f and not f(ec,e,tp,eg,ep,ev,re,r,rp)) then return false end
						for i=min,max do
							if i~=0 and ec:IsCanUpdateEnergy(i,tp,REASON_COST,e) then
								return true
							end
						end
						return false
					end
					local ct=Duel.AnnounceEnergyUpdate(tp,ec,min,max,tp,REASON_COST,e)
					ec:UpdateEnergy(ct,tp,REASON_COST,true,c,e)
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					local ec=Duel.GetEngagedCard(tp)
					local min=min
					if type(min)=="function" then
						min=min(ec,e,tp,eg,ep,ev,re,r,rp)
					end
					if chk==0 then
						if not ec or (f and not f(ec,e,tp,eg,ep,ev,re,r,rp)) then return false end
						return ec:IsCanUpdateEnergy(min,tp,REASON_COST,e)
					end
					ec:UpdateEnergy(min,tp,REASON_COST,true,c,e)
				end
	end
end

--operations
function Duel.SearchAndEngage(tc,e,tp)
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and aux.PLChk(tc,tp,LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,Group.FromCards(tc))
		if tc:IsMonster(TYPE_DRIVE) and tc:IsCanEngage(tp) and Duel.SelectYesNo(tp,STRING_ASK_ENGAGE) then
			tc:Engage(e,tp)
			return tc:IsEngaged()
		end
	end
	return false
end