--Magna Aula dell'Organizzazione Angeli
--Script by XGlitchy30
function c16599469.initial_effect(c)
	c:SetUniqueOnField(1,0,16599469)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--synchro protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c16599469.efilter)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--change stats
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16599469,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetTarget(c16599469.target)
	e2:SetOperation(c16599469.operation)
	c:RegisterEffect(e2)
	--trigger limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c16599469.accon)
	e3:SetValue(c16599469.aclimit)
	c:RegisterEffect(e3)
	--set
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c16599469.setcon)
	e4:SetTarget(c16599469.settg)
	e4:SetOperation(c16599469.setop)
	c:RegisterEffect(e4)
	local e4x=e4:Clone()
	e4x:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4x)
end
--filters
function c16599469.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:GetLevel()>1
end
function c16599469.acfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1559) and c:IsType(TYPE_SYNCHRO)
end
--synchro protection
function c16599469.efilter(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FAIRY)
end
--change stats
function c16599469.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16599469.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c16599469.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c16599469.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c16599469.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local opt=0
		opt=Duel.SelectOption(tp,aux.Stringid(16599469,0),aux.Stringid(16599469,1))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		if opt==0 then
			e1:SetValue(-1)
		else
			e1:SetValue(1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(tc:GetDefense())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
--trigger limit
function c16599469.accon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and Duel.IsExistingMatchingCard(c16599469.acfilter,tp,LOCATION_MZONE,0,1,nil)
end 
function c16599469.aclimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
function c16599469.setfilter(c)
	return c:IsSetCard(0x1559) and c:GetType()==TYPE_TRAP and c:IsSSetable()
end
--set
function c16599469.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c16599469.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c16599469.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) 
	end
	if Duel.IsExistingMatchingCard(c16599469.setfilter,tp,LOCATION_GRAVE,0,1,nil) then
		e:SetCategory(CATEGORY_LEAVE_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
	end
end
function c16599469.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16599469.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.SSet(tp,tc)
		Duel.ConfirmCards(1-tp,tc)
		--enable quick activation
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end