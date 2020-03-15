--coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddEvoluteProc(c,9,cid.mfilter1,cid.mfilter2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(cid.matcheck)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(cid.tgcon)
	e2:SetOperation(cid.tgop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(cid.ctcost)
	e3:SetTarget(cid.cttg)
	e3:SetOperation(cid.ctop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(cid.desop)
	c:RegisterEffect(e4)
end
function cid.mfilter1(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and aux.EvoluteValue(c)==3
end
function cid.mfilter2(c)
	return c:IsRace(RACE_DRAGON) and aux.EvoluteValue(c)==6
end
function cid.matcheck(e,c)
	e:SetLabel(0)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,id-13) then e:SetLabel(3) end
end
function cid.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388
end
function cid.tgop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(388,RESET_EVENT+0x1ff0000,0,1,e:GetLabelObject():GetLabel())
end
function cid.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1088)>=3 end
	e:GetHandler():RemoveCounter(tp,0x1088,3,REASON_COST)
end
function cid.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function cid.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1b9b,1)
		tc=g:GetNext()
	end
end
function cid.filter(c)
	return c:GetCounter(0x1b9b)>0
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		Duel.Damage(tp,ct*400,REASON_EFFECT)
	end
end
