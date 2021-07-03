--Paintress EX - Surrealist Dali
function c160002424.initial_effect(c)
	  --evolute procedure
	aux.AddOrigEvoluteType(c)
	aux.AddEvoluteProc(c,nil,6,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),2)
	c:EnableReviveLimit()

--to deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(160002424,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	   e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,160002424)
	e1:SetCondition(c160002424.retcon)
	e1:SetTarget(c160002424.rettg)
	e1:SetOperation(c160002424.retop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(160002424,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,160002425)
	e2:SetCost(c160002424.hdcost)
	e2:SetTarget(c160002424.destg)
	e2:SetOperation(c160002424.desop)
	c:RegisterEffect(e2)
end

function c160002424.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
end
function c160002424.thfilter(c)
	return c:IsSetCard(0xc52)  and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c160002424.thfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function c160002424.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp)   and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(c160002424.thfilter2,tp,LOCATION_SZONE,0,1,c)
		and Duel.IsExistingMatchingCard(c160002424.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	local g=Duel.SelectTarget(tp,c160002424.thfilter2,tp,LOCATION_SZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c160002424.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget() 
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c160002424.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

function c160002424.filter(c)
	return c:IsSetCard(0xc50) and c:IsAbleToHand()
end

function c160002424.retcon(e,tp,eg,ep,ev,re,r,rp)
	return  e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():GetPreviousControler()==tp --e:GetHandler():IsReason(REASON_DESTROY) and
end
function c160002424.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	 if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_GRAVE+LOCATION_REMOVED and c160002424.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c160002424.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c160002424.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c160002424.retop(e,tp,eg,ep,ev,re,r,rp)
	  local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)  then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
