--Kitseki Solaruna
--Script by XGlitchy30
function c88523909.initial_effect(c)
	--link procedure
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x215a),2)
	c:EnableReviveLimit()
	--deck destruction
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88523909,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c88523909.ddtg)
	e1:SetOperation(c88523909.ddop)
	c:RegisterEffect(e1)
end
--deck destruction
function c88523909.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetHandler():GetLinkedGroup():IsExists(aux.TRUE,3,nil) then
		local fd=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
		if not fd:IsExists(Card.IsAbleToGrave,4,nil) then return end
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,4,1-tp,LOCATION_DECK)
	else
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
	end
end
function c88523909.ddop(e,tp,eg,ep,ev,re,r,rp)
	local op=nil
	local opg=nil
	if e:GetHandler():GetLinkedGroup():IsExists(aux.TRUE,3,nil) then
		if Duel.SelectYesNo(tp,aux.Stringid(88523909,1)) then
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_DECK,4,4,nil)
			if g:GetCount()>=0 then
				Duel.ConfirmCards(tp,g)
				Duel.SendtoGrave(g,REASON_EFFECT)
				op=Duel.GetOperatedGroup()
				Duel.ShuffleDeck(1-tp)
			end
		end
	else
		Duel.DiscardDeck(1-tp,4,REASON_EFFECT)
		op=Duel.GetOperatedGroup()
	end
	op:KeepAlive()
	opg=op:GetFirst()
	while opg do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		opg:RegisterEffect(e1)
		opg=op:GetNext()
	end
end
