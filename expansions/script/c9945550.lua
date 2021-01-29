--Zodiakieri Constellation
function c9945550.initial_effect(c)
	--Cannot Trigger
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetCondition(c9945550.condition)
	c:RegisterEffect(e1)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9945550,0))
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,9945550+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e2)
	--Negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9945550,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,9945550)
	e3:SetCondition(c9945550.descon)
	e3:SetTarget(c9945550.destg)
	e3:SetOperation(c9945550.desop)
	c:RegisterEffect(e3)
	--Set
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(9945550,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetTarget(c9945550.settg)
	e5:SetCountLimit(1,9945551)
	e5:SetOperation(c9945550.setop)
	c:RegisterEffect(e5)
end
function c9945550.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not (c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY))
	and not (c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD))
end

function c9945550.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_MONSTER)
end
function c9945550.negfilter(c)
	return c:IsFaceup() and not c:IsDisabled() and c:IsType(TYPE_EFFECT)
end
function c9945550.negfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x12D7)
end
function c9945550.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c9945550.negfilter,tp,0,LOCATION_MZONE,1,nil)
	and Duel.IsExistingTarget(c9945550.negfilter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=Duel.SelectTarget(tp,c9945550.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g1,1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g2=Duel.SelectTarget(tp,c9945550.negfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
function c9945550.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	local ex1,tg1=Duel.GetOperationInfo(0,CATEGORY_DISABLE)
	local ex2,tg2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	local tc=tg1:GetFirst()
	if tg1:GetFirst():IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_PHASE+(ph)+RESET_EVENT+0x1fc0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_PHASE+(ph)+RESET_EVENT+0x1fc0000)
		tc:RegisterEffect(e2)
		Duel.AdjustInstantly(tc)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetTargetRange(0,1)
		e3:SetTarget(c9945550.sumlimit)
		e3:SetLabel(tc:GetCode())
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
		if tg2:GetFirst():IsRelateToEffect(e) then
		Duel.SendtoHand(tg2,nil,REASON_EFFECT)
	end
end
function c9945550.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
function c9945550.setfilter(c)
	return c:IsSetCard(0x12D7) and not c:IsCode(9945550) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c9945550.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c9945550.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c9945550.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c9945550.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
		Duel.ConfirmCards(1-tp,g)
	end
end