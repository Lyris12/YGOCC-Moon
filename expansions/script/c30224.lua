--Mantra Rhino
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:IsSetCard(0x7d0) or (tc:GetCode()>30200 and tc:GetCode()<30230) end)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,RELEVANT_TIMINGS+TIMING_DAMAGE_STEP)
	e1:SetCondition(scard.discon)
	e1:SetTarget(scard.tg)
	e1:SetOperation(scard.op)
	e1:SetCountLimit(1)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
function scard.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase(tp) and aux.ExceptOnDamageCalc()
end
function scard.handfilter(c)
	return c:IsMantra() and c:IsType(TYPE_MONSTER) and c:IsDiscardable(REASON_EFFECT)
end
function scard.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(scard.handfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function scard.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(scard.handfilter,tp,LOCATION_HAND,0,nil)
	if #g<=0 then return end
	local c=e:GetHandler()
	local ct=Duel.DiscardHand(tp,scard.handfilter,1,#g,REASON_EFFECT+REASON_DISCARD)
	if ct>0 and c:IsFaceup() and c:IsRelateToChain() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*400)
		c:RegisterEffect(e1)
	end
end
