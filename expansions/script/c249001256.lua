--Neo World Battle Mage
function c249001256.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(510)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,249001256)
	e1:SetCost(c249001256.setcost)
	e1:SetTarget(c249001256.settg)
	e1:SetOperation(c249001256.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48343627,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c249001256.condition)
	e4:SetTarget(c249001256.target)
	e4:SetOperation(c249001256.operation)
	c:RegisterEffect(e4)
end
function c249001256.costfilter(c)
	return c:IsSetCard(0x236) and c:IsDiscardable()
end
function c249001256.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001256.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c249001256.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c249001256.setfilter(c)
	return c:IsSetCard(0x236) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c249001256.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249001256.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function c249001256.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001256.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then Duel.SSet(tp,tc) end
end
function c249001256.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) or c:IsReason(REASON_BATTLE)
end
function c249001256.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chck:IsControler(1-tp) and chkc:IsDestructable() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c249001256.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
