--Flamiller Snaketoss
function c1242354357.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--Target Equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1242354357,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCost(c1242354357.cost)
	e2:SetTarget(c1242354357.eqtg)
	e2:SetOperation(c1242354357.eqop)
	c:RegisterEffect(e2)
	--Rota
	--instant(chain)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1242354357,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetLabel(1)
	e4:SetCountLimit(1,1242354357)
	e4:SetCost(c1242354357.cost2)
	e4:SetOperation(c1242354357.operation)
	c:RegisterEffect(e4)
end

--Target equip
function c1242354357.cfilter(c,tp)
	return c:IsFaceup()
		and Duel.IsExistingMatchingCard(c1242354357.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c:GetOriginalAttribute(),c:GetOriginalRace(),tp)
end
function c1242354357.eqfilter(c,att,race,tp)
	return c:IsCode(1242354353)
end
function c1242354357.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) and Duel.GetFlagEffect(tp,1242354357)==0 end
	Duel.PayLPCost(tp,500)
end
function c1242354357.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and c1242354357.cfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c1242354357.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c1242354357.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c1242354357.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,c1242354357.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tc:GetOriginalAttribute(),tc:GetOriginalRace(),tp)
		local sc=g:GetFirst()
		local res=sc:IsLocation(LOCATION_GRAVE)
		if not Duel.Equip(tp,sc,tc) then return end  
	end
end
--rota
--filter for cost
function c1242354357.thfilter(c,ft)
	return (c:IsLocation(LOCATION_HAND+LOCATION_SZONE)) and c:IsCode(1242354353) and c:IsAbleToGraveAsCost()
end
function c1242354357.afilter(c)
	return c:IsSetCard(0x786) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function c1242354357.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1242354357.thfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c1242354357.thfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
	end
		Duel.SendtoGrave(g,REASON_COST)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetLabel(1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		e:GetHandler():RegisterFlagEffect(1242354357,RESET_PHASE+PHASE_END,0,1)

	end
function c1242354357.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c1242354357.afilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end





