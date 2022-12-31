--Cocytus, Ice Prison
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	--Xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),5,2)
	c:EnableReviveLimit()
	--counter
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(scard.target)
	e1:SetOperation(scard.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(scard.disable)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(scard.atktarget)
	c:RegisterEffect(e3)
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and
		Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT) then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if g:GetCount()==0 then return end
	for tc in aux.Next(g) do
		tc:AddCounter(0x1301,1)
	end
end
function scard.disable(e,c)
	return (c:IsType(TYPE_EFFECT) or ((c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT)) and c:GetCounter(0x1301)>0
end
function scard.atktarget(e,c)
	return c:GetCounter(0x1301)>0
end
