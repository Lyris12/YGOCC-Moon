--Nunciator dell'Organizzazione Angeli, Verlo
--Script by XGlitchy30
function c16599460.initial_effect(c)
	--target protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(c16599460.efilter)
	c:RegisterEffect(e0)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCountLimit(1,16599460)
	e1:SetCondition(c16599460.negcon)
	e1:SetCost(c16599460.negcost)
	e1:SetTarget(c16599460.negtg)
	e1:SetOperation(c16599460.negop)
	c:RegisterEffect(e1)
	--lvchange
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,15599460)
	e2:SetCost(c16599460.thcost)
	e2:SetTarget(c16599460.thtg)
	e2:SetOperation(c16599460.thop)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2x)
end
--filters
function c16599460.cfilter(c,lv)
	return c:IsSetCard(0x1559) and c:IsType(TYPE_MONSTER) and c:GetLevel()<=lv and c:IsAbleToRemoveAsCost()
end
function c16599460.cfilter2(c,e)
	return c:IsSetCard(0x1559) and c:IsType(TYPE_MONSTER) and c:GetLevel()>0 and c:IsAbleToRemoveAsCost()
		and c:GetLevel()~=e:GetHandler():GetLevel()
end
function c16599460.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x1559) and re:GetHandler():GetLevel()==e:GetHandler():GetLevel() and not re:GetHandler():IsType(TYPE_SYNCHRO)
		and not re:GetHandler():IsCode(16599460)
end
function c16599460.thfilter(c)
	return c:IsAbleToRemoveAsCost()
end
function c16599460.rmcheck(c)
	return c:IsSetCard(0x1559) and c:IsLocation(LOCATION_REMOVED)
end
--target protection
function c16599460.efilter(e,re,rp)
	return ((re:GetHandler():GetLevel()>0 and re:GetHandler():IsLevelBelow(2)) or (re:GetHandler():GetRank()>0 and re:GetHandler():GetRank()<=2)) and rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--negate
function c16599460.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsType(TYPE_SYNCHRO)
end
function c16599460.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(c16599460.cfilter,tp,LOCATION_DECK,0,1,e:GetHandler(),re:GetHandler():GetLevel())
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c16599460.cfilter,tp,LOCATION_DECK,0,1,1,e:GetHandler(),re:GetHandler():GetLevel())
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c16599460.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingTarget(aux.disfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,aux.disfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function c16599460.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e3)
		end
	end
	--activation limit
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c16599460.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
--to hand
function c16599460.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c16599460.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(c16599460.cfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c16599460.cfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		local op=Duel.GetOperatedGroup():GetFirst()
		if op then
			e:SetLabel(op:GetOriginalLevel())
		end
	end
end
function c16599460.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		c:RegisterEffect(e1)
	end
end