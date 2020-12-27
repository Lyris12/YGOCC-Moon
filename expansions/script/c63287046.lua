--created by Pina, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCategory(CATEGORY_COIN+CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetTarget(s.cointg)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK+LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.hfilter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x26) and c:IsAbleToGrave()
end
function s.tfilter2(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x26) and c:IsAbleToHand()
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.TossCoin(tp,1)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		if Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.hfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)==0 then return end
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tfilter1,tp,LOCATION_DECK,0,2,2,nil)
		if Duel.SendtoGrave(g,REASON_EFFECT)==0 or g:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_GRAVE) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.tfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
