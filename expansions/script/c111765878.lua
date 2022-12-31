function c111765878.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atkgain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(300)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x736))
	c:RegisterEffect(e2)
	--loltraps
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x736))
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetCondition(c111765878.trpcon)
	c:RegisterEffect(e3)
	--banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(111765878,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c111765878.dktg)
	e1:SetOperation(c111765878.dkop)
	c:RegisterEffect(e1)
end
--loltraps
function c111765878.trpfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1736)
end
function c111765878.trpcon(e)
	return Duel.IsExistingMatchingCard(c111765878.trpfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--banish
function c111765878.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp-1,LOCATION_DECK)
end
function c111765878.dkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetDecktopGroup(1-tp,3)
	Duel.DisableShuffleCheck()
	Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
end