function c1553015.initial_effect(c)
	--send to grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1553015,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,1553015)
	e1:SetCondition(c1553015.condition)
	e1:SetTarget(c1553015.target)
	e1:SetOperation(c1553015.operation)
	c:RegisterEffect(e1)
end
function c1553015.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xFA0) and c:IsAbleToGrave()
end
function c1553015.condition(e,tp,eg,ep,ev,re,r,rp)
	return e and (e:GetHandler():IsSetCard(0xFA0)) or (e:GetHandler():GetSummonType()==SUMMON_TYPE_PENDULUM)
end
function c1553015.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1553015.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c1553015.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c1553015.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end