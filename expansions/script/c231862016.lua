--created by ZEN, coded by TaxingCorn117
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetCondition(cid.rmcon)
	e1:SetCost(cid.rmcost)
	e1:SetTarget(cid.rmtg)
	e1:SetOperation(cid.rmop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(cid.atkcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.atktg)
	e2:SetOperation(cid.atkop)
	c:RegisterEffect(e2)
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x52f)
end
function cid.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,nil) or Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_REMOVED,0,2,nil)
end
function cid.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function cid.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cid.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and cid.rmfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(cid.rmfilter,tp,0,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,cid.rmfilter,tp,0,LOCATION_ONFIELD,1,2,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,#g*200)
end
function cid.ctfilter2(c)
	return c:IsLocation(LOCATION_REMOVED) and c:IsType(TYPE_TRAP) and not c:IsReason(REASON_REDIRECT)
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	local ct=Duel.GetOperatedGroup():FilterCount(cid.ctfilter2,nil)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Damage(tp,ct*200,REASON_EFFECT)
	end
end
function cid.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,2,nil) and Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function cid.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,200)
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=Duel.TossDice(tp,1)
	if Duel.Damage(tp,d*200,REASON_EFFECT)~=0 and Duel.GetLP(tp)>0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp and 2 or 1)
			e1:SetValue(-d*500)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end