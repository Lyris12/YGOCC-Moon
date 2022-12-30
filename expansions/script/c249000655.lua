--Guardian-Caller Healer
function c249000655.initial_effect(c)
	--recover
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c249000655.reccon)
	e1:SetTarget(c249000655.rectg)
	e1:SetOperation(c249000655.recop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c249000655.cost)
	e2:SetTarget(c249000655.target)
	e2:SetOperation(c249000655.operation)
	c:RegisterEffect(e2)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c249000655.reptg)
	e3:SetValue(c249000655.repval)
	e3:SetOperation(c249000655.repop)
	c:RegisterEffect(e3)
end
function c249000655.reccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c249000655.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct*400)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*400)
end
function c249000655.recop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	Duel.Recover(tp,ct*400,REASON_EFFECT)
end
function c249000655.costfilter(c)
	return c:IsSetCard(0x2052) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
function c249000655.costfilter2(c,e)
	return c:IsSetCard(0x2052) and not c:IsPublic() and c:IsType(TYPE_MONSTER)
end
function c249000655.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000655.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000655.costfilter2,tp,LOCATION_HAND,0,1,c)) end
	local option
	if Duel.IsExistingMatchingCard(c249000655.costfilter2,tp,LOCATION_HAND,0,1,c)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000655.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000655.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000655.costfilter2,tp,LOCATION_HAND,0,1,c) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000655.costfilter2,tp,LOCATION_HAND,0,1,1,c)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000655.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000655.tgfilter1(c,e,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsSetCard(0x1052)
end
function c249000655.tgfilter2(c,e,tp,att)
	return c:IsSetCard(0x1052) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c249000655.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000655.tgfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000655.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,c249000655.tgfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		local ac=Duel.AnnounceCardFilter(tp,0x1052,OPCODE_ISSETCARD,TYPE_FUSION,OPCODE_ISTYPE,OPCODE_AND)
		local sc=Duel.CreateToken(tp,ac)
		Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		sc=Duel.SelectMatchingCard(tp,c249000655.tgfilter2,tp,LOCATION_EXTRA,0,1,1,tc,e,tp,tc:GetOriginalAttribute()):GetFirst()
		if sc then
			if Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2,true)
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
				e3:SetCountLimit(1)
				e3:SetCondition(c249000655.retcon)
				e3:SetOperation(c249000655.retop)
				e3:SetLabel(1)
				sc:RegisterEffect(e3)
			end
			Duel.SpecialSummonComplete()
		end
	end
end
function c249000655.retcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function c249000655.retop(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetLabel()
	if t==1 then e:SetLabel(0)
	else Duel.SendtoDeck(e:GetHandler(),nil,0,REASON_EFFECT) end
end
function c249000655.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and (c:IsSetCard(0x1052) or c:IsSetCard(0x2052))
		and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function c249000655.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c249000655.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function c249000655.repval(e,c)
	return c80566312.repfilter(c,e:GetHandlerPlayer())
end
function c249000655.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end