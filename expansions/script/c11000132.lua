--Sands Renekton
function c11000132.initial_effect(c)
	--diratk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c11000132.atcon)
	c:RegisterEffect(e1)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
function c11000132.filter(c)
	return c:IsFaceup() and c:IsCode(11000131)
end
function c11000132.atcon(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(c11000132.filter,tp,LOCATION_MZONE,0,1,nil)
end