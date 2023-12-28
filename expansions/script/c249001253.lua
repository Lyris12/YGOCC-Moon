--Neo World's Energy Synthesizer
function c249001253.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c249001253.condition)
	e1:SetTarget(c249001253.target)
	e1:SetOperation(c249001253.activate)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65338781,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c249001253.cttg)
	e2:SetOperation(c249001253.ctop)
	c:RegisterEffect(e2)
end
function c249001253.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x236)
end
function c249001253.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001253.cfilter,tp,LOCATION_ONFIELD,0,1,c)
end
function c249001253.filter(c,e,tp)
	return c:IsSetCard(0x236) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c249001253.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and (chkc:IsLocation(LOCATION_GRAVE) or chkc:IsLocation(LOCATION_REMOVED)) and c249001253.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c249001253.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c249001253.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c249001253.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c249001253.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x54,1)
end
function c249001253.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c249001253.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c249001253.ctfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c249001253.ctfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x54)
end
function c249001253.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x54,2)
	end
end