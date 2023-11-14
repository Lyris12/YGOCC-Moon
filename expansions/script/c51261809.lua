--created by Zarc, coded by Lyris
--Elflair - Iro, Enraged Dark Elf
local s,id,o=GetID()
function s.initial_effect(c)
	c:RegisterSetCardString("Elflair")
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,"Elflair"),2,99,aux.FilterBoolFunction(Group.IsExists,Card.IsLinkAttribute,1,nil,ATTRIBUTE_DARK))
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.count)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
end
function s.filter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500*#g)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	if Duel.Destroy(g,REASON_EFFECT)<1 then return end
	local ct=Duel.GetOperatedGroup():FilterCount(s.filter,nil)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,500*ct,REASON_EFFECT)
	end
end
function s.cfilter(c,g)
	return c:IsFaceup() and c:IsSetCard("Elflair") and g:IsContains(c)
end
function s.count(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil,c:GetLinkedGroup()) then c:AddCounter(0x156e,1) end
end
function s.val(e,c)
	return 100*Duel.GetCounter(e:GetHandlerPlayer(),1,0,0x156e)
end
