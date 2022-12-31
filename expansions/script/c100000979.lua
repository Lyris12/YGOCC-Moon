 --Created and coded by Rising Phoenix
function c100000979.initial_effect(c)
		--act
	local e10=Effect.CreateEffect(c)
	e10:SetOperation(c100000979.actb)
	e10:SetCost(c100000979.descost)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e10:SetCode(EVENT_PREDRAW)
	e10:SetRange(LOCATION_DECK)
	e10:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	c:RegisterEffect(e10)
	--acthand
	local e20=Effect.CreateEffect(c)
	e20:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e20:SetRange(LOCATION_HAND)
	e20:SetCode(EVENT_PREDRAW)
	e20:SetOperation(c100000979.actb)
	e20:SetCost(c100000979.descost)
	e20:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	c:RegisterEffect(e20)
	--actgrave
	local e30=Effect.CreateEffect(c)
	e30:SetOperation(c100000979.actb)
	e30:SetCost(c100000979.descost)
	e30:SetRange(LOCATION_GRAVE)
	e30:SetCode(EVENT_PREDRAW)
	e30:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e30:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	c:RegisterEffect(e30)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100000979,0))
	e2:SetRange(LOCATION_REMOVED)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetCondition(c100000979.drcon)
	e2:SetTarget(c100000979.drtg)
	e2:SetOperation(c100000979.drop)
	c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100000979,0))
	e3:SetRange(LOCATION_REMOVED)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PREDRAW)
	e3:SetCondition(c100000979.drcon2)
	e3:SetTarget(c100000979.drtg2)
	e3:SetOperation(c100000979.drop2)
	c:RegisterEffect(e3)
		--immune
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetValue(c100000979.efilter)
	c:RegisterEffect(e4)
end
function c100000979.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function c100000979.actb(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
function c100000979.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,100000979)==0 end
	Duel.RegisterFlagEffect(tp,100000979,0,0,0)
end
function c100000979.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW
end
function c100000979.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_DECK) and c100000979.filtermm(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c100000979.filtermm,tp,0,LOCATION_DECK,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c100000979.filtermm,tp,0,LOCATION_DECK,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c100000979.filtermm(c)
	return c:IsAbleToHand()
end
function c100000979.drop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
			local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END,3)
	Duel.RegisterEffect(e1,tp)
	end
end
function c100000979.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_DRAW
end
function c100000979.drtg2(e,tp,eg,ep,ev,re,r,rp,chk)
if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_DECK) and c100000979.filtermm2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c100000979.filtermm2,1-tp,0,LOCATION_DECK,1,nil) end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(1-tp,c100000979.filtermm,1-tp,0,LOCATION_DECK,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c100000979.filtermm2(c)
	return c:IsAbleToHand()
end
function c100000979.drop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,1-tp,REASON_EFFECT)
		Duel.ConfirmCards(tp,tc)
			local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END,3)
	Duel.RegisterEffect(e1,1-tp)
	end
end