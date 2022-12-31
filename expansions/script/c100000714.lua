--Created and scripted by Rising Phoenix
function c100000714.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCost(c100000714.cost)
	e1:SetTarget(c100000714.target)
	e1:SetOperation(c100000714.activate)
	c:RegisterEffect(e1)
			--counter
	local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(100000714,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c100000714.ctcost)
	e3:SetTarget(c100000714.cttg)
		e3:SetCountLimit(1,100000714+EFFECT_COUNT_CODE_DUEL)
	e3:SetOperation(c100000714.ctop)
	c:RegisterEffect(e3)
end
function c100000714.cfilter(c)
	return (c:IsCode(100000736) or c:IsCode(100000909) or c:IsCode(100000908) or c:IsCode(100000737)or c:IsCode(100000714)) and c:IsAbleToDeckAsCost() and c:IsFaceup()
end
function c100000714.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100000714.cfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c100000714.cfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function c100000714.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c100000714.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x54,1)
end
function c100000714.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c100000714.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c100000714.ctfilter,tp,LOCATION_ONFIELD,0,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c100000714.ctfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x54)
end
function c100000714.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x54,1)
	end
end
function c100000714.filter(c)
	return c:IsCode(100000736) and c:IsAbleToHand()
end
function c100000714.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100000714.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c100000714.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c100000714.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
