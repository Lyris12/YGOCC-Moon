--Aircaster Claire
--created by Alastar Rainford, coded by Lyris
--New auxiliaries by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddAircasterExcavateEffect(c,3,EFFECT_TYPE_TRIGGER_O,0)
	aux.AddAircasterEquipEffect(c,1)
	--immunity
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.econ)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
end
function s.econ(e)
	return e:GetHandler():IsSpell(TYPE_EQUIP)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER)
end