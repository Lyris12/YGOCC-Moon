function Card.FieldEffect(c,code,range,selfzones,oppozones,f,val,cond)
--CONTINUOUS EFFECTS (EFFECT_TYPE_FIELD)
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
	e:SetCode(code)
	if cond then
		e:SetCondition(cond)
	end
	e:SetTargetRange(selfzones,oppozones)
	if f then
		e:SetTarget(f)
	end
	e:SetValue(val)
	--c:RegisterEffect(e)
	return e
end

-----------------------------------------------------------------------
function Card.UpdateATKField(c,atk,range,selfzones,oppozones,f,cond)
	local e=c:FieldEffect(EFFECT_UPDATE_ATTACK,range,selfzones,oppozones,f,atk,cond)
	c:RegisterEffect(e)
	return e
end
function Card.UpdateDEFField(c,def,range,selfzones,oppozones,f,cond)
	local e=c:FieldEffect(EFFECT_UPDATE_DEFENSE,range,selfzones,oppozones,f,def,cond)
	c:RegisterEffect(e)
	return e
end
function Card.UpdateATKDEFField(c,atk,def,range,selfzones,oppozones,f,cond)
	local e1=c:FieldEffect(EFFECT_UPDATE_ATTACK,range,selfzones,oppozones,f,atk,cond)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(def)
	c:RegisterEffect(e2)
	return e1,e2
end
function Card.ChangeATKField(c,atk,range,selfzones,oppozones,f,cond)
	local e=c:FieldEffect(EFFECT_SET_ATTACK_FINAL,range,selfzones,oppozones,f,atk,cond)
	c:RegisterEffect(e)
	return e
end
function Card.ChangeDEFField(c,def,range,selfzones,oppozones,f,cond)
	local e=c:FieldEffect(EFFECT_SET_DEFENSE_FINAL,range,selfzones,oppozones,f,def,cond)
	c:RegisterEffect(e)
	return e
end

function Card.ChangeAttributeField(c,attr,range,selfzones,oppozones,f,cond)
	local e=c:FieldEffect(EFFECT_CHANGE_ATTRIBUTE,range,selfzones,oppozones,f,attr,cond)
	c:RegisterEffect(e)
	return e
end

function Card.ChangeRaceField(c,race,range,selfzones,oppozones,f,cond)
	local e=c:FieldEffect(EFFECT_CHANGE_RACE,range,selfzones,oppozones,f,race,cond)
	c:RegisterEffect(e)
	return e
end

function Card.UpdateLevelField(c,lv,range,selfzones,oppozones,f,cond)
	local e=c:FieldEffect(EFFECT_UPDATE_LEVEL,range,selfzones,oppozones,f,lv,cond)
	c:RegisterEffect(e)
	return e
end
function Card.ChangeLevelField(c,lv,range,selfzones,oppozones,f,cond)
	local e=c:FieldEffect(EFFECT_CHANGE_LEVEL,range,selfzones,oppozones,f,lv,cond)
	c:RegisterEffect(e)
	return e
end

--SS Procedures
function Card.SSProc(c,desc,prop,range,ctlim,cond,tg,op,pos,p,zone)
	local default_prop = (not pos1 and not p and not zone) and EFFECT_FLAG_UNCOPYABLE or EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM
	local prop = prop and prop or 0
	local range = range and range or (c:IsOriginalType(TYPE_EXTRA)) and LOCATION_EXTRA or LOCATION_HAND
	if p and p==PLAYER_ALL then
		tg=aux.SelectFieldForSSProc(tg,pos)
	end
	---
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	e1:SetProperty(default_prop+prop)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(range)
	if ctlim then
		if type(ctlim)=="table" then
			local flag=#ctlim>2 and ctlim[3] or EFFECT_COUNT_CODE_OATH
			e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
		else
			e1:SetCountLimit(ctlim)
		end
	end
	if pos or p then
		if not pos then pos=POS_FACEUP end
		if not p then p=0 end
		e1:SetTargetRange(pos,p)
	end
	if zone then
		e1:SetValue(zone)
	end
	if cond then
		e1:SetCondition(cond)
	end
	if tg then
		e1:SetTarget(tg)
	end
	if op then
		e1:SetOperation(op)
	end
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.SelectFieldForSSProc(f,pos)
	if not f then f=aux.TRUE end
	if not pos then pos=POS_FACEUP end
	return	function(...)
				local outcome=f(...)
				local sel=Duel.SelectOption(tp,102,103)
				if sel==0 then
					e:SetTargetRange(pos,0)
				else
					e:SetTargetRange(pos,1)
				end
				return outcome
			end
end