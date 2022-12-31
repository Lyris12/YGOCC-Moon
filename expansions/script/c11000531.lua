--Shya Chimera Balance
function c11000531.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Shya
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11000531,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_ONFIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11000531)
	e2:SetCondition(c11000531.drcon)
	e2:SetTarget(c11000531.drtg)
	e2:SetOperation(c11000531.drop)
	c:RegisterEffect(e2)
	--Chimera
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11000531,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_ONFIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,11000531)
	e3:SetCondition(c11000531.thcon)
	e3:SetTarget(c11000531.thtg)
	e3:SetOperation(c11000531.thop)
	c:RegisterEffect(e3)
	--add setcode
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_ADD_SETCODE)
	e4:SetValue(0x11FD)
	c:RegisterEffect(e4)
end
function c11000531.afilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:GetPreviousControler()==tp 
		and c:IsSetCard(0x1FD) and not c:IsSetCard(0x11FD)
end
function c11000531.drcon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c11000531.afilter,nil,tp)
	e:SetLabelObject(g:GetFirst())
	return g:GetCount()>0
end
function c11000531.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c11000531.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c11000531.bfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:GetPreviousControler()==tp
		and (c:IsSetCard(0x11FD) or c:IsSetCard(0x1F3))
end
function c11000531.thcon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c11000531.bfilter,nil,tp)
	e:SetLabelObject(g:GetFirst())
	return g:GetCount()>0
end
function c11000531.dfilter(c)
	return c:IsSetCard(0x11FD) and c:IsFaceup() and c:IsAbleToHand()
end
function c11000531.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11000531.dfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function c11000531.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c11000531.dfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		if Duel.ConfirmCards(1-tp,g)~=0 then
			Duel.BreakEffect()
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
