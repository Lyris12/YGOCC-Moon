--Uru-Chain Assailant
function c249001212.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--s/t set (battled)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCost(c249001212.setcost)
	e1:SetTarget(c249001212.settg)
	e1:SetOperation(c249001212.setop)
	c:RegisterEffect(e1)
	--s/t st (to grave)
	local e2=e1:Clone()
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c249001212.setcon)
	c:RegisterEffect(e2)
	--s/t st (to extra)
	local e3=e1:Clone()
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c249001212.setcon2)
	c:RegisterEffect(e3)	
	--chain attack
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(78274190,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c249001212.catg)
	e4:SetOperation(c249001212.caop)
	c:RegisterEffect(e4)
end
function c249001212.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():IsPreviousControler(tp)
end
function c249001212.costfilter(c)
	return c:IsSetCard(0x232) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function c249001212.costfilter2(c)
	return c:IsSetCard(0x232) and not c:IsPublic()
end
function c249001212.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249001212.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,e:GetHandler())
	or Duel.IsExistingMatchingCard(c249001212.costfilter2,tp,LOCATION_HAND,0,1,e:GetHandler())) end
	local option
	if Duel.IsExistingMatchingCard(c249001212.costfilter2,tp,LOCATION_HAND,0,1,e:GetHandler())  then option=0 end
	if Duel.IsExistingMatchingCard(c249001212.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,e:GetHandler()) then option=1 end
	if Duel.IsExistingMatchingCard(c249001212.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,e:GetHandler())
	and Duel.IsExistingMatchingCard(c249001212.costfilter2,tp,LOCATION_HAND,0,1,e:GetHandler()) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249001212.costfilter2,tp,LOCATION_HAND,0,1,1,nil,e)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249001212.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249001212.setfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
function c249001212.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c249001212.setfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c249001212.setfilter,tp,0,LOCATION_GRAVE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,c249001212.setfilter,tp,0,LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function c249001212.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then
		Duel.SSet(tp,tc)
		Duel.ConfirmCards(1-tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end
function c249001212.setcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()
end
function c249001212.afilter(c,tp)
	return c:IsControler(tp) and c:IsChainAttackable()
end
function c249001212.catg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c249001212.afilter,1,nil,tp) end
	local a=eg:Filter(c249001212.afilter,nil,tp):GetFirst()
	Duel.SetTargetCard(a)
end
function c249001212.caop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToBattle() then
		Duel.ChainAttack()
	end
end