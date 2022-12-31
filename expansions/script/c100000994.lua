function c100000994.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c100000994.spcon)
	c:RegisterEffect(e1)
	--remove field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetDescription(aux.Stringid(100000994,0))
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c100000994.cost)
	e2:SetTarget(c100000994.targetf)
	e2:SetOperation(c100000994.operationf)
	c:RegisterEffect(e2)
	--remove hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetDescription(aux.Stringid(100000994,1))
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c100000994.cost)
	e3:SetTarget(c100000994.targeth)
	e3:SetOperation(c100000994.operationh)
	c:RegisterEffect(e3)
	--remove hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetDescription(aux.Stringid(100000994,2))
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c100000994.cost)
	e4:SetTarget(c100000994.targetg)
	e4:SetOperation(c100000994.operationg)
	c:RegisterEffect(e4)
	--discard deck
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCategory(CATEGORY_DECKDES)
	e5:SetCountLimit(1)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c100000994.condition2)
	e5:SetTarget(c100000994.target2)
	e5:SetOperation(c100000994.operation2)
	c:RegisterEffect(e5)
	--splimit
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e6)
end
function c100000994.spfilter1(c)
	return (c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER))
end
function c100000994.spfilter2(c)
	return c:IsCode(57774843)
end
function c100000994.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c100000994.spfilter1,tp,LOCATION_GRAVE,0,7,nil)
		and Duel.IsExistingMatchingCard(c100000994.spfilter2,tp,LOCATION_GRAVE,0,3,nil)
end
function c100000994.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function c100000994.targetf(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRemoveable,tp,0,LOCATION_ONFIELD,1,c) end
	local sg1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg1,sg1:GetCount(),0,0)
end
function c100000994.operationf(e,tp,eg,ep,ev,re,r,rp)
	local sg1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,e:GetHandler())
	Duel.Remove(sg1,nil,REASON_EFFECT)
end
function c100000994.targeth(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRemoveable,tp,0,LOCATION_HAND,1,c) end
	local sg1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg1,sg1:GetCount(),0,0)
end
function c100000994.operationh(e,tp,eg,ep,ev,re,r,rp)
	local sg1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,e:GetHandler())
	Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)
end
function c100000994.targetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRemoveable,tp,0,LOCATION_GRAVE,1,c) end
	local sg1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg1,sg1:GetCount(),0,0)
end
function c100000994.operationg(e,tp,eg,ep,ev,re,r,rp)
	local sg1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,e:GetHandler())
	Duel.Remove(sg1,nil,REASON_EFFECT)
end
function c100000994.condition2(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function c100000994.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,5)
end
function c100000994.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,5,REASON_EFFECT)
end
