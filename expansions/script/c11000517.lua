--Shya Deceiver
function c11000517.initial_effect(c)
	--atklimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--can't atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11000517,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11000517)
	e2:SetCondition(c11000517.condition)
	e2:SetOperation(c11000517.operation)
	c:RegisterEffect(e2)
end
function c11000517.condition(e,tp,eg,ep,ev,re,r,rp)
	return (e:GetHandler():IsReason(REASON_COST)
		and (re:GetHandler():IsSetCard(0x1FD) or re:GetHandler():IsCode(11000525)))
		or ((re:GetHandler():IsSetCard(0x1FD) or re:GetHandler():IsCode(11000525)) 
		and bit.band(r,REASON_EFFECT)~=0)
		and not e:GetHandler():IsReason(REASON_BATTLE)
end
function c11000517.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end