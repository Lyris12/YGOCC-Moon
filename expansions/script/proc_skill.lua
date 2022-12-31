--created by Glitchy, coded by Lyris
--Not yet finalized values
--Custom constants
TYPE_SKILL		=0x2000000000
TYPE_CUSTOM		=TYPE_CUSTOM|TYPE_SKILL
CTYPE_SKILL		=0x20
CTYPE_CUSTOM	=CTYPE_CUSTOM|CTYPE_SKILL

--Custom Type Table
Auxiliary.Skills={} --number as index = card, card as index = function() is_pendulum

--overwrite functions
local get_type, get_orig_type, get_prev_type_field = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Skills[c] then
		tpe=tpe|TYPE_SKILL
		local ispen,isspell=Auxiliary.Skills[c]()
		if not ispen then
			tpe=tpe&~TYPE_PENDULUM
		end
		if c:IsLocation(LOCATION_PZONE) and not isspell then
			tpe=tpe&~TYPE_SPELL
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Skills[c] then
		tpe=tpe|TYPE_SKILL
		if not Auxiliary.Skills[c]() then
			tpe=tpe&~TYPE_PENDULUM
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Skills[c] then
		tpe=tpe|TYPE_SKILL
		local ispen,isspell=Auxiliary.Skills[c]()
		if not ispen then
			tpe=tpe&~TYPE_PENDULUM
		end
		if c:IsLocation(LOCATION_PZONE) and not isspell then
			tpe=tpe&~TYPE_SPELL
		end
	end
	return tpe
end

--Custom Functions
function Auxiliary.AddOrigSkillType(c,ispendulum,is_spell)
	table.insert(Auxiliary.Skills,c)
	Auxiliary.Customs[c]=true
	local ispendulum=ispendulum==nil and false or ispendulum
	local is_spell=is_spell==nil and false or is_spell
	Auxiliary.Skills[c]=function() return ispendulum, is_spell end
end
function Auxiliary.EDSkillProperties(c)
	--ED Skill Properties
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(Auxiliary.skillcon)
	e1:SetValue(Auxiliary.skill_efilter)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(0)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_USE_AS_COST)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
function Auxiliary.skillcon(e)
	return e:GetHandler():IsFaceup() and e:GetHandler():GetFlagEffect(99988871)>0
end
function Auxiliary.skill_efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
