--Rites-Summoner Black Mage
function c249000294.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--destroy pzone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(502)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetCondition(c249000294.descon)
	e1:SetTarget(c249000294.destg)
	e1:SetOperation(c249000294.desop)
	c:RegisterEffect(e1)
	--tribute to destroy
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(1101)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c249000294.condition)
	e2:SetCost(c249000294.cost)
	e2:SetTarget(c249000294.target)
	e2:SetOperation(c249000294.operation)
	c:RegisterEffect(e2)
	
end
function c249000294.cfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x1AF) or c:IsSetCard(0x1B0)) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function c249000294.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c249000294.cfilter,1,nil,tp)
end
function c249000294.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsDestructable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c249000294.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c249000294.confilter(c,e,tp)
	return c:IsSetCard(0x1B0) and not c:IsCode(249000294)
end
function c249000294.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249000294.confilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c249000294.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function c249000294.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsDestructable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c249000294.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end