--Sigil Beginning
function c213365.initial_effect(c)
	aux.AddCodeList(c,213355)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c213365.activate)
	c:RegisterEffect(e1)
	--Recover
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(213365,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,213365)
	e2:SetCost(c213365.thcost)
	e2:SetTarget(c213365.thtg)
	e2:SetOperation(c213365.thop)
	c:RegisterEffect(e2)
	--todeck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(213365,3))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,213366)
	e3:SetCondition(c213365.tdcon)
	e3:SetTarget(c213365.tdtg)
	e3:SetOperation(c213365.tdop)
	c:RegisterEffect(e3)
end
function c213365.addfilter(c)
	return aux.IsCodeListed(c,213355) and c:IsAbleToHand()
		and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_RITUAL)
end
function c213365.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c213365.addfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(213365,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c213365.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function c213365.thfilter(c)
	return aux.IsCodeListed(c,213355) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToDeck())
end
function c213365.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c213365.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c213365.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c213365.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function c213365.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsAbleToDeck() and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,aux.Stringid(213365,2))==1) then
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
function c213365.tdfilter(c)
	return c:IsFaceup() and c:IsCode(213355)
end
function c213365.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c213365.tdfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c213365.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c213365.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end