--Night Assault Tactical Jammer
--Script by APurpleApple
local s,id=GetID()
function s.initial_effect(c)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--recall
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(s.rccon)
	e2:SetOperation(s.rcop)
	c:RegisterEffect(e2)
	--spproc
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.remtar)
	e3:SetCondition(s.sppcon)
	e3:SetOperation(s.remop)
	e3:SetCountLimit(1,56132155)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+ EFFECT_FLAG_DELAY)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.leavcon)
	e4:SetTarget(s.leavtar)
	e4:SetOperation(s.leavop)
	e4:SetCountLimit(1,56132154)
	c:RegisterEffect(e4)
end
function s.rccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c
end
function s.spfilter(c,e)
	return c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e) and c:GetLevel()<4 and c:GetCode()~=id
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SendtoHand(c,tp,REASON_EFFECT)
end
function s.sppcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x8af)
end
function s.remtar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) end
	Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,nil,nil)
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local tg = Duel.GetFirstTarget()
	if tg:IsRelateToEffect(e) then
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.negcon)
		e1:SetOperation(s.negop)
		e1:SetLabel(tg:GetOriginalType())
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c = re:GetHandler()
	return c:IsType(e:GetLabel()) and c:IsLocation(LOCATION_ONFIELD)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.leavcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.leavtar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND, 0, 1, nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.leavop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e)
	Duel.SpecialSummon(tc,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
end