--Spiritualist Elaine
function c84607227.initial_effect(c)
	--ritual level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetValue(c84607227.rlevel)
	c:RegisterEffect(e1)
	--End Phase Search
   local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c84607227.regop)
	c:RegisterEffect(e2)
end
function c84607227.rlevel(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsSetCard(0x7ce) then
		local clv=c:GetLevel()
		return lv*65536+clv
	else return lv end
end
function c84607227.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(31383545,0))
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,84607227)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c84607227.thtg)
		e1:SetOperation(c84607227.thop)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function c84607227.filter(c)
	return c:IsSetCard(0x7ce) and c:IsType(TYPE_MONSTER) and (not c:IsCode(84607227)) and c:IsAbleToHand()
end
function c84607227.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c84607227.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c84607227.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c84607227.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end