--Kitseki Assalto
--Script by XGlitchy30
function c88523905.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,88523905+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c88523905.target)
	e1:SetOperation(c88523905.activate)
	c:RegisterEffect(e1)
end
--filters
function c88523905.filter(c)
	return c:IsSetCard(0x215a) and c:IsAbleToGrave()
end
--Activate
function c88523905.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c88523905.filter,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsPlayerCanDiscardDeck(1-tp,1) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
end
function c88523905.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local ct=0
	local deck=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
	if deck<=0 then return end
	if deck<3 then
		ct=deck
	else
		ct=3
	end
	local g=Duel.SelectMatchingCard(tp,c88523905.filter,tp,LOCATION_DECK,0,1,ct,nil)
	if g:GetCount()>0 then
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
			local op=Duel.GetOperatedGroup()
			local opf=op:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
			if Duel.IsPlayerCanDiscardDeck(1-tp,opf) then
				Duel.DiscardDeck(1-tp,opf,REASON_EFFECT)
			end
		end
	end
end