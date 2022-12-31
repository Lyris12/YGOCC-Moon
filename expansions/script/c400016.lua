--Untergang Kataklysmus
function c400016.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,400016+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c400016.target)
	e1:SetOperation(c400016.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(400016,ACTIVITY_CHAIN,c400016.counterfilter)
end
function c400016.counterfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsType(TYPE_QUICKPLAY) and re:GetHandler():IsSetCard(0x246))
end
function c400016.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x246)
end
function c400016.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(c400016.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetTurnPlayer()~=tp end
	local ct=Duel.GetMatchingGroupCount(c400016.cfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function c400016.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		if Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED) then
			c:RegisterFlagEffect(400016,0x1600000+RESET_PHASE+PHASE_END,0,1)
			--EP search
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
			e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
			e2:SetReset(RESET_PHASE+PHASE_END)
			e2:SetCountLimit(1)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetCondition(c400016.descon)
			e2:SetTarget(c400016.destg)
			e2:SetOperation(c400016.desop)
			c:RegisterEffect(e2)
		end
	end
end
function c400016.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(400016)~=0 and Duel.GetCustomActivityCount(400015,tp,ACTIVITY_CHAIN)>3
end
function c400016.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c400016.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c400016.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstMatchingCard(c400016.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
function c400016.filter(c)
	return c:IsCode(400016) and c:IsAbleToHand()
end
