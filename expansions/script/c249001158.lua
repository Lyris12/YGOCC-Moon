--Change True Power of Evil HERO - Supreme King's Imperative
function c249001158.initial_effect(c)
	return
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c249001158.condition)
	e1:SetOperation(c249001158.operation)
	c:RegisterEffect(e1)
end
function c249001158.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(249001155)
end
function c249001158.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001158.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(tp,249001158)==0
end
function c249001158.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,249001158)~=0 then return end
	Duel.RegisterFlagEffect(tp,249001158,0,0,0)
	local cc=Duel.CreateToken(tp,48130397)
	Duel.SendtoHand(cc,nil,REASON_RULE)
	local ac=Duel.AnnounceCard(tp,0x8,OPCODE_ISSETCARD,TYPE_FUSION,OPCODE_ISTYPE,OPCODE_AND)
	cc=Duel.CreateToken(tp,ac)
	Duel.SendtoDeck(cc,2,nil,REASON_RULE)
end