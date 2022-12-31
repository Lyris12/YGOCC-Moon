--Spellbook Cache
function c249001060.initial_effect(c)
	aux.AddCodeList(c,249001056)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,249001060+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c249001060.target)
	e1:SetOperation(c249001060.activate)
	c:RegisterEffect(e1)
end
function c249001060.filter(c)
	return aux.IsCodeListed(c,249001056) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetCode()~=249001060 and c:IsAbleToHand()
end
function c249001060.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001060.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c249001060.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c249001060.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
