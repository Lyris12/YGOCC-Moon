--Binding Snake Clausolas of Evil Vine
function c500317491.initial_effect(c)
--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(500317491,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c500317491.target)
	e1:SetCost(c500317491.cost)
	e1:SetOperation(c500317491.operation)
	c:RegisterEffect(e1)
		--cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
		--Cannot Summon/Set
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_SUMMON)
	e3:SetCondition(c500317491.sumcon)
	c:RegisterEffect(e3)
end
function c500317491.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function c500317491.cfilter2(c)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
function c500317491.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c500317491.cfilter2,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c500317491.cfilter2,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function c500317491.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c500317491.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c500317491.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c500317491.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	if tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_LIGHT)or tc:IsAttribute(ATTRIBUTE_DARK)then
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
end
function c500317491.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		if tc:IsType(TYPE_MONSTER) and tc:IsAttribute(ATTRIBUTE_LIGHT) or tc:IsAttribute(ATTRIBUTE_DARK) then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
end
function c500317491.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x85a) 
end
function c500317491.sumcon(e)
return not Duel.IsExistingMatchingCard(c500317491.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end