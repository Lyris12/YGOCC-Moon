-- Abyss Script - Cupid's Kiss
function c109052023.initial_effect(c)
	aux.AddSetNameMonsterList(c,0x10ec)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c109052023.target)
	e1:SetOperation(c109052023.activate)
	c:RegisterEffect(e1)
	--Floating Effect
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c109052023.CoHcon)
	e2:SetTarget(c109052023.CoHtarget)
	e2:SetOperation(c109052023.CoHoperation)
	c:RegisterEffect(e2)

	--Can be activated the turn it was set by an effect

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCondition(c109052023.checkCon)
	c:RegisterEffect(e3)
	if not c109052023.global_check then
	c109052023.global_check=true
	local GSC = Effect.CreateEffect(c)
	GSC:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	GSC:SetCode(EVENT_SSET)
	GSC:SetOperation(c109052023.SetCheck)
	Duel.RegisterEffect(GSC,0)
	end
end

function c109052023.checkCon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():HasFlagEffect(109052023)
end

function c109052023.SetCheck(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re==REASON_EFFECT then return end
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(109052023,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end

function c109052023.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function c109052023.myActors(c)
	return c:IsSetCard(0x10ec) and not c:IsLevelBelow(4)
end

function c109052023.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local AAs = Duel.GetMatchingGroupCount(c109052023.myActors,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsOnField() and s.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(c109052023.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) and 
		Duel.IsExistingMatchingCard(c109052023.myActors,tp, LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c109052023.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,AAs,e:GetHandler()) --Select Spell/traps up to the number of AAs we control
	--Except level 4 or lower monsters and not this card
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c109052023.activate(e,tp,eg,ep,ev,re,r,rp)
	local g = Duel.GetTargetCards(e)
	if #g >0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function c109052023.CoHcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		and Duel.IsExistingMatchingCard(c109052023.FaceupEDFilter,tp,LOCATION_EXTRA,0,1,nil)
end

function c109052023.FaceupEDFilter(c)
    return c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end

function c109052023.CoHtarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

function c109052023.CoHoperation(e,tp,eg,ep,ev,re,r,rp)

	local TurnPlayer = 3
	if Duel.GetTurnPlayer() ~= tp then TurnPlayer = 2 end 

    if Duel.GetLocationCount(tp,LOCATION_MZONE) <= 0 then return end

    local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.HintSelection(g,true)

    if #g > 0 then
        Duel.GetControl(g,tp,PHASE_END,TurnPlayer)
		local mon = g:GetFirst()
		local c = e:GetHandler()
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(3302)
		e4:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CANNOT_TRIGGER)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,TurnPlayer)
		mon:RegisterEffect(e4)

		local e5 = Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_ADD_SETCODE)
		e5:SetValue(0x10ec)
		e5:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CONTROL)
		mon:RegisterEffect(e5)
    end
end