--Azure Magician
function c249001010.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,2)
	aux.EnablePendulumAttribute(c,false)
	c:EnableReviveLimit()
	--search spell/trap
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,2490010101)
	e1:SetCost(c249001010.cost)
	e1:SetTarget(c249001010.target)
	e1:SetOperation(c249001010.operation)
	c:RegisterEffect(e1)
	--attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(93)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c249001010.condition)
	e2:SetTarget(c249001010.target2)
	e2:SetOperation(c249001010.operation2)
	c:RegisterEffect(e2)
	--to pzone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74892653,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetCondition(c249001010.pcon)
	e3:SetTarget(c249001010.ptg)
	e3:SetOperation(c249001010.pop)
	c:RegisterEffect(e3)
	--tohand
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,2490010102)
	e4:SetTarget(c249001010.thtg)
	e4:SetOperation(c249001010.thop)
	c:RegisterEffect(e4)
end
c249001010.pendulum_level=4
function c249001010.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsSetCard(0x1B7) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function c249001010.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and Duel.IsExistingMatchingCard(c249001010.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE+LOCATION_EXTRA,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249001010.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249001010.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c249001010.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001010.filter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function c249001010.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c249001010.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.BreakEffect()
	end
	g=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(60082869,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		if tc and Duel.SSet(tp,tc,tp,false)~=0 then
			local e1=Effect.CreateEffect(e:GetHandler())
 	 	    e1:SetType(EFFECT_TYPE_SINGLE)
      		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
     	 	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	  	    tc:RegisterEffect(e1)
		   	local e2=e1:Clone()
		    e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		    tc:RegisterEffect(e2)
		end
	end
end
function c249001010.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function c249001010.filter2(c)
	return c:IsSetCard(0x1B7) and (c:IsFaceup() or not c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_MONSTER)
end
function c249001010.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249001010.filter2),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
end
function c249001010.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001010.filter2),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
    if g:GetCount()>0 then
    	Duel.Overlay(c,g)
    end
end
function c249001010.pcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
end
function c249001010.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
		or Duel.IsExistingMatchingCard(c249001010.filter3,tp,LOCATION_ONFIELD,0,1,nil)) end
end
function c249001010.filter3(c)
	return c:IsSetCard(0x1B7) and c:IsFaceup()
end
function c249001010.pop(e,tp,eg,ep,ev,re,r,rp)
	if (not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and not Duel.IsExistingMatchingCard(c249001010.filter3,tp,LOCATION_ONFIELD,0,1,nil) then return false end
	local g=Duel.SelectMatchingCard(tp,c249001010.filter3,tp,LOCATION_ONFIELD,0,1,1,nil)
    if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c249001010.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function c249001010.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetTargetRange(LOCATION_HAND,0)
    e1:SetCountLimit(1,249001010)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    Duel.RegisterEffect(e2,tp)
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	if g:GetCount()>0 then
		if g:IsExists(Card.IsAbleToHand,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(16404809,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			g:Sub(sg)
		end
	end
end