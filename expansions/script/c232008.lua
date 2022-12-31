--Galvanizer Dragon Gustav
function c232008.initial_effect(c)
	 --synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x232),1)
	c:EnableReviveLimit()
 --atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c232008.atkup)
	c:RegisterEffect(e1)
 --Attack Protect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(232008,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c232008.cost)
	e2:SetOperation(c232008.tgop)
	c:RegisterEffect(e2)
  --Death
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(232008,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,232008)
	e4:SetCondition(c232008.spcondition)
	e4:SetCost(c232008.spcost)
	e4:SetTarget(c232008.sptarget)
	e4:SetOperation(c232008.spoperation)
	c:RegisterEffect(e4)
end
function c232008.spcondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function c232008.cfilter(c,tp)
	return c:IsSetCard(0x232) and c:IsAbleToRemoveAsCost()
end
function c232008.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c232008.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c232008.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c232008.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c232008.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()/2)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		c:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
	end
end


function c232008.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(232008,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c232008.aclimit)
	e1:SetCondition(c232008.actcon)
	e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
	
end
function c232008.aclimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
function c232008.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end

function c232008.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc then
		Duel.ConfirmCards(1-tp,tc)
		if not tc:IsSetCard(0x232) then
			Duel.BreakEffect()
			Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
			if Duel.IsChainDisablable(0) then
			Duel.NegateEffect(0)
			end
		end
		Duel.ShuffleHand(tp)
	end
end

function c232008.atkfilter(c)
	return c:IsSetCard(0x232) and c:IsType(TYPE_MONSTER)
end
function c232008.atkup(e,c)
	return Duel.GetMatchingGroupCount(c232008.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end