--Mysterious Caterpillar
function c53313913.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--PANDES EFFECTS
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(aux.PandActCheck)
	e1:SetTarget(c53313913.target)
	e1:SetOperation(c53313913.operation)
	c:RegisterEffect(e1)
	aux.EnablePandemoniumAttribute(c,e1)
	--MONSTER EFFECTS
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53313913,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53313913)
	e2:SetCondition(c53313913.drycon)
	e2:SetTarget(c53313913.drytg)
	e2:SetOperation(c53313913.dryop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53313913,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,50313913)
	e3:SetCost(c53313913.spcost)
	e3:SetTarget(c53313913.sptg)
	e3:SetOperation(c53313913.spop)
	c:RegisterEffect(e3)
	--search
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(53313913,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1,51313913)
	e4:SetCost(c53313913.thcost)
	e4:SetTarget(c53313913.thtg)
	e4:SetOperation(c53313913.thop)
	c:RegisterEffect(e4)
end
--filters
function c53313913.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_SZONE)
		and c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsPreviousPosition(POS_FACEUP)
		and c:GetPreviousControler()==tp
end
function c53313913.discardfilter(c,tp,e)
	return c:IsSetCard(0xcf6) and c:IsDiscardable()
		and Duel.IsExistingMatchingCard(c53313913.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,c:GetCode(),c:GetAttribute(),e,tp)
end
function c53313913.spfilter(c,code,attr,e,tp)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and not c:IsCode(code) and c:IsAttribute(attr)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c53313913.thfilter(c)
	return c:IsSetCard(0xcf6) and c:IsAbleToHand()
end
--PANDES EFFECTS
function c53313913.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not Duel.IsChainNegatable(ev) then return false end
		if re:IsHasCategory(CATEGORY_NEGATE) and ev>1
			and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
		local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
		return ex and tg~=nil and tc+tg:Filter(Card.IsOnField,nil):FilterCount(Card.IsControler,nil,tp)-tg:GetCount()>0
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c53313913.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
--MONSTER EFFECTS
--destroy
function c53313913.drycon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53313913.cfilter,1,nil,tp)
end
function c53313913.drytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c53313913.dryop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then 
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
--special summon
function c53313913.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function c53313913.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local obj=e:GetLabelObject()
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c53313913.discardfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),tp,e) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,c53313913.discardfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler(),tp,e)
	if g:GetCount()>0 then
		e:SetLabelObject(g:GetFirst())
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c53313913.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local obj=e:GetLabelObject()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53313913.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,obj:GetCode(),obj:GetAttribute(),e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--search
function c53313913.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c53313913.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313913.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c53313913.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c53313913.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end