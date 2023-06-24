--Metalurgos Overdrive
--Overdrive Metalurgo
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[When your opponent activates a card or effect while you control a face-up "Metalurgos" Bigbang Monster: Negate the activation, and if you do, destroy that card.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT()
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If this card is destroyed by a card effect and sent to the GY: You can Set this card.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
--FILTERS E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_BIGBANG) and c:IsSetCard(ARCHE_METALURGOS)
end
--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	return Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable(e) and re:GetHandler():IsRelateToChain(ev) then
		Duel.SetCardOperationInfo(eg,CATEGORY_DESTROY)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

--E2
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReason()&(REASON_DESTROY|REASON_EFFECT)==REASON_DESTROY|REASON_EFFECT
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end