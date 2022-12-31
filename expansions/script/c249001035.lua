--Ancient Ninja Hiruzen, the Hokage
function c249001035.initial_effect(c)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72989439,1))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(2)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c249001035.cost)
	e1:SetTarget(c249001035.target)
	e1:SetOperation(c249001035.operation)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_HAND)
	e2:SetOperation(c249001035.chop)
	c:RegisterEffect(e2)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(1124)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c249001035.descon)
	e4:SetTarget(c249001035.destg)
	e4:SetOperation(c249001035.desop)
	c:RegisterEffect(e4)
end
function c249001035.tributefilter(c)
	return c:IsReleasable() and (c:IsType(TYPE_MONSTER) or (c:IsSetCard(0x61) and c:IsType(TYPE_CONTINUOUS)))and not c:IsStatus(STATUS_BATTLE_DESTROYED) 
end
function c249001035.chop(e,tp,eg,ep,ev,re,r,rp)
	if  rp==1-tp or not re:GetOwner():IsSetCard(0x61) or not e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) 
		or not Duel.IsExistingMatchingCard(c249001035.tributefilter,tp,LOCATION_ONFIELD,0,2,nil)
		or not Duel.SelectYesNo(tp,2) then return end
		local g=Duel.SelectMatchingCard(tp,c249001035.tributefilter,tp,LOCATION_ONFIELD,0,2,2,nil)
		Duel.Release(g,REASON_COST)
		Duel.SpecialSummon(e:GetHandler(),1,tp,tp,false,false,POS_FACEUP)
end
function c249001035.costfilter(c)
	return c:IsSetCard(0x61) and c:IsAbleToRemoveAsCost()
end
function c249001035.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001035.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249001035.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249001035.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsAbleToRemove() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c249001035.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function c249001035.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function c249001035.cfilter(c)
	return c:IsSetCard(0x61) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function c249001035.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001035.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c249001035.desop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c249001035.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) then return end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=g:Select(tp,1,Duel.GetMatchingGroupCount(c249001035.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil),nil)
	Duel.HintSelection(dg)
	Duel.Destroy(dg,REASON_EFFECT)
end
