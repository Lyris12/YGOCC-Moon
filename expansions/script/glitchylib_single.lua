SCRIPT_AS_EQUIP = false
-----------------------------------------------------------------------

--Stats
function Card.UpdateATK(c,atk,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local reset = type(reset)=="number" and reset or 0
	local rc = rc and rc or c
	
	local att=c:GetAttack()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_ATTACK)
	e:SetValue(atk)
	if reset then
		reset = rc==c and reset|RESET_DISABLE or reset
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	
	if reset then
		return e,c:GetAttack()-att
	else
		return e
	end
end
function Card.UpdateDEF(c,def,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local reset = type(reset)=="number" and reset or 0
	local rc = rc and rc or c
	
	local df=c:GetDefense()
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_DEFENSE)
	e:SetValue(def)
	if reset then
		reset = rc==c and reset|RESET_DISABLE or reset
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	if reset then
		return e,c:GetDefense()-df
	else
		return e
	end
end
function Card.UpdateATKDEFF(c,atk,def,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local reset = type(reset)=="number" and reset or 0
	local rc = rc and rc or c
	
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_ATTACK)
	e:SetValue(atk)
	local e1x=e:Clone()
	e1x:SetCode(EFFECT_UPDATE_DEFENSE)
	e1x:SetValue(def)
	if reset then
		reset = rc==c and reset|RESET_DISABLE or reset
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
		e1x:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	c:RegisterEffect(e1x)
	return e,e1x
end
function Card.ChangeATK(c,atk,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local reset = type(reset)=="number" and reset or 0
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_SET_ATTACK_FINAL)
	e:SetValue(atk)
	if reset then
		reset = rc==c and reset|RESET_DISABLE or reset
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end
function Card.ChangeDEF(c,def,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local reset = type(reset)=="number" and reset or 0
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e:SetValue(def)
	if reset then
		reset = rc==c and reset|RESET_DISABLE or reset
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end
function Card.HalveATK(c,reset,rc)
	local atk=math.floor(c:GetAttack()/2)
	return c:ChangeATK(atk,reset,rc)
end
function Card.HalveDEF(c,reset,rc)
	local def=math.floor(c:GetDefense()/2)
	return c:ChangeDEF(def,reset,rc)
end
function Card.DoubleATK(c,reset,rc)
	local atk=c:GetAttack()*2
	return c:ChangeATK(atk,reset,rc)
end
function Card.DoubleDEF(c,reset,rc)
	local def=math.floor(c:GetDefense()/2)
	return c:ChangeDEF(def,reset,rc)
end

function Card.ChangeAttribute(c,attr,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local reset = type(reset)=="number" and reset or 0
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e:SetValue(attr)
	if reset then
		reset = rc==c and reset|RESET_DISABLE or reset
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end

function Card.ChangeRace(c,race,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local reset = type(reset)=="number" and reset or 0
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_CHANGE_RACE)
	e:SetValue(race)
	if reset then
		reset = rc==c and reset|RESET_DISABLE or reset
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end

function Card.UpdateLevel(c,lv,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local reset = type(reset)=="number" and reset or 0
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_LEVEL)
	e:SetValue(lv)
	if reset then
		reset = rc==c and reset|RESET_DISABLE or reset
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end
function Card.ChangeLevel(c,lv,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local reset = type(reset)=="number" and reset or 0
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_CHANGE_LEVEL)
	e:SetValue(lv)
	if reset then
		reset = rc==c and reset|RESET_DISABLE or reset
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end

--Effect
function Card.EffectsCannotBeNegated(c,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(typ)
	e:SetCode(EFFECT_CANNOT_DISABLE)
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end
function Card.EffectActivationsCannotBeNegated(c,reset,rc)
	if not SCRIPT_AS_EQUIP then return false end
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetRange(LOCATION_SZONE)
	e:SetCode(EFFECT_CANNOT_INACTIVATE)
	e:SetCondition(aux.IsEquippedCond)
	e:SetValue(	function (eff,ct)
					local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
					return te:GetHandler()==eff:GetHandler():GetEquipTarget()
				end
			  )
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end
function Card.ActivatedEffectsCannotBeNegated(c,reset,rc)
	if not SCRIPT_AS_EQUIP then return false end
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetRange(LOCATION_SZONE)
	e:SetCode(EFFECT_CANNOT_DISEFFECT)
	e:SetCondition(aux.IsEquippedCond)
	e:SetValue(	function (eff,ct)
					local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
					return te:GetHandler()==eff:GetHandler():GetEquipTarget()
				end
			  )
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end

--Concessions
function Card.CanAttackDirectly(c,reset,rc)
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_DIRECT_ATTACK)
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
end
function Card.MustAttack(c,reset,rc,cond)
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_MUST_ATTACK)
	if cond then
		e:SetCondition(cond)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
end

--Protections
function Card.BattleProtection(c,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
	local e=Effect.CreateEffect(c)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(MZONE)
	end
	e:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e:SetValue(1)
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end
function Card.EffectProtection(c,oppo_only,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local e=Effect.CreateEffect(c)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	if not oppo_only then
		e:SetValue(1)
	else
		e:SetValue(function(eff,re,rp) return rp~=eff:GetHandlerPlayer() end)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end
function Card.TargetProtection(c,oppo_only,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local e=Effect.CreateEffect(c)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	if not oppo_only then
		e:SetValue(1)
	else
		e:SetValue(aux.tgoval)
	end
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end

function Card.FirstTimeProtection(c,each_turn,battle,effect,oppo_only,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local e=Effect.CreateEffect(c)
	e:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		if each_turn then
			e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		else
			e:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_NO_TURN_RESET)
		end
		e:SetRange(range)
	else
		if not each_turn then
			e:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		end
	end
	e:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e:SetCountLimit(1)
	e:SetValue(	function (eff,re,r,rp)
					return (not battle or r&REASON_BATTLE>0) and (not effect or r&REASON_EFFECT>0 and (not oppo_only or rp~=eff:GetHandlerPlayer()))
				end
			  )
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end

function Card.CannotBeTributed(c,reset,rc)
	local typ = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	--
	local e4=Effect.CreateEffect(c)
	e4:SetType(typ)
	if not SCRIPT_AS_EQUIP then
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e4:SetRange(range)
	end
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	e4:SetValue(1)
	if reset then
		if type(reset)~="number" then reset=0 end
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e4)
	--
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e5)
	return e4,e5
end

--Restriction and Rules
function Card.CannotBeSet(c,reset,rc)
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_CANNOT_SSET)
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
end

function Card.CannotBeMaterial(c,ed_types,f,reset,rc)
	local rc = rc and rc or c
	local effs={}
	local elist={235,236,238,239,624,825}
	local list={TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK,TYPE_BIGBANG,TYPE_TIMELEAP}
	for i,typ in ipairs(list) do
		if ed_types&typ==typ then
			local e=Effect.CreateEffect(rc)
			e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e:SetType(EFFECT_TYPE_SINGLE)
			e:SetCode(elist[i])
			if f then
				e:SetValue(function(eff,cc) if not cc then return false end return f(cc,eff) end)
			end
			if reset then
				if type(reset)~="number" then reset=0 end
				e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
			end
			c:RegisterEffect(e)
			table.insert(effs,e)
		end
	end
	if #effs>0 then
		return table.unpack(effs)
	else
		return false
	end
end

function Card.MustBeSSedByOwnProcedure(c,rc)
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e)
end