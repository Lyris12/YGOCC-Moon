--Paracyclis Capturer

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_POSITION+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsSetCard(0x308) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not rc:IsDisabled() and Duel.IsChainDisablable(ev)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToChain(ev)
	if chk==0 then
		return not relation or (rc:IsLocation(LOCATION_MZONE) and rc:IsCanTurnSetGlitchy(tp) or rc:IsAbleToGrave())
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if relation and rc:IsLocation(LOCATION_MZONE) then
		Duel.SetTargetCard(rc)
		if rc:IsCanTurnSetGlitchy(tp) then
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
		elseif rc:IsAbleToGrave() then
			Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,rc,1,rc:GetControler(),rc:GetLocation())
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if Duel.NegateEffect(ev) and tc:IsRelateToChain(ev) and tc:IsLocation(LOCATION_MZONE) then
		if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)~=0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:Desc(1)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCondition(s.limcon)
			if Duel.GetTurnPlayer()==tp then
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
			else
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
			end
			e1:SetLabel(Duel.GetTurnCount(),tp)
			tc:RegisterEffect(e1)
		elseif tc:IsRelateToChain() then
			Duel.SendtoGrave(tc,nil,REASON_EFFECT)
		end
	end
end
function s.limcon(e)
	local ct,tp=e:GetLabel()
	return Duel.GetTurnCount()>ct and Duel.GetTurnPlayer()==1-tp
end