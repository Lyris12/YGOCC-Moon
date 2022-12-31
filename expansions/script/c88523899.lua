--Kitseki Shiekura
--Script by XGlitchy30
function c88523899.initial_effect(c)
	--link procedure
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x215a),2)
	c:EnableReviveLimit()
	--deck destruction
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88523899,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c88523899.deckcon)
	e1:SetTarget(c88523899.decktg)
	e1:SetOperation(c88523899.deckop)
	c:RegisterEffect(e1)
end
--filters
function c88523899.filter(c)
	return c:IsSetCard(0x215a) and c:IsFaceup()
end
--deck destruction
function c88523899.deckcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function c88523899.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
end
function c88523899.deckop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
	if g:GetCount()<1 then return end
	Duel.ConfirmCards(tp,g)
	if g:IsExists(Card.IsAbleToGrave,1,nil) then
		if g:IsExists(Card.IsAbleToGrave,2,nil) and Duel.IsExistingMatchingCard(c88523899.filter,tp,LOCATION_MZONE,0,3,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g:Select(tp,2,2,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT)
			Duel.ShuffleDeck(1-tp)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT)
			Duel.ShuffleDeck(1-tp)
		end
	end
end	