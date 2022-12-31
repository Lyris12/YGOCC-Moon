--Quick Escape
--coded by Concordia
function c68709348.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,68709348+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c68709348.condition)
	e1:SetTarget(c68709348.target)
	e1:SetOperation(c68709348.activate)
	c:RegisterEffect(e1)
end
function c68709348.afilter(c)
	return c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER)
end
function c68709348.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c68709348.afilter,tp,LOCATION_GRAVE,0,3,99,nil)
end
function c68709348.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf09)
end
function c68709348.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c68709348.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c68709348.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c68709348.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c68709348.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c68709348.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function c68709348.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end