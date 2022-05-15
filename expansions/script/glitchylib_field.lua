--CONTINUOUS EFFECTS (EFFECT_TYPE_FIELD)
-----------------------------------------------------------------------
function Card.UpdateATKField(c,atk,range,selfzones,oppozones,f)
	if not range then range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE end
	if not selfzones then selfzones=0 end
	if type(oppozones)=="boolean" and oppozones==true then
		oppozones=selfzones
	elseif not oppozones then
		oppozones=0
	end
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetRange(range)
	e:SetCode(EFFECT_UPDATE_ATTACK)
	e:SetTargetRange(selfzones,oppozones)
	e:SetTarget(f)
	e:SetValue(atk)
	c:RegisterEffect(e)
	return e
end
function Card.UpdateDEFField(c,def,range,selfzones,oppozones,f)
	if not range then range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE end
	if not selfzones then selfzones=0 end
	if type(oppozones)=="boolean" and oppozones==true then
		oppozones=selfzones
	elseif not oppozones then
		oppozones=0
	end
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetRange(range)
	e:SetCode(EFFECT_UPDATE_DEFENSE)
	e:SetTargetRange(selfzones,oppozones)
	e:SetTarget(f)
	e:SetValue(def)
	c:RegisterEffect(e)
	return e
end
function Card.UpdateATKDEFField(c,atk,def,range,selfzones,oppozones,f)
	if not range then range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE end
	if not selfzones then selfzones=0 end
	if type(oppozones)=="boolean" and oppozones==true then
		oppozones=selfzones
	elseif not oppozones then
		oppozones=0
	end
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetRange(range)
	e:SetCode(EFFECT_UPDATE_ATTACK)
	e:SetTargetRange(selfzones,oppozones)
	e:SetTarget(f)
	e:SetValue(atk)
	c:RegisterEffect(e)
	local e1x=e:Clone()
	e1x:SetCode(EFFECT_UPDATE_DEFENSE)
	e1x:SetValue(def)
	c:RegisterEffect(e1x)
	return e,e1x
end

function Card.UpdateLevelField(c,lv,range,selfzones,oppozones,f)
	if not range then range=c:GetOriginalType()&TYPE_FIELD>0 and LOCATION_FZONE or c:GetOriginalType()&TYPE_ST>0 and LOCATION_SZONE or LOCATION_MZONE end
	if not selfzones then selfzones=0 end
	if type(oppozones)=="boolean" and oppozones==true then
		oppozones=selfzones
	elseif not oppozones then
		oppozones=0
	end
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetRange(range)
	e:SetCode(EFFECT_UPDATE_LEVEL)
	e:SetTargetRange(selfzones,oppozones)
	e:SetTarget(f)
	e:SetValue(lv)
	c:RegisterEffect(e)
	return e
end