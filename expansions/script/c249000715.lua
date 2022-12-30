--Evolution-Knight of Tactics
function c249000715.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--inactivatable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetValue(c249000715.efilter)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81055000,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c249000715.thcon)
	e2:SetTarget(c249000715.thtg)
	e2:SetOperation(c249000715.thop)
	c:RegisterEffect(e2)
	--scale
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_LSCALE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCondition(c249000715.slcon)
	e4:SetValue(6)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e5)
	--search
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(42940404,2))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetTarget(c249000715.stg)
	e6:SetOperation(c249000715.sop)
	c:RegisterEffect(e6)
end
function c249000715.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:GetHandler():IsSetCard(0x1E9) and te:IsActiveType(TYPE_MONSTER)
end
function c249000715.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsReason(REASON_DESTROY)
end
function c249000715.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c249000715.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function c249000715.slcon(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x1E9)
end
function c249000715.sfilter(c)
	return c:IsSetCard(0x1E9) and c:GetCode()~=249000715 and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c249000715.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000715.sfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c249000715.sop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c249000715.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end