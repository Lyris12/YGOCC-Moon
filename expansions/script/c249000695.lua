--Arcane-Transcend Cyber Magician
function c249000695.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--add to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36733451,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c249000695.thcon)
	e2:SetTarget(c249000695.thtg)
	e2:SetOperation(c249000695.thop)
	c:RegisterEffect(e2)
	--copy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48229808,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,249000695)
	e3:SetCondition(c249000695.condition)
	e3:SetCost(c249000695.cost)
	e3:SetTarget(c249000695.target)
	e3:SetOperation(c249000695.operation)
	c:RegisterEffect(e3)
end
function c249000695.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
function c249000695.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsSetCard(0x1E6)
end
function c249000695.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c36733451.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c249000695.filter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c249000695.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function c249000695.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
function c249000695.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function c249000695.rmfilter(c)
	return c:IsSetCard(0x1E6) and c:IsAbleToRemoveAsCost()
end
function c249000695.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000695.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	local sg=Duel.SelectMatchingCard(tp,c249000695.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function c249000695.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if re:GetHandler():GetOriginalCode()==249000695 then return false end
	local tg=re:GetTarget()
	if chk==0 and tg then return tg(e,tp,eg,ep,ev,re,r,rp,0) else return true end
end
function c249000695.operation(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local tg=re:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	local op=re:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end