--Multitask Tracciatracce
--Script by XGlitchy30
function c86433605.initial_effect(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c86433605.regop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1x)
	local e1y=e1:Clone()
	e1y:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1y)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86433605,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,80433605)
	e2:SetCondition(c86433605.spcon)
	e2:SetTarget(c86433605.sptg)
	e2:SetOperation(c86433605.spop)
	c:RegisterEffect(e2)
end
--filters
function c86433605.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
function c86433605.spfilter(c,e,tp)
	return c:IsSetCard(0x86f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(86433605)
end
--tohand
function c86433605.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86433605,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,86433605)
	e1:SetTarget(c86433605.thtg)
	e1:SetOperation(c86433605.thop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function c86433605.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c86433605.filter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToHand() and Duel.IsExistingTarget(c86433605.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,c86433605.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c86433605.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		if g:GetCount()<=0 then return end
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
--spsummon
function c86433605.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c86433605.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c86433605.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c86433605.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c86433605.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local og=Duel.GetOperatedGroup():GetFirst()
			if og:IsPosition(POS_FACEUP_ATTACK) then
				local e0x=Effect.CreateEffect(c)
				e0x:SetType(EFFECT_TYPE_SINGLE)
				e0x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e0x:SetRange(LOCATION_MZONE)
				e0x:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
				e0x:SetValue(1)
				e0x:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
				og:RegisterEffect(e0x)
				local e0y=e0x:Clone()
				e0y:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
				og:RegisterEffect(e0y)
				og:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(86433605,2))
			elseif og:IsPosition(POS_FACEUP_DEFENSE) then
				local e0x=Effect.CreateEffect(c)
				e0x:SetType(EFFECT_TYPE_SINGLE)
				e0x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e0x:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
				e0x:SetRange(LOCATION_MZONE)
				e0x:SetValue(aux.imval1)
				e0x:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
				og:RegisterEffect(e0x)
				local e0y=e0x:Clone()
				e0y:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
				e0y:SetValue(aux.tgoval)
				og:RegisterEffect(e0y)
				og:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(86433605,3))
			end
		end
	end
end