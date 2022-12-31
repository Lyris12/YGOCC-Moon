--Kitseki Expectance
--Script by XGlitchy30
function c88523893.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c88523893.condition)
	e1:SetTarget(c88523893.target)
	e1:SetOperation(c88523893.activate)
	c:RegisterEffect(e1)
end
--filters
--Activate
function c88523893.condition(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOnField())
end
function c88523893.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function c88523893.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		--spell/trap negation
		if re:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP) then
			local rc=re:GetHandler()
			local seq=rc:GetSequence()
			rc:CancelToGrave()
			Duel.SendtoDeck(rc,nil,2,REASON_EFFECT)
			local op=Duel.GetOperatedGroup()
			local tc=op:GetFirst()
			Duel.SSet(1-tp,tc)
			Duel.MoveSequence(tc,seq)
			Duel.ConfirmCards(1-tp,tc)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT+0x17a0000+RESET_PHASE+PHASE_STANDBY)
			tc:RegisterEffect(e1)
		--monster negation
		elseif re:GetHandler():IsType(TYPE_MONSTER) and re:GetHandler():IsCanTurnSet() then
			if Duel.ChangePosition(re:GetHandler(),POS_FACEDOWN_DEFENSE)~=0 then
				local op=Duel.GetOperatedGroup()
				local tc=op:GetFirst()
				while tc do
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
					e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_STANDBY)
					tc:RegisterEffect(e1)
					tc=op:GetNext()
				end
			end
		end
	end
end
