--Mage-Core of Inferno
function c249001265.initial_effect(c)
	aux.EnableDualAttribute(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(249001265,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c249001265.condition)
	e1:SetCost(c249001265.cost)
	e1:SetTarget(c249001265.target)
	e1:SetOperation(c249001265.operation)
	c:RegisterEffect(e1)
	--spsummon proc
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c249001265.spcon)
	c:RegisterEffect(e2)
end
function c249001265.cfilter(c)
	return c:IsFaceup() and c:IsCode(249001261)
end
function c249001265.condition(e,tp,eg,ep,ev,re,r,rp)
	return aux.IsDualState(e) and Duel.IsExistingMatchingCard(c249001265.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c249001265.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function c249001265.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c249001265.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c249001265.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c249001265.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c249001265.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c249001265.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Destroy(g,REASON_EFFECT)
end
function c249001265.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
