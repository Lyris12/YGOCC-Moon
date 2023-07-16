--Dracosis Syowar

local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,2,s.alt,aux.Stringid(id,0))
	--negate
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_DISABLE|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(aux.DetachSelfCost())
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,4) and c:IsSetCard(0x300)
end
function s.xyzcheck(g)
	return g:GetClassCount(Card.GetRace)==#g or g:GetClassCount(Card.GetAttribute)==#g
end
function s.alt(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,6) and c:IsSetCard(0x300)
end

function s.tfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x300)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end