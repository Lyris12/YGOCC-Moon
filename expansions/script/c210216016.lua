function c210216016.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210216016)
	e1:SetOperation(c210216016.tgop)
	c:RegisterEffect(e1)
end
function c210216016.tgop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(c210216016.actop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c210216016.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if  re:IsActiveType(TYPE_TRAP) and rc:IsSetCard(0x216) then
		Duel.SetChainLimit(c210216016.chainlm)
	end
end
function c210216016.chainlm(e,rp,tp)
	return tp==rp
end