--Flamiller Breeder
function c1242354360.initial_effect(c)
	--search equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1242354360,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c1242354360.thtg)
	e1:SetOperation(c1242354360.thop)
	c:RegisterEffect(e1)
	--Rota
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1242354360,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1242354360)
	e2:SetCost(c1242354360.cost2)
	e2:SetOperation(c1242354360.operation)
	c:RegisterEffect(e2)
end

--search equip
function c1242354360.thfilter(c)
	return c:IsCode(1242354353) and c:IsAbleToHand()
end
function c1242354360.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1242354360.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c1242354360.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1242354360.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--search Ritual

function c1242354360.rfilter(c,ft)
	return (c:IsLocation(LOCATION_SZONE)) and c:IsCode(1242354353) and c:IsAbleToGraveAsCost()
end
function c1242354360.afilter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsSetCard(0x786) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function c1242354360.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1242354360.rfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c1242354360.rfilter,tp,LOCATION_SZONE,0,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
	end
		Duel.SendtoGrave(g,REASON_COST)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetLabel(1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		e:GetHandler():RegisterFlagEffect(1242354360,RESET_PHASE+PHASE_END,0,1)

	end
function c1242354360.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c1242354360.afilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end