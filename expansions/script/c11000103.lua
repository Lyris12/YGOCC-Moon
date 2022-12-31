--Rek'Sai
function c11000103.initial_effect(c)
	--adding to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11000103,0))
	e1:SetCountLimit(1,11000103)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c11000103.rmtgr)
	e1:SetOperation(c11000103.rmopr)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function c11000103.filterrgr(c)
	return  c:IsSetCard(0x1F4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c11000103.rmtgr(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11000103.filterrgr,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function c11000103.rmopr(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	local g=Duel.SelectMatchingCard(tp,c11000103.filterrgr,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then  end
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
end