--Temple of Summoned Guardians
function c249000659.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--inactivatable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetValue(c249000659.efilter)
	c:RegisterEffect(e2)
	--todeck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(61583217,0))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c249000659.tdcon)
	e4:SetTarget(c249000659.tdtg)
	e4:SetOperation(c249000659.tdop)
	c:RegisterEffect(e4)
end
function c249000659.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and te:GetHandler():IsSetCard(0x2052)
end
function c249000659.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2052)
end
function c249000659.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249000659.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c249000659.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function c249000659.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return (chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c:IsControler(tp)) or (chkc:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp)) and c249000659.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c249000659.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c249000659.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249000659.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end