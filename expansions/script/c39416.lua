--Dracosis Electrosyde
function c39416.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c39416.mfilter,c39416.xyzcheck,2,2,c39416.alt,aux.Stringid(39415,0))
	--negate activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92661479,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c39416.condition)
	e1:SetCost(c39416.cost)
	e1:SetTarget(c39416.target)
	e1:SetOperation(c39416.operation)
	c:RegisterEffect(e1)
end
function c39416.mfilter(c,xyzc)
	return c:GetLevel()==4 and c:IsSetCard(0x300)
end
function c39416.xyzcheck(g)
	local sg=g:Filter(function(c) return c:GetLevel()==4 end,nil)
	return sg:GetClassCount(Card.GetRace)>=2 or sg:GetClassCount(Card.GetAttribute)>=2
end
function c39416.alt(c)
	return c:IsSetCard(0x300) and c:GetLevel()==6
end
function c39416.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER)
end
function c39416.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg:IsExists(c39416.filter,1,nil,tp) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function c39416.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c39416.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function c39416.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then Duel.Destroy(eg,REASON_EFFECT) end
end
