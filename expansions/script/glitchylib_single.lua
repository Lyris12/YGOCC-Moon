SCRIPT_AS_EQUIP = false
-----------------------------------------------------------------------

--Stats
function Card.UpdateATK(c,atk,reset,rc)
	local type = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(type)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_ATTACK)
	e:SetValue(atk)
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end
function Card.UpdateDEF(c,def,reset,rc)
	local type = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(type)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_DEFENSE)
	e:SetValue(def)
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end
function Card.UpdateATKDEFF(c,atk,def,reset,rc)
	local type = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(type)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_ATTACK)
	e:SetValue(atk)
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	local e1x=e:Clone()
	e1x:SetCode(EFFECT_UPDATE_DEFENSE)
	e1x:SetValue(def)
	c:RegisterEffect(e1x)
	return e,e1x
end

function Card.UpdateLevel(c,lv,reset,rc)
	local type = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(type)
	if not SCRIPT_AS_EQUIP then
		e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e:SetRange(range)
	end
	e:SetCode(EFFECT_UPDATE_LEVEL)
	e:SetValue(lv)
	if reset then
		if type(reset)~="number" then reset=0 end
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	end
	c:RegisterEffect(e)
	return e
end

--Effect
function Card.EffectsCannotBeNegated(c,reset,rc)
	local type = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
	local e=Effect.CreateEffect(rc)
	e:SetType(type)
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

--Protections
function Card.BattleProtection(c,reset,rc)
	local type = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
	local e=Effect.CreateEffect(c)
	e:SetType(type)
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
	local type = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local e=Effect.CreateEffect(c)
	e:SetType(type)
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
	local type = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local e=Effect.CreateEffect(c)
	e:SetType(type)
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
	local type = (SCRIPT_AS_EQUIP==true) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_SINGLE
	local rc = rc and rc or c
	local range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE
	local e=Effect.CreateEffect(c)
	e:SetType(type)
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