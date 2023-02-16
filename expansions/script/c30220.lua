--Mantra Alligator
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:IsSetCard(0x7d0) or (tc:GetCode()>30200 and tc:GetCode()<30230) end)
	--to defense
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetCategory(CATEGORY_POSITION)
	e0:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_DDD)
	e0:SetTarget(scard.potg)
	e0:SetOperation(scard.poop)
	c:RegisterEffect(e0)
	local e3=e0:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--confirm
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(s_id)
	e1:SetCondition(scard.condition)
	e1:SetCost(scard.cost)
	e1:SetTarget(scard.target)
	e1:SetOperation(scard.operation)
	c:RegisterEffect(e1)
	if not scard.global_check then
		scard.global_check=true
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_NEGATED)
		e2:SetProperty(EFFECT_FLAG_DELAY)
		e2:SetCondition(scard.negcon)
		e2:SetOperation(scard.negop)
		Duel.RegisterEffect(e2,0)
	end
end
function scard.potg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackPos() and c:IsCanChangePosition() end
	Duel.SetCardOperationInfo(c,CATEGORY_POSITION)
	Duel.SetCustomOperationInfo(0,CATEGORY_POSITION,c,1,c:GetControler(),c:GetLocation(),POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)
end
function scard.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)
	end
end

function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,s_id)==0
end
function scard.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,LOCATION_HAND,0,nil)>1 end
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD,nil)
	if Duel.GetTurnPlayer()==tp and e:IsActivated() then
		Duel.RegisterFlagEffect(tp,s_id,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,2)
	end
end
function scard.filter(c)
	return (c:IsOnField() and c:IsFacedown()) or (c:IsLocation(LOCATION_HAND) and not c:IsPublic())
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(scard.filter,tp,0,LOCATION_HAND+LOCATION_ONFIELD,1,nil) end
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(scard.filter,tp,0,LOCATION_HAND+LOCATION_ONFIELD,nil)
	Duel.ConfirmCards(tp,g)
	Duel.ShuffleHand(1-tp)
end

function scard.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetLabel()==s_id
end
function scard.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(rp,s_id)
end