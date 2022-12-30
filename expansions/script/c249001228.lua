--Light-Crusader Tendril Manipulator
function c249001228.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c249001228.sptg)
	e1:SetOperation(c249001228.spop)
	c:RegisterEffect(e1)
	--to hand 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92826944,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,249001228)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c249001228.target)
	e2:SetOperation(c249001228.operation)
	c:RegisterEffect(e2)
end
function c249001228.filter(c,e,tp)
	return c:IsSetCard(0x233) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c249001228.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c249001228.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c249001228.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001228.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c249001228.filter2(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
function c249001228.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_GRAVE and c249001228.filter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c249001228.filter2,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c249001228.filter2,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c249001228.countfilter(c)
	return c:IsSetCard(0x233) and c:IsType(TYPE_MONSTER)
end
function c249001228.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,tc)
		local g=Duel.GetMatchingGroup(c249001228.countfilter,tp,LOCATION_GRAVE,0,c:GetHandler())
		local ct=g:GetClassCount(Card.GetCode)
		if ct<2 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(c249001228.sumlimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function c249001228.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end