--Uru-Chain Overlayer
function c249001209.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--enable chain overlay
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,249001209)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c249001209.cost)
	e1:SetOperation(c249001209.operation)
	c:RegisterEffect(e1)
	--remove overlay replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c249001209.rcon)
	e2:SetOperation(c249001209.rop)
	c:RegisterEffect(e2)
end
function c249001209.costfilter(c)
	return c:IsSetCard(0x232) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function c249001209.costfilter2(c,e)
	return c:IsSetCard(0x232) and not c:IsPublic() and c:IsType(TYPE_MONSTER)
end
function c249001209.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249001209.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil)
	or Duel.IsExistingMatchingCard(c249001209.costfilter2,tp,LOCATION_HAND,0,1,nil)) end
	local option
	if Duel.IsExistingMatchingCard(c249001209.costfilter2,tp,LOCATION_HAND,0,1,nil)  then option=0 end
	if Duel.IsExistingMatchingCard(c249001209.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249001209.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil)
	and Duel.IsExistingMatchingCard(c249001209.costfilter2,tp,LOCATION_HAND,0,1,nil) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249001209.costfilter2,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249001209.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249001209.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_MONSTER))
	e1:SetTargetRange(LOCATION_OVERLAY,0)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local hg=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0):Filter(Card.IsType,nil,TYPE_MONSTER)
	local tc=hg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_XYZ_MATERIAL)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetValue(aux.TRUE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetOperation(c249001209.gop)
	Duel.RegisterEffect(e2,tp)
end
function c249001209.gfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
function c249001209.gop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(c249001209.gfilter,nil,tp)
	local tc=hg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_XYZ_MATERIAL)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetValue(aux.TRUE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
end
function c249001209.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(249001209+ep)==0
		and bit.band(r,REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and re:GetHandler():GetOverlayCount()>=ev-1
end
function c249001209.rop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(249001209+ep,RESET_PHASE+PHASE_END,0,1)
	Duel.Hint(HINT_CARD,1-tp,nil)
	return 1
end