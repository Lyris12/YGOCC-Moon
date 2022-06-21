--Chronologist Advance
--Keddy was here~
local cod,id=GetID()
function cod.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cod.target)
	e1:SetOperation(cod.activate)
	c:RegisterEffect(e1)
end
function cod.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x593) and c:IsType(TYPE_MONSTER)
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cod.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>0 end
end
function cod.activate(e,tp,eg,ep,ev,re,r,rp)
	--Turn Count
	local g=Duel.GetMatchingGroup(cod.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if ct==0 then return end
	for i=1,ct do
		Duel.MoveTurnCount()
	end
	--Gain ATK
	local g2=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE):Filter(Card.IsFaceup,nil)
	local tc=g2:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*100)
		e1:SetReset(RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g2:GetNext()
	end
end