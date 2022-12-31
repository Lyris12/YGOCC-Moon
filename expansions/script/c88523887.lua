--Kitseki Grooming
--Script by XGlitchy30
function c88523887.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,88523887)
	e1:SetTarget(c88523887.target)
	e1:SetOperation(c88523887.activate)
	c:RegisterEffect(e1)
end
--filters
function c88523887.scfilter(c)
	return c:IsSetCard(0x215a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c88523887.extracard(c)
	return c:IsSetCard(0x215a) and c:IsAbleToHand()
end
--Activate
function c88523887.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c88523887.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c88523887.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c88523887.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)>10 and Duel.IsExistingMatchingCard(c88523887.extracard,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(88523887,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local extra=Duel.SelectMatchingCard(tp,c88523887.extracard,tp,LOCATION_DECK,0,1,1,nil)
			if extra:GetCount()>0 then
				Duel.SendtoHand(extra,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,extra)
			end
		end
	end
end
