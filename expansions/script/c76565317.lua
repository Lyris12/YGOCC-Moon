--Ritmi Mistici - Pianka Kat
--Script by XGlitchy30
function c76565317.initial_effect(c)
	c:EnableCounterPermit(0x1555)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_CUSTOM+76565329)
	e1:SetCountLimit(1,76565317)
	e1:SetTarget(c76565317.sptg)
	e1:SetOperation(c76565317.spop)
	c:RegisterEffect(e1)
	local efix=e1:Clone()
	efix:SetCode(EVENT_CUSTOM+76565322)
	c:RegisterEffect(efix)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c76565317.thcost)
	e2:SetTarget(c76565317.thtg)
	e2:SetOperation(c76565317.thop)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,76265317)
	e3:SetCondition(c76565317.lfcon)
	e3:SetTarget(c76565317.lftg)
	e3:SetOperation(c76565317.lfop)
	c:RegisterEffect(e3)
end
--filters
function c76565317.counterf(c)
	return c:IsFaceup() and c:GetCounter(0x1555)>0
end
function c76565317.costfilter(c)
	return c:IsSetCard(0x7555) and c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsCanRemoveCounter(c:GetControler(),0x1555,1,REASON_COST)
end
function c76565317.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7555) and c:GetCode()~=76565317 and c:IsAbleToHand()
end
--counter tracker
function c76565317.ctop0(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	local group=Duel.GetMatchingGroup(c76565317.counterf,tp,LOCATION_ONFIELD,0,nil)
	local ct=group:GetCount()
	for card in aux.Next(group) do
		if card:GetCounter(0x1555)>0 then
			count=count+card:GetCounter(0x1555)
		end
	end
	e:SetLabel(count)
end
function c76565317.ctop1(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabelObject():GetLabel()
	local newcount=0
	local group=Duel.GetMatchingGroup(c76565317.counterf,tp,LOCATION_ONFIELD,0,nil)
	for card in aux.Next(group) do
		if card:GetCounter(0x1555)>0 then
			newcount=newcount+card:GetCounter(0x1555)
		end
	end
	if newcount<count then
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+76565317,e,0,0,tp,0)
		e:GetLabelObject():SetLabel(newcount)
	else
		e:GetLabelObject():SetLabel(newcount)
	end
end
function c76565317.exc(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()+2)
end
function c76565317.exc2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,1000,REASON_EFFECT)
	local fcount=0
	local group=Duel.GetMatchingGroup(c76565317.counterf,tp,LOCATION_ONFIELD,0,nil)
	if group:GetCount()<=0 then
		e:GetLabelObject();SetLabel(0)
	else
		for card in aux.Next(group) do
			if card:GetCounter(0x1555)>0 then
				fcount=fcount+card:GetCounter(0x1555)
			end
		end
		e:GetLabelObject():SetLabel(fcount)
	end
end
--spsummon
function c76565317.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c76565317.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--to hand
function c76565317.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76565317.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,c76565317.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	if g:GetCount()>0 then
		g:GetFirst():RemoveCounter(tp,0x1555,1,REASON_COST)
	end
end
function c76565317.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c76565317.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c76565317.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(c76565317.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function c76565317.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
--draw
function c76565317.lfcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function c76565317.lftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_SZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_SZONE)
end
function c76565317.lfop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_SZONE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
