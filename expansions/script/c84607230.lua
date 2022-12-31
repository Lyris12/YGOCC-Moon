--Spiritualist Fading
function c84607230.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84607230,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c84607230.thcon)
	e1:SetTarget(c84607230.thtg)
	e1:SetOperation(c84607230.thop)
	c:RegisterEffect(e1)
	 --destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c84607230.reptg)
	e2:SetValue(c84607230.repval)
	e2:SetOperation(c84607230.repop)
	c:RegisterEffect(e2)
end
function c84607230.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousControler()==tp
end
function c84607230.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c84607230.cfilter,1,nil,tp)
end
function c84607230.filter(c)
	return c:IsSetCard(0x7ce) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c84607230.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c84607230.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c84607230.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c84607230.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c84607230.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0x7ce)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function c84607230.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c84607230.repfilter,1,nil,tp) end
	return Duel.SelectYesNo(tp,aux.Stringid(84607230,0))
end
function c84607230.repval(e,c)
	return c84607230.repfilter(c,e:GetHandlerPlayer())
end
function c84607230.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end